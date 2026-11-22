<p align="center"><img src="docs/logo.svg" width="72" alt="Webbie"></p>

# Webbie

[简体中文](README.md) · **English** · [日本語](README.ja.md)

A macOS download workspace for video creators. Need one minute from an hour-long video? Paste the link, set the start and end times, and save just that clip to your Mac.

[**Download for macOS**](https://github.com/raynpan316-cyber/webbie/releases/latest) · [Build from source](#build-from-source)

![The Webbie workspace with clip times, export settings, and the download queue](docs/workspace.png)

## What you can do

- Download a full video or set a clip range. Use the first 30 seconds or first 3 minutes as a preset.
- Export MP4 with your choice of available resolution and video bitrate, or extract audio as MP3 or M4A at a selected bitrate.
- Queue downloads, retry jobs, browse your history, and reveal exported files in Finder.
- Switch between Simplified Chinese, English, and Japanese in Settings. Downloads are processed and tracked locally.

Webbie can attempt to parse media links from YouTube, Bilibili, TikTok, Douyin, Xiaohongshu, and more. Available formats, quality options, and clip ranges depend on the source, the link, and yt-dlp support.

## Install

1. Use a Mac with Apple silicon and macOS 14 or later.
2. Install [Homebrew](https://brew.sh/), then install the download tools in Terminal.

   ```bash
   brew install yt-dlp ffmpeg deno
   ```

3. Download `Webbie-macOS-arm64.zip` from [Releases](https://github.com/raynpan316-cyber/webbie/releases), unzip it, and move `Webbie.app` to Applications.
4. The release is ad hoc signed and has yet to be notarized by Apple. If macOS blocks it on first launch, verify that it came from this repository and follow [Apple’s instructions](https://support.apple.com/en-us/102445) in System Settings → Privacy & Security.

## Build from source

Install the Xcode Command Line Tools with `xcode-select --install`, then run the command below from the repository root. The app builds to `build/Webbie.app` and uses the download tools installed above.

```bash
./build.sh
```

## About

Built by [Rayn](https://github.com/raynpan316-cyber). Share feedback in [Issues](https://github.com/raynpan316-cyber/webbie/issues) or follow my build-in-public updates on [Xiaohongshu](https://www.xiaohongshu.com/user/profile/5edcdd31000000000101cbdb) and [X](https://x.com/raynpann).

Webbie’s source is available under the [MIT license](LICENSE). [yt-dlp](https://github.com/yt-dlp/yt-dlp), [FFmpeg](https://ffmpeg.org/), and [Deno](https://github.com/denoland/deno) are installed separately through Homebrew and carry their own licenses.
