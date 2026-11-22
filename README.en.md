# <img src="docs/logo.svg" width="28" alt=""> Webbie

[简体中文](README.md) · **English** · [日本語](README.ja.md)

> The video is an hour long. I need the first 30 seconds for my edit.

I used to download the whole thing, drop it into my editor, and find the timecode I’d already written down. After doing that enough times, I built **Webbie**, a Mac app for downloading video and audio by time range.

[**Download Webbie for macOS**](https://github.com/raynpan316-cyber/webbie/releases/latest) · [Installation](#install) · [Build from source](#build-from-source)

## Save the first 30 seconds

1. **Paste a link.** Add a video URL to the workspace and click **Analyze link**.
2. **Pick a range.** Choose **Clip** and click **First 30 sec**. For a clip from the middle, enter your own start and end times.
3. **Save it to your Mac.** Choose MP4 and an available resolution, then add it to the queue. When it’s ready, click **Finder** by the job to reveal the file.

![Webbie’s workspace with the 00:00:00 to 00:00:30 range selected, export formats, and the download queue](docs/workspace.png)

## YouTube downloads by use case

- **YouTube Clip Downloader.** Set `00:12:40 → 00:13:10` to save a 30-second sound bite, or use the first-three-minutes preset to grab an intro.
- **YouTube Video Downloader.** Choose **Full media**, then pick an available resolution and video bitrate. Queue multiple sources and retry failed jobs from history.
- **YouTube MP4 Download / YouTube MP3 Download.** Save video as MP4 or extract audio as MP3 or M4A at your chosen bitrate. Set start and end times when you only need part of the audio.

Webbie can try links from YouTube, Bilibili, TikTok, Douyin, Xiaohongshu, and other sites. Available formats, quality, and clip downloads depend on the source, the specific link, and yt-dlp support. Downloads and history stay on your Mac. Settings offers Simplified Chinese, English, and Japanese.

## Install

Requires an **Apple silicon Mac** running **macOS 14 or later**.

1. Install [Homebrew](https://brew.sh/) and run the command below in Terminal.

   ```bash
   brew install yt-dlp ffmpeg deno
   ```

2. Download `Webbie-macOS-arm64.zip` from [Releases](https://github.com/raynpan316-cyber/webbie/releases). Unzip it and move `Webbie.app` to Applications.
3. In Finder, open Applications and double-click Webbie.

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

You’ll find the app at `build/Webbie.app`. It uses the download tools installed above. If you have several SDKs, use `WEBBIE_SDK_PATH` to select the one that matches your Swift toolchain.

## Follow along

I’m [Rayn](https://github.com/raynpan316-cyber). If Webbie saves you a step, a ⭐ is always welcome. I’d also love to hear how you collect footage in [Issues](https://github.com/raynpan316-cyber/webbie/issues). I share the build and updates on [Xiaohongshu](https://www.xiaohongshu.com/user/profile/5edcdd31000000000101cbdb) and [X](https://x.com/raynpann).

Webbie’s source uses the [MIT license](LICENSE). [yt-dlp](https://github.com/yt-dlp/yt-dlp), [FFmpeg](https://ffmpeg.org/), and [Deno](https://github.com/denoland/deno) are installed separately through Homebrew and have their own licenses.
