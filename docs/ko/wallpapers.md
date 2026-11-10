---
title: 배경화면
description: 내장 및 사용자 지정 ARGVUS 배경화면을 사용하세요.
---
`argvus-wallpapers`에 의해 `/usr/share/backgrounds/argvus/` 아래에 내장 JPEG XL 배경화면이 설치됩니다. **제어 센터 → 모양 → 배경화면**에서, 이들은 `Abstract` 또는 `Landscape`로 정리되며, 그 다음 `Dark` 또는 `Light`로 정리됩니다. 루트 `argvus-dark.jxl` 및 `argvus-light.jxl` 파일은 추상 백업 그룹 아래에 나타납니다. 테마 전환은 `abstract/dark` 및 `abstract/light`의 추상 파일만 사용하며, 가로 배경화면 파일은 선택적인 수동 선택입니다. `SUPER + Y`를 눌러 이 제어 센터 화면을 직접 열 수 있습니다. 첫 번째 항목은 HOME에서 사용자 지정 이미지를 받아들일 수도 있으며, 선택된 파일은 사용자의 사용자 지정 배경화면 상태가 됩니다.

첫 번째 항목은 사용자 정의 이미지를 위한 파일 선택기를 엽니다. 선택한 사용자 정의 배경화면은 표준 구성에서 `/appearance/wallpaper`와 `/appearance/wallpaper_custom`와 함께 저장되며, `argvus config`는 이를 세션에서 사용되는 Hyprland 배경화면 구성으로 투사합니다. 이는 테마 또는 모드 변경이 해당 테마의 배경화면을 다시 적용할 때까지 활성 상태로 유지됩니다. 활성 테마를 내보내어 현재 배경화면을 포함하고 내보낸 테마에 저장하십시오. `$XDG_CONFIG_HOME/argvus/.wallpaper-custom`는 이전 마이그레이션 입력 전용입니다.

테마를 내보낼 때, 현재 배경화면 이미지는 읽을 수 있는 경우 포함됩니다. 가져오기는 테마를 설치하며, 적용 시 해당 배경화면을 활성화합니다. 자세한 내용은 [테마 가져오기 및 내보내기](/docs/components/argvus-themes/import-and-export/)]를 참조하십시오.

사용자 인터페이스용 외형 컨트롤은 Hyprland 헬퍼 `hypr-wallpaper-pick.sh`를 사용하며, 자체적으로 배경화면 상태를 저장하는 대신 선택된 경로를 `argvus config`를 통해 커밋합니다. 생성된 배경화면 구성은 직접 편집하지 마십시오.
