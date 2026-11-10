---
title: 壁紙
description: 組み込みおよびカスタムのARGVUS壁紙を使用してください。
---
内蔵のJPEG XL壁紙は、`argvus-wallpapers`によって`/usr/share/backgrounds/argvus/`の下にインストールされています。**コントロールセンター → 外観 → 壁紙**では、`Abstract`または`Landscape`として整理され、その後`Dark`または`Light`によって分類されます。ルートの`argvus-dark.jxl`および`argvus-light.jxl`ファイルは、抽象フォールバックグループの下に表示されます。テーマの切り替えは`abstract/dark`および`abstract/light`の抽象ファイルのみを使用します。ランドスケープファイルは任意の手動選択です。`SUPER + Y`を押すと、直接このコントロールセンター画面を開くことができます。最初の項目はHOMEからのカスタム画像も受け付け、選択されたファイルはユーザーのカスタム壁紙の状態になります。

最初のエントリはカスタム画像用のファイル選択ダイアログを開きます。選択されたカスタム壁紙は、標準的な設定で`/appearance/wallpaper`と`/appearance/wallpaper_custom`とともに保存され、`argvus config`はそれをセッションで使用されるHyprlandの壁紙設定に反映します。テーマまたはモードの変更がそのテーマの壁紙を再適用するまでは有効です。現在の壁紙を含めるためにアクティブなテーマをエクスポートし、エクスポートされたテーマに保存します。`$XDG_CONFIG_HOME/argvus/.wallpaper-custom`は旧バージョンのマイグレーション入力専用です。

テーマがエクスポートされると、現在の壁紙画像は読み取り可能であれば含まれます。インポートはテーマをインストールし、適用はその壁紙を有効にします。[テーマのインポートとエクスポート](/docs/components/argvus-themes/import-and-export/)]を参照してください。

ユーザー向けの外観コントロールは Hyprland ヘルパー `hypr-wallpaper-pick.sh` を使用しており、壁紙の状態自体を保存するのではなく、選択されたパスを `argvus config` を通じてコミットします。生成された壁紙設定を直接編集しないでください。
