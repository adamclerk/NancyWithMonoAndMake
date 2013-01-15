C=dmcs
SUBDIR=models helpers modules host
BIN=$(CURDIR)/src/bin/
HOST=$(CURDIR)/src/bin/host.exe
BIN_HOLDER=$(CURDIR)/src/bin/holder.keep
NUGET_HOLDER=$(CURDIR)/src/bin/nuget.keep
ALL_SRC=$(shell find src -type f -name '*.cs')
BUILDTYPE=DEBUG

all: build
	@echo "SOLUTION BUILT!"

build: $(BIN_HOLDER) $(NUGET_HOLDER) $(HOST) $(ALL_SRC)

$(HOST): $(ALL_SRC)
	@echo "BUILDING $(@F)"
	@$C -out:$(HOST) -lib:./src/bin -d:$(BUILDTYPE) -r:nancy.dll,nancy.hosting.self.dll $(ALL_SRC)

$(BIN_HOLDER):
	@echo "CREATING BIN FOLDER"
	@mkdir -p src/bin
	@touch $(BIN_HOLDER)

$(NUGET_HOLDER):
	@echo "RETRIEVING NUGET PACKAGES" 
	@nuget install ./src/Packages/packages.config -OutputDirectory ./src/Packages > /dev/null
	@cp ./src/Packages/Nancy.0.15.1/lib/net40/Nancy.dll ./src/bin
	@cp ./src/Packages/Nancy.Hosting.Self.0.15.1/lib/net40/Nancy.Hosting.Self.dll ./src/bin
	@cp ./src/Packages/Nancy.ViewEngines.Razor.0.15.1/lib/net40/Nancy.ViewEngines.Razor.dll ./src/bin
	@cp ./src/Packages/Nancy.ViewEngines.Razor.0.15.1/lib/net40/System.Web.Razor.dll ./src/bin
	@touch $(NUGET_HOLDER)
	
.PHONY: clean

clean:
	@echo "CLEANING PROJECT"
	@rm -r src/bin
	@mkdir -p src/bin
	
run: build
	@echo "RUNNING SITE"
	@mono ./src/bin/host.exe
