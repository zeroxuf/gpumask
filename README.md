# gpumask

Force specific apps to launch on the Intel iGPU by hiding the NVIDIA dGPU
from them — without touching your global PRIME/offload setup, and without
affecting other system

Built for the common hybrid-graphics annoyance: apps waking up the NVIDIA card just to enumerate GPUs on startup,
burning power for no reason.

## How it works

`gpumask` patches the `Exec=` line of an app's `.desktop` file so it
launches through `gpumask-run` instead of directly. `gpumask-run` then
starts the app inside a [bubblewrap](https://github.com/containers/bubblewrap)
sandbox with the NVIDIA device nodes and PCI sysfs entry masked out, so the
app never sees the dGPU and falls back to the Intel iGPU automatically.

- Only the apps you target are affected — everything else, including games,
  still sees NVIDIA normally.
- Nothing is edited in `/usr/share/applications`; a local override is
  written to `~/.local/share/applications` instead (standard XDG desktop
  file override behavior), so uninstalling is a clean `--undo` or
  `rm ~/.local/share/applications/<app>.desktop`.
- Matching is whole-word, not substring — targeting `zed` won't
  accidentally match `kcm_breezedecoration`.

## Requirements

- Linux with hybrid Intel/NVIDIA (PRIME) graphics
- [`bubblewrap`](https://github.com/containers/bubblewrap) (`bwrap`)

```bash
sudo pacman -S bubblewrap      # Arch
sudo apt install bubblewrap    # Debian/Ubuntu
sudo dnf install bubblewrap    # Fedora
```

## Install Manual (any distro)

```bash
curl -fsSL https://raw.githubusercontent.com/zeroxuf/gpumask/main/install.sh | bash
```

Installs to `~/.local/bin` by default. Set `PREFIX=/usr/local` and run
with `sudo` for a system-wide install instead.

### From source

```bash
git clone https://github.com/zeroxuf/gpumask.git
cd gpumask
make install               # installs to /usr/local/bin
make PREFIX=$HOME/.local install   # or a user-local install
```

## Usage

```bash
gpumask [APPNAME]                       # preview matches (safe, nothing changes)
gpumask [APPNAME] --apply               # actually patch them
gpumask [APPNAME] --undo                # remove the wrapper from [APPNAME]
gpumask --status                        # list every app currently wrapped
```

### `--exclude`

Skip a match that contains a given token — useful when an app ships two
`.desktop` entries (e.g. a normal one and a `-nogpu` variant) and you only
want to wrap one of them:

```bash
gpumask [APPNAME] --exclude [EXCLUDE_TEXT] --apply
```

### Full flag reference

| Flag              | Effect                                                 |
|-------------------|--------------------------------------------------------|
| *(none)*            | Preview mode — shows what would match, changes nothing |
| `--apply`           | Actually patch the matched `.desktop` files              |
| `--undo`            | Remove the wrapper, restoring default behavior         |
| `--status`          | List every app currently wrapped                       |
| `--doctor`          | check your system for common issues                    |
| `--fix`             |  Checks needed requirements and program functionality    |
| `--exclude TOKEN`   | Skip matches whose filename/name contains `TOKEN`        |
| `-h`, `--help`        | Show usage                                             |
| `--version`         | Show version                                           |

## Tested Hardware

`gpumask` has been tested and confirmed working on:

- **GPU pair:** NVIDIA (dGPU) + Intel (iGPU) hybrid laptop
- **Display server:** Wayland session
- **Distro:** CachyOS (Arch-based)
- **NVIDIA driver:** proprietary (not `nouveau`, not `nvidia-open`)

This is currently the *only* combination verified end-to-end. It should
work — and the code is written to be hardware-agnostic where possible
(see below) — on other combinations, but they haven't been confirmed
by an actual run yet.

### Should work, not yet confirmed

These are supported by the code's design, but need a real test report
before being called "supported":

- **AMD iGPU instead of Intel** — `gpumask-run` detects the NVIDIA dGPU
  dynamically by PCI vendor ID (`0x10de`), not a hardcoded address, and
  picks whichever non-NVIDIA Vulkan ICD is present on the system rather
  than assuming `intel_icd.x86_64.json`. In principle this means an
  AMD (RADV) iGPU should work the same way — but it hasn't been run on
  one yet.
- **X11 sessions** — the masking mechanism (bubblewrap + device node
  hiding) doesn't depend on Wayland specifically, so X11 should behave
  the same. Not yet tested.
- **Other distros** (Fedora, Ubuntu/Debian, openSUSE) — `install.sh`
  detects `pacman`/`apt`/`dnf`, but only the Arch/CachyOS path has
  actually been exercised.

### Want to help expand this list?

If you've run `gpumask` successfully (or unsuccessfully) on a
combination not listed above — different GPU vendor pairing, different
distro, X11 vs Wayland — please open an issue with your hardware and
driver details. Real test reports are what turn "should work" into
"tested."

## Uninstall

### Quick (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/zeroxuf/gpumask/main/uninstall.sh | bash
```

### manual / from source
```bash
make uninstall
```

Run `gpumask --status` first if you want to `--undo` any wrapped apps
before removing the package — uninstalling `gpumask` itself won't revert
already-patched `.desktop` files.

## License

MIT — see [LICENSE](LICENSE).
