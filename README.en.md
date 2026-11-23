# <img src="docs/logo.svg" width="28" alt=""> Webbie

[简体中文](README.md) · **English** · [日本語](README.ja.md)

> The YouTube interview is an hour long. I need the 30 seconds from 12:40 to 13:10.

I’ve already written down where the quote starts and ends. With a web downloader that only saves full videos, I still have to wait for the whole interview, drop it into my editor, and find the same line again. I end up keeping an hour-long file on disk for a single sound bite.

I built **Webbie**, a Mac download workspace for video creators. Paste the interview link, analyze it, choose **Clip**, and enter the two timecodes to save just those 30 seconds. Export MP4 for the video and sound, or choose MP3 or M4A for the audio alone.

[**Download Webbie for macOS**](https://github.com/raynpan316-cyber/webbie/releases/latest) · [Installation](#install) · [Build from source](#build-from-source)

## Save those 30 seconds from the interview

1. **Paste a link.** Add a video URL to the workspace and click **Analyze link**.
2. **Pick a range.** Choose **Clip**, set the start to `00:12:40`, and set the end to `00:13:10`.
3. **Save it to your Mac.** Choose MP4 and an available resolution, then add it to the queue. When it’s ready, click **Finder** by the job to reveal the file.

![Webbie’s workspace with the 00:00:00 to 00:00:30 range selected, export formats, and the download queue](docs/workspace.png)

*The screenshot shows the **First 30 sec** preset. The same fields take custom start and end times.*

## YouTube downloads by use case

- **YouTube Clip Downloader.** Use **First 30 sec** or **First 3 min** for an intro. Enter your own timecodes to save a shot or a line of dialogue from the middle.
- **YouTube Video Downloader.** Choose **Full media**, then pick an available resolution and video bitrate. Queue multiple sources and retry failed jobs from history.
- **YouTube MP4 Download / YouTube MP3 Download.** Save video as MP4 or extract audio as MP3 or M4A at your chosen bitrate. Set start and end times when you only need part of the audio.

Webbie can try links from YouTube, Bilibili, TikTok, Douyin, Xiaohongshu, and other sites. Available formats, quality, and clip downloads depend on the source, the specific link, and yt-dlp support. Downloads and history stay on your Mac. Settings offers Simplified Chinese, English, and Japanese.

Looking for an interview quote, B-roll, or original audio, or troubleshooting a download on your Mac? [Browse video download use cases and common questions](docs/video-download-use-cases.md)

## Install

Requires an **Apple silicon Mac** running **macOS 14 or later**. Starting with v1.5.3, the GitHub download includes the tools it needs. You can run Webbie without installing Homebrew.

1. Download `Webbie-macOS-arm64.zip` from the [latest release](https://github.com/raynpan316-cyber/webbie/releases/latest). Unzip it and move `Webbie.app` to Applications.
2. In Finder, open Applications and double-click Webbie.

### If macOS blocks Webbie the first time

This release uses an ad hoc signature and hasn’t been notarized by Apple. Make sure your copy came from this repository’s [GitHub Releases](https://github.com/raynpan316-cyber/webbie/releases) before following these steps.

1. Click **Done** in the alert.
2. Go to **System Settings → Privacy & Security** and scroll down to **Security**. Find Webbie and click **Open Anyway**.
3. Click **Open** in the next dialog. macOS remembers the exception, so you can double-click Webbie the next time.

If **Open Anyway** is missing, double-click `Webbie.app` in Finder again, then return to System Settings right away. [Apple Support](https://support.apple.com/en-us/102445)

## Build from source

Install the Xcode Command Line Tools with `xcode-select --install` and run the command below from the repo root.

```bash
./build.sh
```

You’ll find the app at `build/Webbie.app`. For a development build, install external tools with `brew install yt-dlp ffmpeg deno`. See [bundled runtime instructions](docs/runtime.md) to build a self-contained release. If you have several SDKs, use `WEBBIE_SDK_PATH` to select the one that matches your Swift toolchain.

## Follow along

I’m [Rayn](https://github.com/raynpan316-cyber). If Webbie saves you a step, a ⭐ is always welcome. I’d also love to hear how you collect footage in [Issues](https://github.com/raynpan316-cyber/webbie/issues). I share the build and updates on [Xiaohongshu](https://www.xiaohongshu.com/user/profile/5edcdd31000000000101cbdb) and [X](https://x.com/raynpann).

Webbie’s source uses the [MIT license](LICENSE). The separate bundled tools retain their own licenses. [Third-party tools and source code](docs/runtime.md)
