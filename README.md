# <img src="docs/logo.svg" width="28" alt=""> Webbie

**简体中文** · [English](README.en.md) · [日本語](README.ja.md)

> 一小时的 YouTube 访谈，我只想下载 12:40 到 13:10 的那 30 秒。

剪片找素材时，我明明已经记好了那句对白的时间码。可遇到只支持整条下载的网页版工具，还是得等一小时的视频下完，再拖进剪辑软件，把那句话重新找一遍。最后只用一句，整条原片却已经占了硬盘。

我做了 **Webbie**，一个给剪辑创作者用的 Mac 素材下载工作台。贴上访谈链接，解析后选「指定片段」，填好起止时间，就能把这 30 秒单独存下来。要画面和声音就导出 MP4，只要这句的声音就导出 MP3 或 M4A。

[**下载 Webbie for macOS**](https://github.com/raynpan316-cyber/webbie/releases/latest) · [安装指南](#安装) · [从源码构建](#从源码构建)

## 把访谈里的这 30 秒存下来

1. **贴链接。** 把视频链接粘到工作台，点击「解析链接」。
2. **圈出要的部分。** 选「指定片段」，开始填 `00:12:40`，结束填 `00:13:10`。
3. **存到 Mac。** 选 MP4 和可用画质，加入下载队列。完成后，点任务旁的 **Finder** 就能找到成品。

![Webbie 工作台中选中 00:00:00 到 00:00:30，并显示 MP4、音频格式和下载任务](docs/workspace.png)

*截图演示的是「前 30 秒」预设，同一个面板也可以手动输入中间片段的起止时间。*

## YouTube 下载场景

- **YouTube Clip Downloader（按时间段下载 YouTube 片段）** · 要留节目开场，可以直接用「前 30 秒」或「前 3 分钟」预设。要取中段的画面或台词，输入自己的起止时间。
- **YouTube Video Downloader（下载完整 YouTube 视频）** · 选「完整素材」和可用的分辨率、视频码率。多个素材可以加入同一个队列，失败的任务能从下载记录重试。
- **YouTube MP4 Download / YouTube MP3 Download** · 下载 MP4 视频，或提取 MP3、M4A 音频并选择音频码率。只要一段对白时，音频也可以按起止时间导出。

Webbie 可尝试解析 YouTube、B 站、TikTok、抖音、小红书等平台的链接。实际可用的画质、格式和片段下载能力随源站与具体链接而变，也受 yt-dlp 支持情况影响。下载和记录都在 Mac 上处理，界面可在「设置」中切换简体中文、英文和日文。

想找访谈金句、B-roll、视频原声，或者排查 Mac 上的下载问题？[查看素材下载场景和常见问法](docs/video-download-use-cases.md)

## 安装

需要 **Apple 芯片的 Mac** 和 **macOS 14 或更新版本**。v1.5.3 起，GitHub 安装包自带下载组件，解压后可直接使用，无需安装 Homebrew。

1. 从 [Releases](https://github.com/raynpan316-cyber/webbie/releases/latest) 下载 `Webbie-macOS-arm64.zip`。解压后，把 `Webbie.app` 移到「应用程序」。
2. 在访达的「应用程序」文件夹里双击 Webbie。

### 首次打开时提示「未打开 Webbie」

发布包使用 ad hoc 签名，尚未经过 Apple 公证。确认这份 `Webbie.app` 来自本仓库的 [GitHub Releases](https://github.com/raynpan316-cyber/webbie/releases) 后，可以这样打开。

1. 在弹窗左下角点 **「完成」**。
2. 打开 **系统设置 → 隐私与安全性**，往下滚到 **「安全性」**，找到 Webbie，点 **「仍要打开」**。
3. 在下一次弹窗点 **「打开」**。macOS 会记住这次放行，以后可以直接双击。

如果没看到「仍要打开」，回访达再双击一次 `Webbie.app`，然后马上回到设置查看。[Apple 官方说明](https://support.apple.com/zh-cn/102445)

## 从源码构建

用 `xcode-select --install` 安装 Xcode 命令行工具，再到仓库根目录运行下面的命令。

```bash
./build.sh
```

应用生成在 `build/Webbie.app`。开发构建可以用 `brew install yt-dlp ffmpeg deno` 安装外部组件。要构建自带组件的发布包，见 [运行时打包说明](docs/runtime.md)。如果装了多个 SDK，可用 `WEBBIE_SDK_PATH` 指定和 Swift 工具链匹配的 SDK。

## Build in Public

我是 [Rayn](https://github.com/raynpan316-cyber)。如果 Webbie 帮你少做了一道工序，欢迎点个 ⭐。你也可以在 [Issues](https://github.com/raynpan316-cyber/webbie/issues) 说说你平时怎样找素材。开发过程和更新会发在 [小红书](https://www.xiaohongshu.com/user/profile/5edcdd31000000000101cbdb) 和 [X](https://x.com/raynpann)。

Webbie 源码采用 [MIT 许可证](LICENSE)。发布包中的独立下载工具按各自许可证分发。[第三方组件与源码](docs/runtime.md)
