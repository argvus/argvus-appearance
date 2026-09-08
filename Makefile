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
	install -dm755 "$(DESTDIR)$(PREFIX)/share/argvus"
	if [ -d config ]; then \
		cp -R --no-preserve=ownership config/. "$(DESTDIR)$(PREFIX)/share/argvus/"; \
		find "$(DESTDIR)$(PREFIX)/share/argvus/hypr/themes" -type f -name 'hyprlock.conf' -delete 2>/dev/null || true; \
		rm -f "$(DESTDIR)$(PREFIX)/share/argvus/hypr/hyprlock.conf"; \
		find "$(DESTDIR)$(PREFIX)/share/argvus/scripts" -type f -name '*.sh' -exec chmod 755 {} \; 2>/dev/null || true; \
	fi

uninstall:
	rm -f "$(DESTDIR)$(PREFIX)/share/argvus/scripts/apps/hypr-wallpaper-pick.sh"
	rm -f "$(DESTDIR)$(PREFIX)/share/argvus/scripts/argvus/accent-switch.sh"
	rm -f "$(DESTDIR)$(PREFIX)/share/argvus/scripts/argvus/brightness-switch.sh"
	rm -f "$(DESTDIR)$(PREFIX)/share/argvus/scripts/argvus/hypr.sh"
	rm -f "$(DESTDIR)$(PREFIX)/share/argvus/scripts/argvus/theme-switch.sh"
	rm -f "$(DESTDIR)$(PREFIX)/share/argvus/scripts/argvus/toggle-mode.sh"
	rm -rf "$(DESTDIR)$(PREFIX)/share/argvus/gtk-3.0"
	rm -rf "$(DESTDIR)$(PREFIX)/share/argvus/gtk-4.0"
	rm -rf "$(DESTDIR)$(PREFIX)/share/argvus/qt6ct"
	rm -f "$(DESTDIR)$(PREFIX)/share/argvus/hypr/application-style.conf"
	rm -f "$(DESTDIR)$(PREFIX)/share/argvus/hypr/hyprpaper.conf"
	rm -f "$(DESTDIR)$(PREFIX)/share/argvus/hypr/hyprtoolkit.conf"
	find "$(DESTDIR)$(PREFIX)/share/argvus/hypr/themes" -type f -name 'hyprlock.conf' -delete 2>/dev/null || true

validate:
	@set -eu; \
	test -d config; \
	scripts=$$(find config -type f -name '*.sh' | sort); \
	if [ -n "$$scripts" ]; then \
		for script in $$scripts; do sh -n "$$script"; done; \
		if command -v shellcheck >/dev/null 2>&1; then \
			for script in $$scripts; do shellcheck -e SC1090 -e SC1091 -e SC2034 "$$script"; done; \
		else \
			echo "shellcheck not found; skipped"; \
		fi; \
	fi; \
	test -f config/hypr/hyprpaper.conf; \
	test -f config/hypr/application-style.conf; \
	test -f config/qt6ct/qt6ct.conf
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