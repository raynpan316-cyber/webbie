<p align="center"><img src="docs/logo.svg" width="72" alt="Webbie"></p>

# Webbie

[简体中文](README.md) · [English](README.en.md) · **日本語**

動画クリエイター向けの macOS 素材ダウンロードツール。1 時間の動画から 1 分だけ使いたいときは、リンクを貼り付け、開始時刻と終了時刻を指定して、その区間を Mac に保存できます。

[**macOS 版をダウンロード**](https://github.com/raynpan316-cyber/webbie/releases/latest)

![時間範囲、書き出し形式、ダウンロードキューを表示する Webbie の作業画面](docs/workspace.png)

## 主な機能

- 動画全体を保存するか、開始・終了時刻を指定します。冒頭 30 秒と 3 分のプリセットもあります。
- MP4 動画の解像度とビットレートを選べます。音声はビットレートを指定して MP3 または M4A で書き出せます。
- ダウンロードをキューに追加して、履歴の確認や再試行ができます。保存済みのファイルは Finder で表示できます。
- 設定から簡体字中国語、英語、日本語に切り替えられます。ダウンロードの処理と履歴の保存は Mac 上で行います。

YouTube、Bilibili、TikTok、抖音、小紅書などの動画リンクを解析できます。利用できる形式、画質、時間範囲はリンク先や yt-dlp の対応状況によって異なります。

## インストール

1. macOS 14 以降を搭載した Apple シリコンの Mac を使用してください。
2. [Homebrew](https://brew.sh/) をインストールし、ターミナルでダウンロード用のツールを追加します。

   ```bash
   brew install yt-dlp ffmpeg deno
   ```

3. [Releases](https://github.com/raynpan316-cyber/webbie/releases) から `Webbie-macOS-arm64.zip` をダウンロードし、展開した `Webbie.app` を「アプリケーション」に移動します。
4. リリース版は ad hoc 署名を使用しており、Apple の公証を受けていません。初回起動がブロックされた場合は、ファイルの入手元を確認し、[Apple の手順](https://support.apple.com/ja-jp/102445)に従って「システム設定 → プライバシーとセキュリティ」で開いてください。

## ソースからビルド

`xcode-select --install` で Xcode Command Line Tools をインストールし、リポジトリのルートで次のコマンドを実行します。アプリは `build/Webbie.app` に生成され、上記のダウンロード用ツールを使用します。

```bash
./build.sh
```

## 開発者

開発は [Rayn](https://github.com/raynpan316-cyber)。フィードバックは [Issues](https://github.com/raynpan316-cyber/webbie/issues) へ。開発の過程や更新情報は [小紅書](https://www.xiaohongshu.com/user/profile/5edcdd31000000000101cbdb) と [X](https://x.com/raynpann) で共有しています。

Webbie のソースコードは [MIT ライセンス](LICENSE)のもとで公開しています。[yt-dlp](https://github.com/yt-dlp/yt-dlp)、[FFmpeg](https://ffmpeg.org/)、[Deno](https://github.com/denoland/deno) は Homebrew で個別にインストールされ、それぞれのライセンスが適用されます。
