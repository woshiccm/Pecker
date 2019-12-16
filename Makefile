PREFIX?=/usr/local

build:
	swift build --disable-sandbox -c release

clean_build:
	rm -rf .build
	make build

portable_zip: build
	rm -rf portable_pecker
	mkdir portable_pecker
	mkdir portable_pecker/bin
	cp -f .build/release/pecker portable_pecker/bin/pecker
	cp -f LICENSE portable_pecker
	cd portable_pecker
	(cd portable_pecker; zip -yr - "bin" "LICENSE") > "./portable_pecker.zip"
	rm -rf portable_pecker

install: build
	mkdir -p "$(PREFIX)/bin"
	cp -f ".build/release/pecker" "$(PREFIX)/bin/pecker"

get_version:
	@cat .version

publish:
	brew update && brew bump-formula-pr --tag=$(shell git describe --tags) --revision=$(shell git rev-parse HEAD) pecker
	COCOAPODS_VALIDATOR_SKIP_XCODEBUILD=1 pod trunk push Pecker.podspec

%:

	@:
