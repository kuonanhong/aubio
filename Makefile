WAFCMD=python waf

ENABLE_DOUBLE := $(shell [ -z $(HAVE_DOUBLE) ] || echo --enable-double )

all: build

checkwaf:
	@[ -f waf ] || make getwaf

getwaf:
	curl https://waf.io/waf-1.8.20 > waf
	@chmod +x waf

expandwaf:
	@[ -d wafilb ] || rm -fr waflib
	@$(WAFCMD) --help > /dev/null
	@mv .waf*/waflib . && rm -fr .waf*
	@sed '/^#==>$$/,$$d' waf > waf2 && mv waf2 waf
	@chmod +x waf

configure: checkwaf
	$(WAFCMD) configure $(WAFOPTS) $(ENABLE_DOUBLE)

build: configure
	$(WAFCMD) build $(WAFOPTS)

build_python:
	cd python && python ./setup.py generate $(ENABLE_DOUBLE) build

test_python:
	cd python && pip install -v .
	LD_LIBRARY_PATH=$(PWD)/build/src python/tests/run_all_tests --verbose
	cd python && pip uninstall -y -v aubio

test_python_osx:
	cd python && pip install --user -v .
	[ -f build/src/libaubio.[0-9].dylib ] && ( mkdir -p ~/lib && cp -prv build/src/libaubio.4.dylib ~/lib ) || true
	./python/tests/run_all_tests --verbose
	cd python && pip uninstall -y -v aubio

clean_python:
	cd python && ./setup.py clean

build_python3:
	cd python && python3 ./setup.py generate $(ENABLE_DOUBLE) build

clean_python3:
	cd python && python3 ./setup.py clean

clean:
	$(WAFCMD) clean

distcheck: checkwaf
	$(WAFCMD) distcheck

help:
	$(WAFCMD) --help
