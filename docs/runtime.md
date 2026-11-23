# Runtime supplied in Webbie releases

Webbie uses these separate command-line tools from its app bundle. Each component retains its own license. The release includes license notices in `Webbie.app/Contents/Resources/Runtime/Licenses` and the Python distributions’ original license files.

- FFmpeg and FFprobe 8.1.3, built with x264 at `b35605ace3ddf7c1a5d67a2eb553f034aef41d55` and LAME 4.0. The resulting executables use GPL-2.0-or-later. Configuration, exact corresponding source archives, and the build script are in `Webbie-FFmpeg-Source.tar.gz` alongside the application on the [v1.5.3 release](https://github.com/raynpan316-cyber/webbie/releases/tag/v1.5.3).
- yt-dlp 2026.10.26, the official Unix ZIP application. It includes EJS 0.8.0 with third-party notices embedded in the JavaScript bundle. [yt-dlp release and source](https://github.com/yt-dlp/yt-dlp/releases/tag/2026.10.26) · [EJS source](https://github.com/yt-dlp/ejs/tree/0.8.0)
- Deno 2.9.8 from the official Apple silicon release. Its engine comes from V8 15.0.245.2, pinned through rusty_v8 150.4.0. [Deno release and source](https://github.com/denoland/deno/releases/tag/v2.9.8) · [rusty_v8 source](https://github.com/denoland/rusty_v8/tree/v150.4.0)
- CPython 3.13.18 from the SHA-256-pinned official Apple silicon archive. [Python build and source metadata](https://github.com/astral-sh/python-build-standalone/releases/tag/20261110) · [CPython source](https://www.python.org/downloads/release/python-31318/)
- The pinned Python wheels are curl-cffi 0.17.0, cffi 2.1.1, certifi 2026.10.19, and pycparser 2.23. The curl-cffi wheel uses the curl-impersonate 2.3.1 build for macOS. [curl-cffi source and wheels](https://pypi.org/project/curl-cffi/0.17.0/#files) · [curl-impersonate and dependency source versions](https://github.com/lexiforest/curl-impersonate/tree/v2.3.1) · [cffi source and wheels](https://pypi.org/project/cffi/2.1.1/#files) · [certifi source and wheels](https://pypi.org/project/certifi/2026.10.19/#files) · [pycparser source and wheels](https://pypi.org/project/pycparser/2.23/#files)

## Rebuilding the bundled distribution

Extract the FFmpeg corresponding-source archive to a directory called `sources`. On an Apple silicon Mac with Xcode Command Line Tools, run `./Scripts/build-ffmpeg.sh sources runtime`. This builds the media tools and copies their notices into `runtime`.

Put the upstream artifacts listed above in a directory called `inputs`. Use the filenames in `Scripts/prepare-runtime.sh`, which verifies all SHA-256 checksums. Rename the Astral archive to `python-3.13.18-arm64.tar.gz` and include the release's `notices/` directory from the source archive. Then run the commands below.

```bash
./Scripts/prepare-runtime.sh inputs runtime
WEBBIE_RUNTIME_DIR="$PWD/runtime" ./build.sh
```

The finished app is at `build/Webbie.app`. If your machine has multiple SDKs, use `WEBBIE_SDK_PATH` to choose the one that matches your installed tools.
