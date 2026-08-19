# gpumask

Force specific apps to launch on the Intel iGPU by hiding the NVIDIA dGPU
from them — without touching your global PRIME/offload setup, and without
affecting games or anything else.

Built for the common hybrid-graphics annoyance: apps like Slack, Discord,
or Spotify waking up the NVIDIA card just to enumerate GPUs on startup,
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
gpumask spotify discord slack           # preview matches (safe, nothing changes)
gpumask spotify discord slack --apply   # actually patch them
gpumask spotify --undo                  # remove the wrapper from spotify
gpumask --status                        # list every app currently wrapped
```

Flags can go anywhere in the command:

```bash
gpumask spotify --apply
gpumask --undo spotify
gpumask spotify discord --exclude nogpu --apply
```

### `--exclude`

Skip a match that contains a given token — useful when an app ships two
`.desktop` entries (e.g. a normal one and a `-nogpu` variant) and you only
want to wrap one of them:

```bash
gpumask zapzap --exclude nogpu --apply
```

### Full flag reference

| Flag              | Effect                                              |
|-------------------|------------------------------------------------------|
| *(none)*          | Preview mode — shows what would match, changes nothing |
| `--apply`         | Actually patch the matched `.desktop` files          |
| `--undo`          | Remove the wrapper, restoring default behavior       |
| `--status`        | List every app currently wrapped                     |
| `--exclude TOKEN` | Skip matches whose filename/name contains `TOKEN`    |
| `-h`, `--help`    | Show usage                                            |
| `--version`       | Show version                                          |

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
