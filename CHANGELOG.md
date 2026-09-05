# Changelog

## Unreleased — docs

GPU firmware ruled out by direct test (FWCODE 21.1137 → 21.1182, OptionROM
23.1051.0.0 → 23.1066.0.0; LVFS, Sept 2026) and recorded in the verified
environment, which previously omitted the card's own firmware level.

Documented that the patch becomes a no-op on a full BAR — `has_small_bar` is
false once `cpu_visible_size == total_size` — and should be kept installed
regardless, since it covers early boot, `norebar`, rescue and live media.

## 25.2.3+ds1-1+smallbar1

Backports upstream commit
[`c3e1867`](https://github.com/intel/media-driver/commit/c3e1867d6de236102951ee40a75319dbf54beb79)
onto Debian 13's `intel-media-va-driver-non-free 25.2.3+ds1-1`.

Fixes SIGBUS during `vaInitialize` on `xe` small-BAR systems by detecting
when `cpu_visible_size < total_size` for VRAM and setting
`DRM_XE_GEM_CREATE_FLAG_NEEDS_VISIBLE_VRAM` on allocations.

Verified on Intel Arc B580 (Battlemage G21) — decode and H.264/HEVC/AV1
encode all functional, video engines confirmed executing via
`drm-cycles-vcs`. See `docs/VERIFIED-ENV.md`.
