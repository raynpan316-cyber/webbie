# <img src="docs/logo.svg" width="28" alt=""> Webbie

[简体中文](README.md) · [English](README.en.md) · **日本語**

> 1 時間の動画。編集に使うのは冒頭の 30 秒だけ。

以前は動画を丸ごとダウンロードして、編集ソフトに入れてから、メモしておいた時間を探していました。この作業を何度も繰り返すうちに、欲しい区間の動画や音声をダウンロードできる Mac アプリ **Webbie** を自分で作りました。

[**macOS 版をダウンロード**](https://github.com/raynpan316-cyber/webbie/releases/latest) · [インストール](#インストール) · [ソースからビルド](#ソースからビルド)

## 冒頭の 30 秒を保存する

1. **リンクを貼る。** 作業画面に動画の URL を貼って「リンクを解析」を押します。
2. **区間を選ぶ。** 「範囲を指定」に切り替え、「最初の30秒」を選びます。途中から切り出すときは、開始時刻と終了時刻を入力します。
3. **Mac に保存する。** MP4 と利用可能な解像度を選び、キューに追加します。完了したら、タスクの横にある **Finder** から保存先を開けます。

![00:00:00 から 00:00:30 までの区間、書き出し形式、ダウンロードキューを表示する Webbie の作業画面](docs/workspace.png)

## 次の編集ではこんな使い方も

- **使いたい発言は 12 分過ぎ。** `00:12:40 → 00:13:10` と入力して、その 30 秒を書き出します。冒頭を長めに取りたいときは、最初の 3 分を選べます。
- **声だけを使いたい。** MP3 または M4A を選び、音声のビットレートを指定します。音声だけでも時間範囲を指定できます。
- **素材がいくつも見つかった。** まとめてキューに追加します。MP4 では解像度とビットレートを選べます。履歴から再試行したり、ファイル全体をダウンロードしたりすることもできます。

YouTube、Bilibili、TikTok、抖音、小紅書などのリンクを読み込めます。利用できる形式や画質、区間指定の可否は、リンク先や yt-dlp の対応状況によって変わります。ダウンロード処理と履歴の保存は Mac 上で行います。設定で簡体字中国語、英語、日本語を切り替えられます。

## インストール

**Apple シリコン搭載の Mac** と **macOS 14 以降**が必要です。

1. [Homebrew](https://brew.sh/) をインストールし、ターミナルで次のコマンドを実行します。

   ```bash
   brew install yt-dlp ffmpeg deno
   ```

2. [Releases](https://github.com/raynpan316-cyber/webbie/releases) から `Webbie-macOS-arm64.zip` をダウンロードします。展開した `Webbie.app` を「アプリケーション」に移動します。
3. リリース版は ad hoc 署名を使用しており、Apple の公証を受けていません。初回起動がブロックされた場合は、入手元を確認し、[Apple の手順](https://support.apple.com/ja-jp/102445)に従って「システム設定 → プライバシーとセキュリティ」で開いてください。

## ソースからビルド

`xcode-select --install` で Xcode Command Line Tools をインストールし、リポジトリのルートで次のコマンドを実行します。

```bash
./build.sh
```

アプリは `build/Webbie.app` に生成され、上記のダウンロード用ツールを使用します。SDK が複数ある場合は、Swift ツールチェーンに対応する SDK を `WEBBIE_SDK_PATH` で指定できます。

## 開発のようす

開発者の [Rayn](https://github.com/raynpan316-cyber) です。Webbie でひと手間減らせたら、⭐ を付けてもらえるとうれしいです。普段どんなふうに素材を集めているか、[Issues](https://github.com/raynpan316-cyber/webbie/issues) でも教えてください。開発の過程や更新は [小紅書](https://www.xiaohongshu.com/user/profile/5edcdd31000000000101cbdb) と [X](https://x.com/raynpann) で公開しています。

Webbie のソースコードは [MIT ライセンス](LICENSE)で公開しています。[yt-dlp](https://github.com/yt-dlp/yt-dlp)、[FFmpeg](https://ffmpeg.org/)、[Deno](https://github.com/denoland/deno) は Homebrew で個別にインストールされ、それぞれ独自のライセンスが適用されます。
