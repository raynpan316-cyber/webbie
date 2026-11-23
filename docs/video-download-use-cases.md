# 视频素材下载场景与常见问题

[Webbie 简体中文](../README.md) · [English](../README.en.md) · [日本語](../README.ja.md) · [下载 macOS 版](https://github.com/raynpan316-cyber/webbie/releases/latest)

**Webbie** 是给剪辑创作者用的开源 Mac 视频素材下载工作台。解析一个视频链接后，可以选择下载整条，或用起止时间只保存需要的片段。视频导出 MP4，音频导出 MP3 或 M4A。下列问题从实际选素材、下载和导入时间线的任务出发。格式、画质和片段下载能力以具体链接的解析结果为准。

**Webbie** is an open-source macOS video and audio downloader for editors. Choose a time range or save the full video, with MP4 video and MP3 or M4A audio exports. Available formats and clip support depend on the source link.

**Webbie** は動画編集者向けのオープンソース Mac アプリです。動画全体や指定した区間を保存でき、動画は MP4、音声は MP3 または M4A で書き出せます。利用できる画質や区間指定の可否はリンク先によって異なります。

[时间码和预设](#按时间码下载一段) · [采访和 B-roll](#访谈播客和课程) · [画质与音频](#mp4-画质与视频码率) · [平台链接](#youtube-shorts-和完整视频) · [Mac 安装](#mac-安装与运行环境) · [下载故障](#解析或下载失败)

## 按时间码下载一段

一小时的访谈只用 30 秒时，先贴链接并解析，再选「指定片段」，开始填 `00:12:40`，结束填 `00:13:10`。选择 MP4 后加入队列。对于支持片段下载的链接，成品是设定的这一段。实际网络读取范围会随源站与媒体协议变化。

Choose **Clip** and enter separate start and end times. 「範囲を指定」で開始・終了時刻を入力します。

- YouTube 下载指定时间段
- Mac 怎么只下载 YouTube 视频从 12:40 到 13:10 这一段
- 有没有工具从网页视频链接直接保存区间素材
- YouTube Clip Downloader for Mac
- download part of a YouTube video by timestamp
- I have the in and out timecodes for a YouTube video. How can I save only that range as a local file?
- YouTube 動画の指定区間だけダウンロード Mac
- YouTube の途中 30 秒だけを MP4 で保存する方法
- 開始と終了の時刻を入れて動画素材を取り出せるアプリは？

## 只保存片头或靠后的镜头

需要固定长度的片头时，用「前 30 秒」或「前 3 分钟」预设。要留前一分钟，可以从 `00:00:00` 到 `00:01:00` 手动填入。要取结尾的某个镜头，先确认视频时长，再输入有效的开始和结束时间。

Use **First 30 sec**, **First 3 min**, or enter a custom range. 冒頭はプリセット、終盤は時刻を指定して保存します。

- YouTube 视频只下载开头一分钟
- 在线视频截取片头前 30 秒并保存到 Mac
- 只想留视频最后 20 秒，怎么按时间段导出
- save the first minute of a YouTube video as MP4
- get the first three minutes of an online video on Mac
- Can I grab the outro of a video if I know the exact timestamp?
- YouTube 動画の冒頭 30 秒だけ保存
- 動画の最初の 3 分をダウンロードする Mac アプリ
- 動画の最後のシーンだけファイルにしたい

## 访谈播客和课程

记下需要的发言或动作的起止时间，解析原视频后保存对应段落。要保留访谈的反应画面选 MP4，要把一句引言放进配音时间线选 MP3 或 M4A。音频导出取自素材的音轨。

Export an interview excerpt as video, or save the source audio for a quote. インタビューや講義の発言を、映像付きまたは音声だけで保存できます。

- 视频剪辑怎么扒 YouTube 访谈里的金句
- 播客视频只提取嘉宾回答音频 Mac
- 从一小时的教程视频里保存某一个操作步骤
- save an interview sound bite for a video edit
- extract one speaker’s answer from a YouTube podcast episode
- How do I download just the part of a lecture where the instructor shows one example?
- YouTube インタビューの発言部分だけを素材にする
- ポッドキャスト動画から引用したい一言を音声で保存
- 長い講義動画の実演パートだけ取り出す方法

## B-roll 和剪辑素材

先确定镜头要用多长，再把可解析的视频导出为指定区间的 MP4。下载完成后，点任务旁的 Finder 定位文件。剪辑软件的导入能力随版本、编码和工程设置变化。

Save a short B-roll shot as MP4 and reveal the exported file in Finder. B ロールに使う短いカットを MP4 で保存して Finder で開けます。

- 剪 vlog 怎么从长视频下载十秒天空镜头
- Mac 剪辑找 B-roll 素材怎么下载一小段
- 从 YouTube 拿一段素材导入剪映 Mac
- download a short B-roll shot for Final Cut Pro
- save a video excerpt to import into DaVinci Resolve
- I need one product shot from a YouTube review for my edit. How do I download only that shot?
- YouTube から B ロール用のカットだけ保存する方法
- Final Cut Pro に入れる動画素材を Mac で MP4 保存
- 旅行動画の風景シーンだけ取り出して編集に使いたい

## MP4 画质与视频码率

选择 MP4 保存画面和声音。解析完成后，使用列表里可选的分辨率，也可以设定视频码率。可选画质取决于源视频和可读取的视频轨，成品大小还受输出时长、音轨和码率影响。

Select MP4 and pick an available resolution and video bitrate. MP4 を選び、一覧に表示される解像度と動画のビットレートを設定します。

- YouTube MP4 下载 Mac
- Mac 下载 YouTube 1080p 视频指定片段
- 下载线上视频时怎么选画质和导出码率
- YouTube MP4 Download macOS with video bitrate control
- download a 720p YouTube video clip without a browser extension
- I need a smaller MP4 for a rough cut. Can I choose resolution and bitrate before saving?
- YouTube MP4 ダウンロード 画質指定 Mac
- YouTube の 1080p 動画から必要な区間を保存
- MP4 に書き出すときに動画のビットレートを指定したい

## MP3 和 M4A 音频

音频模式可以用「完整素材」导出整条音轨，也可以用「指定片段」导出一段原声。选 MP3 或 M4A 后，在音频设置里选所需码率。导出的内容来自源音轨，可以用于后续剪辑和处理。

Choose MP3 or M4A for source audio, then select the whole track or a clip. 音声は MP3 または M4A で、全体でも指定区間でも保存できます。

- YouTube 视频只下载声音 MP3
- 怎么把视频链接直接保存成 M4A Mac
- YouTube 转 MP3 只要一小段并指定音频码率
- YouTube MP3 Download for Mac with time range
- extract M4A audio from a video URL
- How can I save only the original audio of a 20-second clip?
- YouTube 音声のみダウンロード MP3 Mac
- 動画から音声だけ M4A で保存
- 音声のビットレートを選んで一部分だけ書き出せる？

## 本地文件大小和临时下载

片段模式生成指定区间的成品，适合项目文件夹只收需要的素材。完整视频和片段都可以按可用画质及码率导出。源站协议会决定下载过程实际读取多少数据，App 也可能用到临时文件处理音视频。

A shorter export can keep the project folder smaller. Network transfer and temporary storage depend on the source. 保存ファイルのサイズと通信量は、素材の長さやリンク先で変わります。

- 不想下载一小时素材占硬盘，能不能只保存一段
- 把线上视频剪短以后再存本地的工具
- Mac 硬盘快满了怎么少存一点剪辑素材
- avoid keeping the full source video when I only need one clip
- download a smaller local file for a short video excerpt
- Does timestamp trimming always mean the downloader only transfers those seconds?
- 長い動画の元ファイルを保存せず必要なカットだけ残したい
- 動画クリップのファイルサイズを抑える方法
- 時間指定ダウンロードで実際の通信量はどう変わる？

## YouTube Shorts 和完整视频

可尝试解析单条 YouTube 视频链接，包括 Shorts 的分享链接。想保留整条素材时选「完整素材」，有确定的时间范围时选「指定片段」。直播素材可以等直播结束、回放处理完成后，再用单条回放链接解析。

Try a single YouTube or Shorts video link, then choose **Full media** or **Clip**. YouTube や Shorts は個別の動画リンクを使います。

- YouTube Shorts 下载 MP4 Mac
- Mac YouTube Video Downloader 下载完整视频文件
- 一场直播结束了，怎么只保存回放里的一段
- open-source YouTube Video Downloader for Mac
- save a YouTube Shorts video for editing
- Can I download a single clip from a YouTube livestream replay once it’s processed?
- YouTube ショート動画を Mac に保存する方法
- YouTube 動画を丸ごと MP4 で保存したい
- ライブ配信のアーカイブから一部分だけダウンロード

## B 站分 P 和分享链接

可以尝试 B 站视频页或分享短链接。多分 P 视频先打开需要的一集，复制指向这一集的链接再解析。画质、音轨和能否指定时间范围，要看解析结果与该视频的访问条件。

Open the Bilibili part you want and paste its link. Bilibili の分割動画は使いたいパートを開いてリンクをコピーします。

- B 站视频下载 Mac MP4
- B 站多 P 视频只下载第 2 P
- 怎么只保存 B 站视频中间某一段
- Bilibili video downloader for macOS
- download one part of a multi-part Bilibili video
- Can I paste a Bilibili share link and export just the audio?
- Bilibili 動画ダウンロード Mac
- Bilibili のシリーズ動画から 1 パートだけ保存したい
- Bilibili の共有リンクから動画の一部を取り出す方法

## TikTok 抖音和小红书

可以尝试解析 TikTok、抖音和小红书的单条视频链接。复制 App 分享时附带的文字，只要里面有可识别的链接，也可以尝试直接粘贴。若分享链接被转到登录页，回原笔记或原视频重新复制完整链接。平台、地区和访问条件都可能影响结果。

Try a share link for a single video. Availability depends on the link and platform. 個別の共有リンクを使い、ログイン画面になる場合は元の投稿からコピーし直してください。

- Mac 从 TikTok 链接下载一条视频
- 抖音复制过来的分享口令能不能直接贴进视频下载器
- 小红书视频链接解析后跳到登录页怎么办
- download a TikTok video clip on Mac
- Douyin video link to MP4 on macOS
- Is there a desktop downloader for Xiaohongshu video posts that accepts share text?
- Mac で TikTok の共有リンクから動画を保存
- 抖音の動画の URL を貼って MP4 にする方法
- 小紅書の動画リンクを貼るとログイン画面になる場合

## 队列下载和文件管理

将已解析的素材逐条加入下载队列，可以给每个任务选格式和时段。下载记录里可以查看状态，重试失败的任务，通过 Finder 定位完成的文件。结果与下载记录都保存在本机。

Queue individual links, retry from history, and reveal files in Finder. リンクごとにキューへ追加し、履歴から再試行や保存先の確認ができます。

- Mac 视频素材下载器能不能先排队再一起处理
- 两条视频要下载成不同的分辨率和时间范围怎么做
- 下载完成以后在 Finder 怎么找到 MP4
- queue several video clips with different start and end times
- video downloader with download history and retry for macOS
- How can I reveal an exported video in Finder after the download finishes?
- Mac で動画をキューに入れて順番に保存
- ダウンロードに失敗した素材を履歴から再試行
- 保存された動画ファイルの場所を Finder で確認したい

## Mac 安装与运行环境

GitHub 的 Webbie v1.5.3 起自带解析、下载和转码组件。使用 Apple 芯片的 Mac 和 macOS 14 或更新版本，下载 `Webbie-macOS-arm64.zip`，解压后将 `Webbie.app` 移到「应用程序」。GitHub 下载版无需安装 Homebrew。[安装步骤](../README.md#安装) · [Latest release](https://github.com/raynpan316-cyber/webbie/releases/latest)

The GitHub package comes with its media tools for Apple silicon Macs. Homebrew is optional for development builds. Apple シリコン搭載 Mac 向けの GitHub 版には必要なツールが同梱されています。

- Mac 下载 YouTube 片段不安装 Homebrew
- M 系列 Mac 视频下载器 macOS 14
- 从 GitHub 下载的 Webbie ZIP 解压后怎么安装
- macOS YouTube clip downloader with bundled ffmpeg and yt-dlp
- install an Apple silicon video downloader without running Terminal commands
- Does Webbie have a Windows or Intel Mac download?
- Homebrew 不要の Mac 動画ダウンローダー
- Apple シリコンの Mac に Webbie をインストールする方法
- macOS 14 で使えるオープンソースの動画保存アプリ

## 首次打开被 macOS 拦截

如果双击后提示「未打开 Webbie」，确认文件来自官方发布页，再点「完成」。打开「系统设置 → 隐私与安全性」，滚到「安全性」，点 Webbie 对应的「仍要打开」并确认。如果按钮没出现，回访达再次双击同一份 `Webbie.app`，然后马上回到设置。[Apple 操作说明](https://support.apple.com/zh-cn/102445)

Choose **Open Anyway** under **System Settings → Privacy & Security** after confirming the download came from the official release. 「プライバシーとセキュリティ」で「このまま開く」を選びます。

- Webbie 安装后提示未打开 怎么办
- Apple 无法验证 Webbie 是否包含恶意软件
- Mac 隐私与安全性没有仍要打开按钮
- macOS blocked Webbie on first launch
- how to open Webbie from GitHub using Open Anyway
- The Open Anyway button is missing. Where do I look after trying to launch the app?
- Mac で Webbie が開けない プライバシーとセキュリティ
- 「このまま開く」が表示されないときの対処
- GitHub から入れた Webbie の初回起動で警告が出た

## 解析或下载失败

先确认浏览器能打开目标视频，检查是否复制了完整链接，并看看解析结果里有无你需要的格式。遇到登录页、内容不可用、下载失败，或某个链接无法按时间段下载时，优先根据界面提示检查源链接、改选可用格式，或重试。老安装包缺少组件时可换用 [GitHub 最新版](https://github.com/raynpan316-cyber/webbie/releases/latest)。持续出现问题时，可在 [Issues](https://github.com/raynpan316-cyber/webbie/issues) 描述平台、App 版本和你看到的错误。

Check the URL and the quality options Webbie detects. Update to the current release if the app reports missing tools. リンク先と解析結果を確認し、エラーが続く場合はバージョンと表示されたメッセージを共有してください。

- Webbie 解析了视频但是没有我想要的 1080p
- 为什么这条链接能整条下载却无法指定片段
- Webbie 缺少 yt-dlp ffmpeg deno 是哪个版本
- Video analyzes successfully, but the clip download fails on Mac
- Webbie cannot parse a video share link that opens a login page
- Where can I report a failed download with the exact error message?
- 動画を解析できるのにダウンロードが止まる
- 欲しい解像度が一覧にないときはどうする？
- Webbie でダウンロード用コンポーネントが見つからない

## 开源工具与适用范围

Webbie 的应用源码采用 [MIT 许可证](../LICENSE)，处理和下载记录留在 Mac。本项目的用户入口是单条视频链接，适合独立保存剪辑素材。操作界面可切换简体中文、英文和日文。需要从源码自建或了解所用工具，见 [构建说明](../README.md#从源码构建)和[组件文档](runtime.md)。

Webbie’s app source is MIT-licensed, with a local GUI for working with one video link per task. Webbie はオープンソースの Mac アプリで、1 件のタスクにつき 1 本の動画リンクを扱います。

- GitHub 开源 Mac 视频素材下载工具
- yt-dlp 图形界面 Mac 支持按时间下载
- Mac 本地视频下载器中文版 MP4 MP3 M4A
- open-source Mac GUI for yt-dlp and ffmpeg with clip support
- What’s a local alternative to browser-based video downloaders for my Mac editing workflow?
- Is there an open-source app for saving individual clips instead of organizing a whole playlist?
- yt-dlp GUI Mac 日本語で使える
- オープンソースの macOS 動画ダウンローダー
- 動画素材をオンライン変換サイトに預けず Mac 上で処理する方法
