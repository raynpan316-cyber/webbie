<p align="center"><img src="docs/logo.svg" width="72" alt="Webbie"></p>

# Webbie

**简体中文** · [English](README.en.md) · [日本語](README.ja.md)

给剪辑创作者用的 macOS 素材下载工作台。一小时的原片只需要一分钟？粘贴链接，选好起止时间，把需要的那一段直接存到 Mac。

[**下载 macOS 版**](https://github.com/raynpan316-cyber/webbie/releases/latest) · [从源码构建](#从源码构建)

![Webbie 工作台，显示时间段、导出格式和下载队列](docs/workspace.png)

## 你可以用它做什么

- 下载完整素材，或指定开始和结束时间。常用的前 30 秒和前 3 分钟可以一键填入。
- 导出 MP4 视频并选择可用的分辨率和视频码率，或导出 MP3 / M4A 音频并选择音频码率。
- 排队下载、重试任务、查看记录，并在访达中定位已导出的文件。
- 在「设置」切换简体中文、英文或日文。下载处理和记录保存在本机。

可尝试解析 YouTube、B 站、TikTok、抖音、小红书等平台的视频链接。实际可用的格式、画质和时间段取决于源站、链接及 yt-dlp 的支持情况。

## 安装

1. 使用搭载 Apple 芯片且运行 macOS 14 或更新版本的 Mac。
2. 安装 [Homebrew](https://brew.sh/)，然后在终端安装下载工具。

   ```bash
   brew install yt-dlp ffmpeg deno
   ```

3. 从 [Releases](https://github.com/raynpan316-cyber/webbie/releases) 下载 `Webbie-macOS-arm64.zip`，解压并将 `Webbie.app` 移到「应用程序」。
4. 发布包使用临时签名，尚未经过 Apple 公证。如果 macOS 拦截首次打开，可在确认文件来自本仓库后，按 [Apple 的说明](https://support.apple.com/zh-cn/102445)在「系统设置 → 隐私与安全性」中允许打开。

## 从源码构建

安装 Xcode 命令行工具（`xcode-select --install`），在仓库目录执行以下命令。生成的应用位于 `build/Webbie.app`，下载功能使用上一步安装的工具。

```bash
./build.sh
```

## 关于

由 [Rayn](https://github.com/raynpan316-cyber) 开发。欢迎在 [Issues](https://github.com/raynpan316-cyber/webbie/issues) 分享反馈，也可以在 [小红书](https://www.xiaohongshu.com/user/profile/5edcdd31000000000101cbdb) 和 [X](https://x.com/raynpann) 关注 Build in Public 更新。

Webbie 源码使用 [MIT 许可证](LICENSE)。[yt-dlp](https://github.com/yt-dlp/yt-dlp)、[FFmpeg](https://ffmpeg.org/) 和 [Deno](https://github.com/denoland/deno) 通过 Homebrew 单独安装，分别适用各自的许可证。
