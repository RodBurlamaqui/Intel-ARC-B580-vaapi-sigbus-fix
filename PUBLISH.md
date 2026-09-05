# How to publish this repo

Everything here is ready to go. Nothing needs editing except one placeholder.

**Intended repo name:** `arc-b580-vaapi-sigbus-fix`
**Intended visibility:** public
**Description:** Fix for Intel Arc VAAPI SIGBUS during vaInitialize on small-BAR systems (Debian 13 .deb + patch)

## One thing to replace

`README.md` line 55 contains `YOUR-USERNAME`. Replace it with the real
GitHub account once the repo exists:

```bash
sed -i 's|YOUR-USERNAME|<actual-username>|' README.md
```

## Publish with gh

```bash
gh auth login
cd arc-b580-vaapi-sigbus-fix
git init -b main
git add -A
git commit -m "Debian 13 package with small-BAR SIGBUS fix for Intel Arc"

gh repo create arc-b580-vaapi-sigbus-fix --public --source=. --remote=origin \
  --description "Fix for Intel Arc VAAPI SIGBUS during vaInitialize on small-BAR systems (Debian 13 .deb + patch)" \
  --push
```

## Cut a release

The `.deb` is committed in `dist/`, but the README's install command points at
a release asset, so create the release too:

```bash
gh release create "v25.2.3+smallbar1" \
  dist/intel-media-va-driver-non-free_25.2.3+ds1-1+smallbar1_amd64.deb \
  dist/SHA256SUMS \
  --title "25.2.3+ds1-1+smallbar1" \
  --notes-file RELEASE-NOTES.md
```

## Publish without gh

Create the repo through the GitHub web UI, then:

```bash
git init -b main && git add -A
git commit -m "Debian 13 package with small-BAR SIGBUS fix for Intel Arc"
git remote add origin https://github.com/<user>/arc-b580-vaapi-sigbus-fix.git
git push -u origin main
```

Then upload `dist/*.deb` and `dist/SHA256SUMS` as assets on a new release
tagged `v25.2.3+smallbar1`, using `RELEASE-NOTES.md` as the body.

## Suggested topics

`intel-arc` `vaapi` `debian` `battlemage` `intel-media-driver` `resizable-bar`
`sigbus` `hardware-acceleration` `ffmpeg` `xe-driver`

## Licensing (already handled)

Upstream is MIT (Expat) plus some BSD-3-clause. Redistribution of the binary
is permitted. Debian's "non-free" label is a DFSG matter (prebuilt shader
kernels without source), not a redistribution restriction. See `NOTICE`.
