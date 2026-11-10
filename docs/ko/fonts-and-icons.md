---
title: 폰트와 아이콘
description: ARGVUS에서 사용하는 글꼴과 아이콘 테마를 구성하십시오.
---
`argvus-fonts`는 번들 폰트를 `/usr/share/fonts/` 아래에 설치합니다; `argvus-icons`는 ARGVUS 아이콘 테마를 설치합니다. `argvus-appearance`와 제어 센터는 이러한 자산을 데스크톱 테마에 연결합니다.

## 기본 폰트

ARGVUS 기본 기본 폰트는 **IBM Plex Mono**이며, `Regular` 스타일을 사용합니다. 이는 제어 센터에서 노출되는 폰트 대상에 사용되는 기본 글꼴 계열입니다. 번들된 `argvus-fonts` 패키지는 IBM Plex Mono와 데스크톱에서 사용하는 지원 아이콘/터미널 글꼴 계열을 제공합니다.

개별 대상을 설정하려면 **제어 센터 → 폰트**를 엽니다:

- 작업 표시줄;
- 텔레메트리/시스템 정보;
- 제어판;
- ARGVUS 시스템 인터페이스;
- 애플리케이션;
- 터미널;
- 브라우저.

기본 크기는 대상마다 다릅니다: 작업 표시줄, 시스템 및 터미널은 `13`를 사용; 텔레메트리 및 제어판은 `14`를 사용; 애플리케이션은 `12`를 사용; 브라우저는 `10`를 사용합니다. 이러한 기본값은 폰트 페이지에서 복원할 수 있습니다.

## 아이콘 테마

활성 아이콘 테마는 config.json에서 정규적으로 `appearance.icon_theme`로 저장됩니다. 빈 값(기본값)은 활성 테마 모드의 ARGVUS 아이콘 테마를 선택합니다: 어두운 테마의 경우  `config.json` `Argvus Dark Icons`, 밝은 테마의 경우 `Argvus Light Icons`, 둘 다 `argvus-icons`에 의해 설치됩니다.

`sh/icon-switch.sh`는 실제 테마를 확인하고 모든 사용자에게 적용합니다:

- GNOME 설정: `org.gnome.desktop.interface icon-theme`;
- GTK 3 및 GTK 4: ARGVUS 및 네이티브 settings.ini 파일의 `gtk-icon-theme-name`;
- Qt: 관리되는 `settings.ini`에서 `icon_theme`, 및 ARGVUS에 의해 생성된 경우 네이티브 `qt6ct.conf`에서 `qt6ct.conf`.

테마는 `/usr/share/icons`, `$XDG_DATA_HOME/icons` 및 `~/.icons`에서 조회됩니다. 설치되지 않은 구성된 테마나 `/`를 포함하거나 `..`인 값은 동일 모드 기본값으로 되돌아가며 메시지를 기록하므로, 데스크톱이 누락된 테마를 가리키는 일이 없습니다. 테마 또는 모드 전환은 가져온 테마 프로필에 아이콘 선택이 있는 경우 이를 사용하고, 그렇지 않으면 패키지된 모드 기본값을 복원합니다. 테마를 내보내면 전환 시에도 사용자 지정 아이콘 선택을 유지할 수 있습니다.

제어 센터에서 글꼴 컨트롤을 사용하십시오. 글꼴 기본 설정은 `config.json`에서 표준이며, `fonts.targets.<target>`에서는 글꼴 패밀리, 스타일 및 크기, `fonts.rendering`에서는 안티앨리어싱, 힌팅, 서브픽셀 순서 및 DPI를 설정할 수 있습니다. 제어 센터는 이를 `argvus-config`를 통해 유지하며, 자체적으로 소비자 파일을 작성하지 않습니다. 그런 다음 `argvus-config`가 `data/generated/fonts.conf`를 투사하고 `data/waybar/argvus-taskbar.css`와 `data/waybar/argvus-widget-telemetry.css` 내의 구분된 글꼴 블록을 다시 작성하여, 해당 블록 밖에서의 글꼴 편집이 글꼴 변경 후에도 유지되도록 합니다. 터미널과 GTK 글꼴 구성 규칙은 원래의 어댑터 대상로 유지됩니다. 패키지는 설치 중에 글꼴 캐시 업데이트를 실행합니다.

작업 표시줄 모듈 생성은 게시하기 전에 결과 JSONC를 검증합니다. 유틸리티 모듈 목록은 활성화된 환경 설정에서 다시 빌드되며, 오버 모드에서만 표시되는 서랍 확장기가 포함됩니다. 작업 공간 아이콘 모드는 `{windows}`와 `{name}`를 함께 렌더링합니다. 시스템 트레이 가시성은 백그라운드 애플리케이션 아이콘에만 영향을 줍니다.

유틸리티 그룹 프로젝터는 선택적 모듈에서 활성화되고 작업 표시줄 템플릿에 정의된 경우 custom/ai를 유지합니다. 그 nf-md-robot 글리프(U+F06A9)는 공유 AI 에이전트 메뉴를 열며, 다른 모든 유틸리티 아이콘이 비활성화된 경우에도 모듈에 의해 가용성이 유지됩니다.

AI 아이콘 가시성은 /taskbar/icons/ai_agents_enabled(기본값 true)에 의해 제어되며, 제어 센터 > 외관 > 작업 표시줄 > 아이콘 > 선택적 모듈 > AI 에이전트에서 확인할 수 있습니다. 프로젝터는 모든 적용 시 비활성 상태를 존중하며, AI 에이전트만 활성화된 경우 유틸리티 그룹을 유지합니다.

작업 표시줄 프로젝터는 `/taskbar/icons/update_status_enabled`가 true일 때 업데이트 상태를 유틸리티와 네트워크/성능 그룹 사이의 별도 그룹에 배치합니다. 또한, 이전에 생성된 구성들을 모듈 정의와 함께 업그레이드합니다.

헬퍼는 `argvus window-mode-menu`입니다; `argvus window-mode-menu --status`는 Waybar JSON을 출력합니다. 이는 마스터 `argvus` 패키지에 의해 제공됩니다. 기존에 사용자 정의된 작업 표시줄 복사본은 유지됩니다: 패키지된 템플릿에서 `custom/window-mode` 모듈 정의와 그룹 항목을 추가하여 옵트인하거나 제어 센터를 사용하십시오. 외형 프로젝터는 정의가 존재할 경우, 다른 유틸리티 아이콘이 비활성화되더라도 모듈을 유지합니다.

`window-bar` 및 `window-controls` 테마 소비자는 색상을 bg, fg 및 accent에서 가져옵니다. 제목 표시줄 색상은 `argvus windows decorations`를 통해 다시 로드되며, 창 표시줄은 생성된 스타일시트를 관찰합니다. 타일/플로팅은 스티키/스페이스드 외형 지오메트리와 독립적입니다.
