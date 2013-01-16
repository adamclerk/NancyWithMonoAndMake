C=dmcs
SUBDIR=models helpers modules host
BIN=$(CURDIR)/src/bin/
HOST=$(CURDIR)/src/bin/host.exe
BIN_HOLDER=$(CURDIR)/src/bin/holder.keep
NUGET_HOLDER=$(CURDIR)/src/bin/nuget.keep
ALL_SRC=$(shell find src -type f -name '*.cs')
BUILDTYPE=DEBUG
DLSED1=sed -n 's|<package id="\([a-zA-Z0-9.]*\)" version="\([a-zA-Z0-9\.]*\)\(.*\)|
DLSED2=http://packages.nuget.org/api/v2/package/\1/\2|p' ./src/Packages/packages.config 
DLXARG=|xargs -I {} wget -nv -N -P ./src/Packages --trust-server-name {}
UZFIND=find ./src/Packages -type f -name "*.nupkg" 
UZSED1=| sed 's/.nupkg//g'
UZSED2=| sed 's/.\/src\/Packages\///g'
UZXARG=| xargs -I fname unzip -u -q -d ./src/Packages/fname ./src/Packages/fname.nupkg

all: build
	@echo "SOLUTION BUILT!"

build: $(BIN_HOLDER) $(NUGET_HOLDER) $(HOST) $(ALL_SRC)

$(HOST): $(ALL_SRC)
	@echo "BUILDING $(@F)"
	@$C -out:$(HOST) -lib:./src/bin -d:$(BUILDTYPE) -r:Nancy.dll,Nancy.Hosting.Self.dll $(ALL_SRC)

$(BIN_HOLDER):
	@echo "CREATING BIN FOLDER"
	@mkdir -p src/bin
	@touch $(BIN_HOLDER)

nuget: $(NUGET_HOLDER)

$(NUGET_HOLDER):
	@echo "RETRIEVING NUGET PACKAGES"
	@$(DLSED1)$(DLSED2)$(DLXARG)
	@echo "UNZIPING NUGET PACKAGES"
	@$(UZFIND)$(UZSED1)$(UZSED2)$(UZXARG)
	@cp ./src/Packages/Nancy.0.15.1/lib/net40/Nancy.dll ./src/bin
	@cp ./src/Packages/Nancy.Hosting.Self.0.15.1/lib/net40/Nancy.Hosting.Self.dll ./src/bin
	@touch $(NUGET_HOLDER)

clean:
	@echo "CLEANING PROJECT"
	@echo "CLEANING PACKAGES FOLDER"
	@find ./src/Packages -type f -name "*.nupkg" | xargs -I nupkg rm nupkg
	@find ./src/Packages -type d -path './src/Packages/*' -maxdepth 1 | xargs -I nupkgdir rm -r nupkgdir
	@rm -r src/bin
	@mkdir -p src/bin
	
run: build
	@echo "RUNNING SITE"
	@mono ./src/bin/host.exe
