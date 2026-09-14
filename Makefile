PREFIX ?= /usr
DESTDIR ?=

.DEFAULT_GOAL := help

.PHONY: help install uninstall validate release-archive clean

help:
	@echo "Available targets:"
	@echo "  make build"
	@echo "  make install"
	@echo "  make uninstall"
	@echo "  make validate"
	@echo "  make release-archive"

install:
	install -dm755 "$(DESTDIR)$(PREFIX)/share/argvus/appearance"
	cp -R --no-preserve=ownership src/usr/share/argvus/appearance/. "$(DESTDIR)$(PREFIX)/share/argvus/appearance/"
	find "$(DESTDIR)$(PREFIX)/share/argvus/appearance/sh" -type f -name '*.sh' -exec chmod 755 {} \; 2>/dev/null || true

uninstall:
	rm -rf "$(DESTDIR)$(PREFIX)/share/argvus/appearance"

validate:
	@set -eu; \
	test -d src/usr/share/argvus/appearance/config; \
	scripts=$$(find src/usr/share/argvus/appearance/sh -type f -name '*.sh' | sort); \
	if [ -n "$$scripts" ]; then \
		for script in $$scripts; do sh -n "$$script"; done; \
		if command -v shellcheck >/dev/null 2>&1; then \
			for script in $$scripts; do shellcheck -e SC1090 -e SC1091 -e SC2034 "$$script"; done; \
		else \
			echo "shellcheck not found; skipped"; \
		fi; \
	fi; \
	test -f src/usr/share/argvus/appearance/config/hypr/hyprpaper.conf; \
	test -f src/usr/share/argvus/appearance/config/hypr/application-style.conf; \
	test -f src/usr/share/argvus/appearance/config/qt6ct/qt6ct.conf; \
	test -f src/usr/share/argvus/appearance/config/waybar/mode.css
	@echo "argvus-appearance validation ok"

release-archive:
	mkdir -p .release
	git archive --format=tar.gz --prefix="argvus-appearance-$$(git rev-parse --short HEAD)/" \
		--output=".release/argvus-appearance-$$(git rev-parse --short HEAD).tar.gz" HEAD

.PHONY: build

build:
	@tools/build-local-package.sh

clean:
	rm -rf dist
	rm -f packaging/arch/*.zst packaging/arch/*.tar.gz
