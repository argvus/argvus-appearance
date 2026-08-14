PREFIX ?= /usr
DESTDIR ?=

.DEFAULT_GOAL := help

.PHONY: help install uninstall release-archive

help:
	@echo "Available targets:"
	@echo "  make install"
	@echo "  make uninstall"
	@echo "  make release-archive"

install:
	install -dm755 "$(DESTDIR)$(PREFIX)/share/backgrounds/argvus"
	install -dm755 "$(DESTDIR)$(PREFIX)/share/fonts"
	cp -a usr/share/backgrounds/argvus/. "$(DESTDIR)$(PREFIX)/share/backgrounds/argvus/"
	cp -a usr/share/fonts/. "$(DESTDIR)$(PREFIX)/share/fonts/"
	@if command -v fc-cache >/dev/null 2>&1; then fc-cache -f "$(DESTDIR)$(PREFIX)/share/fonts" || true; fi

uninstall:
	rm -rf "$(DESTDIR)$(PREFIX)/share/backgrounds/argvus"
	rm -f "$(DESTDIR)$(PREFIX)/share/fonts"/Font\ Awesome\ 7\ Brands-Regular-400.otf
	rm -f "$(DESTDIR)$(PREFIX)/share/fonts"/Font\ Awesome\ 7\ Free-Regular-400.otf
	rm -f "$(DESTDIR)$(PREFIX)/share/fonts"/Font\ Awesome\ 7\ Free-Solid-900.otf
	rm -f "$(DESTDIR)$(PREFIX)/share/fonts"/TerminusTTF-Bold-Italic.ttf
	rm -f "$(DESTDIR)$(PREFIX)/share/fonts"/TerminusTTF-Bold.ttf
	rm -f "$(DESTDIR)$(PREFIX)/share/fonts"/TerminusTTF-Italic.ttf
	rm -f "$(DESTDIR)$(PREFIX)/share/fonts"/TerminusTTF.ttf
	@if command -v fc-cache >/dev/null 2>&1; then fc-cache -f "$(DESTDIR)$(PREFIX)/share/fonts" || true; fi

release-archive:
	mkdir -p .release
	git archive --format=tar.gz --prefix="argvus-appearance-$$(git rev-parse --short HEAD)/" \
		--output=".release/argvus-appearance-$$(git rev-parse --short HEAD).tar.gz" HEAD
