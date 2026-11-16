---
title: 레이아웃 모드
description: Sticky 또는 Spaced 데스크톱 레이아웃을 선택하세요.
---
Sticky는 창과 셸 표면을 컴팩트하게 유지합니다. Spaced는 더 큰 간격, 둥근 모서리 및 넓은 작업 표시줄 여백을 사용합니다. 레이아웃 모드는 선택한 테마와 무관하며, 모드를 변경하면 해당 모드의 레이아웃이 다시 적용됩니다.

**Control Center → Appearance → Desktop → Appearance Mode**에서 모드를 선택하거나 `SUPER + Shift + M`를 사용하여 선택기를 열 수 있습니다. 정식 설정은 `/layout/variant`이며, 값은 `sticky` 및 `spaced`입니다. 해결된 Spaced 테마 ID는 `-spaced` 접미사를 사용합니다. 기존 `float` 값과 `-float` ID는 호환성을 위해 그대로 읽을 수 있습니다.

`argvus layout-mode-menu` (SUPER + Shift + M): **Tab / Shift+Tab**: Sticky/Spaced ⇄ Tile/Floating · Taskbar Top/Bottom. ↑/↓로 Sticky 또는 Spaced를 선택합니다. 오른쪽 카드 네 개는 타일 또는 플로팅 창과 작업 표시줄 위 또는 아래를 조합합니다. ↑/↓/←/→는 끝에서 순환하지 않습니다. 클릭으로 선택하고 Enter로 적용, Escape로 취소합니다. 선택하지 않은 모드는 흐리게 표시되며 미리 보기는 현재 테마와 배경을 사용합니다. 대기 상태가 표시되고 실패하면 다시 시도할 수 있습니다.

테마 및 모드 선택기는 세션 시작 화면 없이 자체 창에 진행 상황을 표시합니다. 다시 불러오기 전에 작업 표시줄의 최종 위치를 준비하고 필요한 재시작을 하나의 systemd 트랜잭션으로 묶습니다.
