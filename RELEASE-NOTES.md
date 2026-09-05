Debian 13 (trixie) build of `intel-media-va-driver-non-free` with upstream
commit [`c3e1867`](https://github.com/intel/media-driver/commit/c3e1867d6de236102951ee40a75319dbf54beb79)
backported.

Fixes `vainfo` and FFmpeg VAAPI crashing with **Bus error (SIGBUS, exit 135)**
during `vaInitialize` on Intel Arc discrete GPUs where Resizable BAR is
unavailable.

## Install

```bash
sudo apt install ./intel-media-va-driver-non-free_25.2.3+ds1-1+smallbar1_amd64.deb
```

You also need to be in the `render` group:

```bash
sudo usermod -aG render "$USER"   # then log out and back in
```

## Verified

Arc B580 (Battlemage G21), 256MB BAR, `xe` driver, Debian 13:

| Test | Stock | Patched |
|---|---|---|
| `vainfo` | SIGBUS (135) | exit 0, 39 profiles |
| VAAPI decode | SIGBUS (135) | exit 0 |
| H.264 / HEVC / AV1 encode | never initialised | exit 0 |
| `drm-cycles-vcs` | 0 | 69,393,918 |

Upstream issue: https://github.com/intel/media-driver/issues/1998
