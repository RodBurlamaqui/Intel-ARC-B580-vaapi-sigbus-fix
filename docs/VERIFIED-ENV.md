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
  Board: X9DRH-7TF/7F/iTF/iF, BIOS 3.2  06/04/2015

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
