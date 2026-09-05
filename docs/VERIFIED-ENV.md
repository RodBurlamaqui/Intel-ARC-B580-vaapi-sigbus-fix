# Verified working configuration
# Captured on the reference test system

## Hardware
  86:00.0 VGA compatible controller [0300]: Intel Corporation Battlemage G21 [Arc B580] [8086:e20b]
  	Subsystem: ASRock Incorporation Device [1849:6021]
  PCIe link: Speed 8GT/s (downgraded), Width x8
  BAR2 (small BAR condition): BAR 2: current size: 256MB, supported: 256MB 512MB 1GB 2GB 4GB 8GB 16GB
  VRAM visible: 256MiB of 12216MiB total (measured on kernel 6.12 via
    /sys/kernel/debug/dri/0/vram_mm; that node does NOT exist on kernel 7.1.8 --
    use the lspci Resizable BAR line above to detect small BAR instead)
  Board: dual-socket Ivy Bridge-EP server board, BIOS dated 2015
         (predates Resizable BAR entirely -- hence the small BAR condition)

## Kernel
  7.1.8+deb13-amd64
  cmdline (relevant flags only): ro quiet intel_iommu=off
  driver: xe
  GuC: found release version 70.65.0

## Userspace versions
  intel-media-va-driver-non-free   25.2.3+ds1-1
  libigdgmm12                      22.7.2+ds1-1
  libva2                           2.22.0-3
  libva-drm2                       2.22.0-3
  mesa-vulkan-drivers              25.0.7-2+deb13u1
  libgl1-mesa-dri                  25.0.7-2+deb13u1
  firmware-misc-nonfree            20260622-1~bpo13+1
  firmware-intel-graphics          20260622-1~bpo13+1
  ffmpeg                           7:7.1.5-0+deb13u1
  vainfo                           2.22.0+ds1-2

## Important caveats

* `intel_iommu=off` appears in the cmdline above but is NOT required for this fix.
  It was set while debugging (it silenced unrelated recurring DMAR invalidation
  errors on this VT-d platform) and had zero effect on the SIGBUS. Do not
  cargo-cult it.
* Kernel 7.1.8 and firmware 20260622 are likewise NOT required. The SIGBUS
  reproduced identically on stock Debian 13 kernel 6.12.107 with firmware
  20250410. The bug is purely userspace allocation placement.
* The 256MB BAR is unchanged by this fix. The driver stops placing buffers
  outside the CPU-visible window; it does not enlarge the window. Small-BAR
  performance costs remain.
* Minimum requirement is simply: Intel dGPU on the `xe` kernel driver with
  cpu_visible_size < total VRAM.

## PCIe link — not a fault

The GPU sits behind an on-package PCIe switch, so `lspci` shows four devices:

| | root port | card upstream | card downstream | GPU |
|---|---|---|---|---|
| LnkCap | 8GT/s x16 | 16GT/s x8 | 2.5GT/s x1 | 2.5GT/s x1 |
| LnkSta | 8GT/s x8 | 8GT/s x8 | 2.5GT/s x1 | 2.5GT/s x1 |
| EqualizationComplete | + | + | - | - |
| DLActive | + | + | - | - |

The two "2.5GT/s x1" entries are **internal die-level ports**, not trained
electrical links: no equalization, no Data Link Layer Active, no slot or
common clock, and `LnkCap2` advertising 2.5GT/s as their only supported
speed. They are hardcoded minimums with no PHY behind them.

Do not mistake these for a degraded link. Read the **card's upstream port**
instead. Confirmed empirically: four parallel 4K nv12 upload streams
sustained ~2200 MB/s host-to-device, 8.8x the 250 MB/s theoretical ceiling
of a real Gen1 x1 link.

The reference platform is an Ivy Bridge-EP root port whose silicon ceiling
is Gen3, so `8GT/s (downgraded)` on a Gen4 card is expected, and x8 is the
card's native width. PCIe 3.0 x8 is the correct maximum there.

## Small BAR consequences beyond this fix

The BAR aperture is exposed as a Vulkan heap that is both DEVICE_LOCAL and
HOST_VISIBLE. On a small-BAR system it is ~256 MB rather than full VRAM,
which makes some Vulkan compute workloads fail with `-12 ENOMEM` rather than
merely run slower. Media engines are unaffected. See README for measurements.

The kernel attempts a BAR resize at every boot and reports
`Failed to resize BAR2 ... (-ENOSPC)` followed by `Small BAR device` when
firmware has laid the bridge windows out too tightly. On the reference
platform the ACPI _CRS window has ample free space and both bridges decode
64-bit prefetchable memory (`decode_type=1`, upper32 populated), so
`pci=realloc` is a well-founded thing to try. lspci may tag the window
`[32-bit]`; that is a display quirk -- read the config-space registers.
