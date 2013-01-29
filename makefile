C=dmcs
FLAGS=-debug -d:DEBUG -d:TRACE
SUBDIR=models helpers modules host
URL=http://localhost.com:4444
BIN=bin
HOST=$(BIN)/host.exe
SITEDLL=$(BIN)/site.dll
TESTDLL=$(BIN)/test.dll
BINFOLDER=$(BIN)/holder.keep

#########################
# D_* Dependency
# T_* Target
# P_* Parameter for Command
# L_* List
# C_* Command
#########################

#########################
#   Site Source Files   #
#########################
#find all files with *.cs extension
D_SITESRC=$(shell find src -type f -name '*.cs')

#########################
#  Host Source Files    #
#########################
#find all files with *.cs extension
D_HOSTSRC=$(shell find host -type f -name '*.cs')

#########################
#  Test Source Files    #
#########################
#find all files with *.cs extension
D_TESTSRC=$(shell find test -type f -name '*.cs')

#########################
#    Resource Files     #
#########################
#find all the files with *.txt extension in the src/Resources dir
#DEPENDENCY
D_RESTXT=$(shell find src/Resources -type f -name '*.txt')
#pattern substr to create *.resources
#TARGETS
T_RES=$(patsubst src/Resources/%.txt,$(BIN)/res/%.resources, $(D_RESTXT))
#pattern substr to create parameters for dmcs
P_RES=$(patsubst %,-resource:%, $(T_RES))

#########################
#    Site References    #
#########################
SITEREF=src/DLLRef.txt
D_SITEREF=$(shell cat $(SITEREF) | tr '\n' ' ')

#TARGETS THAT ARE NOT SYSTEM REFERENCE (file name only)
L_EXPLICITSITEREF=$(filter pkg/%, $(D_SITEREF))
L_SYSSITEREF=$(filter-out pkg/%, $(D_SITEREF))
T_FILESITEREF=$(notdir $(L_EXPLICITSITEREF))
T_SITEREF=$(patsubst %,bin/%, $(T_FILESITEREF))
L_FINALSITEREF=$(L_SYSSITEREF) $(T_SITEREF)
P_SITEREF=$(patsubst %,-r:%, $(L_FINALSITEREF))

#########################
#    Host References    #
#########################
HOSTREF=host/DLLRef.txt
D_HOSTREF=$(shell cat $(HOSTREF) | tr '\n' ' ')

#TARGETS THAT ARE NOT SYSTEM REF (file name only)
L_EXPLICITHOSTREF=$(filter pkg/%, $(D_HOSTREF))
L_SYSHOSTREF=$(filter-out pkg/%, $(D_HOSTREF))
T_FILEHOSTREF=$(notdir $(L_EXPLICITHOSTREF))
T_HOSTREF=$(patsubst %,bin/%, $(T_FILEHOSTREF))
L_FINALHOSTREF=$(L_SYSHOSTREF) $(T_HOSTREF)
P_HOSTREF=$(patsubst %,-r:%, $(L_FINALHOSTREF))

#########################
#    Test References    #
#########################
TESTREF=test/DLLRef.txt
D_TESTREF=$(shell cat $(TESTREF) | tr '\n' ' ')
L_EXPLICITTESTREF=$(filter pkg/%, $(D_TESTREF))
L_SYSTESTREF=$(filter-out pkg/%, $(D_TESTREF))

