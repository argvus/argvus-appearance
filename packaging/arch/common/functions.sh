#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2154
# srcdir, pkgdir, pkgname, and pkgver are supplied by makepkg.

arch_normalize_source_tree() {
	local expected="${srcdir}/${pkgname}-${pkgver}"
	local -a roots=()

	while IFS= read -r -d '' root; do
		roots+=("$root")
	done < <(find "$srcdir" -mindepth 1 -maxdepth 1 -type d -print0)

	if (( ${#roots[@]} != 1 )); then
		printf 'error: expected exactly one extracted source directory in %s\n' "$srcdir" >&2
		return 1
	fi

	if [[ "${roots[0]}" != "$expected" ]]; then
		[[ ! -e "$expected" ]] || {
			printf 'error: source destination already exists: %s\n' "$expected" >&2
			return 1
		}
		mv -- "${roots[0]}" "$expected"
	fi
}

arch_check_appearance_payload() {
	local source_root="${srcdir}/${pkgname}-${pkgver}"

	test -d "${source_root}/src/usr/share/argvus/appearance/config"
	test -f "${source_root}/src/usr/share/argvus/appearance/config/hypr/hyprpaper.conf"
	test -f "${source_root}/src/usr/share/argvus/appearance/config/qt6ct/qt6ct.conf"
	while IFS= read -r -d '' script; do
		bash -n "$script"
	done < <(find "${source_root}/src/usr/share/argvus/appearance/sh" -type f -name '*.sh' -print0)
}

arch_package_appearance_payload() {
	local source_root="${srcdir}/${pkgname}-${pkgver}"

	install -dm755 "${pkgdir}/usr/share/argvus/appearance"
	cp -R --no-preserve=ownership \
		"${source_root}/src/usr/share/argvus/appearance/." \
		"${pkgdir}/usr/share/argvus/appearance/"
	find "${pkgdir}/usr/share/argvus/appearance/sh" -type f -name '*.sh' \
		-exec chmod 755 {} \;
	install -Dm644 "${source_root}/LICENSE" \
		"${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}
