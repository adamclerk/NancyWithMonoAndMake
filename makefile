C=dmcs
BUILDTYPE=DEBUG
SUBDIR=models helpers modules host
BIN=src/bin/
HOST=src/bin/host.exe
BINFOLDER=src/bin/holder.keep
NUGET=src/bin/nuget.keep

#########################
# D_* Dependency
# T_* Target
# P_* Parameter for Command
# L_* List
# C_* Command
#########################

#########################
#     Source Files      #
#########################
#find all files with *.cs extension
D_SRC=$(shell find src -type f -name '*.cs')

#########################
#    Resource Files     #
#########################
#find all the files with *.txt extension in the src/Resources dir
#DEPENDENCY
D_RESTXT=$(shell find src/Resources -type f -name '*.txt')
#pattern substr to create *.resources
#TARGETS
T_RES=$(patsubst src/Resources/%.txt,src/bin/res/%.resources, $(D_RESTXT))
#pattern substr to create parameters for dmcs
P_RES=$(patsubst %,-resource:%, $(T_RES))

#########################
#    DLL References     #
#########################
#find all the dll that was copied to the bin
L_DLL=$(shell find src/bin -type f -name '*.dll')
#create references (-r:*) for dmcs compiler
P_DLL=$(patsubst src/bin/%.dll, -r:src/bin/%.dll, $(L_DLL))

#########################
#   System References   #
#########################
SYSREF=src/SystemRef.txt
L_SYSREF=$(shell cat $(SYSREF) | tr '\n' ' ')
P_SYSREF=$(patsubst %,-r:%, $(L_SYSREF))

#########################
#      Nuget nupkg      #
#########################
PKG_DIR=src/Packages
PKG_CONFIG=$(PKG_DIR)/packages.config
L_NUGET=$(strip $(shell sed -n 's|<package id="\([a-zA-Z0-9\.]*\)" version="\([a-zA-Z0-9\.]*\)\(.*\)|\1/\2|p' $(PKG_CONFIG) | tr '\n' ' '))
TEMP_NUGET=$(subst /,___,$(L_NUGET))
T_NUGET=$(patsubst %,$(PKG_DIR)/%.nupkg, $(TEMP_NUGET))

APPCONFIG=src/App.config

all: build
	@echo "SOLUTION BUILT!"

build: $(BINFOLDER) $(HOST)

$(HOST): $(D_SRC) $(APPCONFIG) $(T_NUGET) $(T_RES) $(HOST).config
	@echo "BUILDING $(@F)"
	$C -out:$(HOST) -d:$(BUILDTYPE) $(P_SYSREF) $(P_DLL) $(P_RES) $(D_SRC)

$(HOST).config: $(APPCONFIG)
	@echo "COPYING APPCONFIG"
	@cp src/App.config $(HOST).config

$(BINFOLDER):
	@echo "CREATING BIN FOLDER"
	@mkdir -p src/bin
	@mkdir -p src/bin/res
	@touch $(BINFOLDER)

nuget: $(T_NUGET)

$(T_NUGET):
	@echo "RETRIEVING NUGET: $@"
	@echo $@ | sed 's|$(PKG_DIR)\/\([a-zA-Z0-9.]*\)___\([a-zA-Z0-9.]*\).nupkg|http://packages.nuget.org/api/v2/package/\1/\2|' | xargs -I {} wget -nv --unlink -O $@  {}
	@echo "UNZIPING NUGET PKG: $@"
	@echo $@ | sed 's|.nupkg||g' | xargs -I dir unzip -u -q -d dir $@ 
	@echo "COPYING DLL TO BIN"
	@echo $@ | sed 's|.nupkg||g' | xargs -I path find path -type f -name "*.dll" | xargs -I file rsync -W file src/bin

$(T_RES): $(D_RESTXT)
	@echo "CONVERTING TXT TO RESOURCE"
	@resgen $< $@

clean:
	@echo "CLEANING PROJECT"
	@echo "CLEANING PACKAGES FOLDER"
	@find src/Packages -type f -name "*.nupkg" | xargs -I nupkg rm nupkg
	@find src/Packages -type d -path 'src/Packages/*' -maxdepth 1 | xargs -I nupkgdir rm -r nupkgdir
	@rm -r src/bin
	@mkdir -p src/bin
	
run: build
	@echo "RUNNING SITE"
	@mono ./src/bin/host.exe

config:
	@echo "SYSREF:      $(SYSREF)"
	@echo "L_SYSREF:    $(L_SYSREF)"
	@echo "P_SYSREF:    $(P_SYSREF)"
	@echo "L_NUGET:     $(L_NUGET)"
	@echo "TEMP_NUGET:  $(TEMP_NUGET)"
	@echo "T_NUGET:     $(T_NUGET)"
	@echo "PKG_CONFIG:  $(PKG_CONFIG)"
	@echo "T_RES:       $(T_RES)"
	@echo "P_RES:       $(P_RES)"