#########################
#Combine Site Test Host #
#########################
DLLREF=$(sort $(D_HOSTREF) $(D_SITEREF) $(D_TESTREF))
SYSDLLREF=$(sort $(L_SYSHOSTREF) $(L_SYSSITEREF $(L_SYSTESTREF))
EXPLICITDLLREF=$(sort $(L_EXPLICITHOSTREF) $(L_EXPLICITSITEREF) $(L_EXPLICITTESTREF))
FILEDLLREF=$(notdir $(EXPLICITDLLREF))
BINDLLREF=$(patsubst %,bin/%, $(FILEDLLREF))

#########################
#      Nuget nupkg      #
#########################
PKG_DIR=$(CURDIR)/pkg
PKG_CONFIG=$(PKG_DIR)/packages.config
L_NUGET=$(strip $(shell sed -n 's|<package id="\([a-zA-Z0-9\.]*\)" version="\([a-zA-Z0-9\.\-]*\)\(.*\)|\1/\2|p' $(PKG_CONFIG) | tr '\n' ' '))
TEMP_NUGET=$(subst /,___,$(L_NUGET))
T_NUGET=$(patsubst %,$(PKG_DIR)/%.nupkg, $(TEMP_NUGET))

APPCONFIG=src/App.config

all: build
	@echo "SOLUTION BUILT!"

build: $(BINFOLDER) $(T_NUGET) $(BINDLLREF) $(SITEDLL) $(HOST) $(TESTDLL)

$(SITEDLL): $(D_SITESRC) $(APPCONFIG) $(T_RES) $(HOST).config
	@echo "BUILDING $(@F)"
	$C $(FLAGS) -out:$(SITEDLL) -t:library $(P_SITEREF) $(P_RES) $(D_SITESRC)

$(TESTDLL): $(D_TESTSRC)
	@echo "BUILDING $(@F)"
	$C $(FLAGS) -out:$(TESTDLL) -t:library $(P_TESTREF) -r:$(SITEDLL) $(D_TESTSRC)

$(HOST): $(D_HOSTSRC)
	@echo "BUILDING $(@F)"
	$C $(FLAGS) -out:$(HOST) $(P_HOSTREF) $(D_HOSTSRC)

$(HOST).config: $(APPCONFIG)
	@echo "COPYING APPCONFIG"
	@cp src/App.config $(HOST).config

$(BINFOLDER):
	@echo "CREATING BIN FOLDER"
	@mkdir -p $(BIN)
	@mkdir -p $(BIN)/res
	@touch $(BINFOLDER)

$(BINDLLREF): $(EXPLICITDLLREF) 
	@echo "COPYING REFERENCED DLLS TO BIN"
	@cp $? bin/

nuget: $(T_NUGET)

$(T_NUGET):
	@echo "DOWNLOADING NUGET: $(@F)"
	@echo $@ | sed 's|$(PKG_DIR)\/\([a-zA-Z0-9.]*\)___\([a-zA-Z0-9.\-]*\).nupkg|http://packages.nuget.org/api/v2/package/\1/\2|' | xargs -I uri wget -nv --unlink --quiet -O $@ uri
	@echo "UNZIPIN NUGET PKG: $(@F)"
	@echo $@ | sed 's|.nupkg||g' | xargs -I dir unzip -u -q -d dir $@ 

$(T_RES): $(D_RESTXT)
	@echo "CONVERTING TXT TO RESOURCE"
	@resgen $< $@ 2>&1 >/dev/null

clean:
	@echo "CLEANING PROJECT"
	@echo "CLEANING PACKAGES FOLDER"
	@find $(PKG_DIR) -type f -name "*.nupkg" | xargs -I nupkg rm nupkg
	@find $(PKG_DIR) -type d -path '$(PKG_DIR)/*' -maxdepth 1 | xargs -I nupkgdir rm -r nupkgdir
	@rm -r bin
	@mkdir -p bin
	
run: build
	@echo "RUNNING SITE"
	@mono --debug bin/host.exe -e $(URL)

test: build
	@echo "TESTING SITE"
	@echo "REPLACE THIS LINE IN MAKE FILE WITH TEST RUNNER"
	@echo "LIKE:"
	@echo "mspec $(TESTDLL)"

complete: test run

config:
	@echo "DLLREF --------------------"
	@echo "$(DLLREF)"
	@echo "EXPLICITDLLREF ------------"
	@echo "$(EXPLICITDLLREF)"
	@echo "FILEDLLREF ----------------"
	@echo "$(FILEDLLREF)"
	@echo "SITE ----------------------"
	@echo "D_SITEREF:         $(D_SITEREF)"
	@echo "L_EXPLICITSITEREF: $(L_EXPLICITSITEREF)"
	@echo "L_SYSSITEREF:      $(L_SYSSITEREF)"
	@echo "T_FILESITEREF:     $(T_FILESITEREF)"
	@echo "T_SITEREF: 		  $(T_SITEREF)"
	@echo "L_FINALSITEREF:    $(L_FINALSITEREF)"
	@echo "P_SITEREF:         $(P_SITEREF)"
	@echo "HOST ----------------------"
	@echo "D_HOSTREF:         $(D_HOSTREF)"
	@echo "L_EXPLICITHOSTREF: $(L_EXPLICITHOSTREF)"
	@echo "L_SYSHOSTREF:      $(L_SYSHOSTREF)"
	@echo "T_FILEHOSTREF:     $(T_FILEHOSTREF)"
	@echo "T_HOSTREF: 		  $(T_HOSTREF)"
	@echo "L_FINALHOSTREF:    $(L_FINALHOSTREF)"
	@echo "P_HOSTREF:         $(P_HOSTREF)"
	@echo "----------------------"
	@echo "SITEREF:           $(SITEREF)"
	@echo "D_SITEREF:         $(D_SITEREF)"
	@echo "T_SITEREF:         $(T_SITEREF)"
	@echo "L_EXPLICITSITEREF: $(L_EXPLICITSITEREF)"
	@echo "L_SYSSITEREF:      $(L_SYSSITEREF)"
	@echo "L_FINALSITEREF:    $(L_FINALSITEREF)"
	@echo "T_FILESITEREF:     $(T_FILESITEREF)"
	@echo "P_SITEREF:         $(P_SITEREF)"
	@echo "L_NUGET:           $(L_NUGET)"
	@echo "TEMP_NUGET:        $(TEMP_NUGET)"
	@echo "T_NUGET:           $(T_NUGET)"
	@echo "PKG_CONFIG:        $(PKG_CONFIG)"
	@echo "T_RES:             $(T_RES)"
	@echo "P_RES:             $(P_RES)"
