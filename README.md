# NVCD NeoVim Chad (as in NvChad) for Docker

DEMO:
https://github.com/marionebl/svg-term/issues/6
Right now, the fonts look like crap...
Hopefully OK with FiraCode


NeoVim is changing very fast, but most distros ship with old versions of 
neovim. For example, to check the most current release:

```
curl -s https://api.github.com/repos/rails/rails/releases | 
jq '.[0,1,2,3]|{ URL: .html_url, TAG: .tag_name, DATE: .published_at }'
```

Yet `apt show neovim` and you'll see Ubuntu 22.04 ships with neovim 0.61

Easily install / reinstall most recent stable neovim inside
a Docker container that's fully integrated with your system
(clipboard, permissions, file access)

However you use neovim, permissions and filenames should work
as if it's not running inside a container

```
sudo nvcd /etc/passwd
nvcd foo bar baz "crazy filename with spaces"
nvcd "Any Unicode Filenames 当然汉语也行"
cd ~/Dev/BestThingEver && nvcd
```

Your command line operations and permissions should
come out exactly the same as if you were not using
a Docker container.

### Configuration Experiments

## INSTALL

Ubuntu:
```
sudo apt install fzf curl git docker.io 
sudo usermod -a -G docker $(id -un)
git clone https://github.com/erwin/nvcd.git
cd nvcd
./nvcd --build
```

Fedora:
```
sudo dnf install fzf docker
sudo usermod -a -G docker $(id -un)
sudo systemctl restart docker

```

CentOS:
```
sudo yum install curl git docker
sudo groupadd -r docker
sudo systemctl restart docker
sudo usermod -a -G docker $(id -un)
# requires SELINUX=disabled or selinux security policy
git clone github.com/erwin/nvcd
cd nvcd
./nvcd --build
```

Fedora:

Does installing `fonts-firacode` help?

### Alternate Configs

https://geekrepos.com/topics/vim-configuration
https://neovimcraft.com/

## REQUIREMENTS

#### Complete UTF-8 Terminal

https://www.cl.cam.ac.uk/~mgk25/ucs/examples/UTF-8-demo.txt

#### Recentish Docker

Anything Ubuntu 18.04 or later should work fine.
The docker.io package on Ubuntu 14.04 doesn't work
because the docker `--build-arg` 

#### Modernish Terminal

If you're using a current distro

https://aur.archlinux.org/packages/ttf-symbola




#### Icons in your Terminal Font

The terminal where `nvcd` is running may be connected
via `ssh`, and the exact way to configure fonts for each
terminal is a little bit different.

If you don't already have a font with icons installed,
the Nerd Fonts are a good place to get started. "Nerd Font Complete Mono Windows Compatible"

#### Nice to have: Ligatures

#### Nice to have: True Color

## FAQ

### What do I do about `CTRL+Z` hanging?

CTRL+Z invokes NeoVim's `:suspend` function
You can disable this with:

```
noremap <c-z> <nop>
```

Normally running `:suspend` in NeoVim uses to OS to send `-SIGSTOP` to the process
and then when your shell foregrounds NeoVim, your OS sends `-SIGCONT` (continue)
Resume the process.

Docker also as a `docker pause` and `docker unpause`, but these do not fix our
shell integration problem.

I haven't figured out how to make shell job control work across the Docker container boundary.

Maybe starting one instance on first launch and using `docker exec` to connect
would be faster and provide more of a host shell job control possability


### BUGS

* Share the config for both regular user and root
* CTRL+Z into background hangs - Disable Ctrl+z, use:
  `vim.cmd('nnoremap <c-z> <nop>')`
* How to make Neovim inside a Docker container compatible with `nvr` (NeoVim Remote)
* Warning to remove directories when first starting
  (if I don't create those directories, we get an even uglier warning)

### Useful Resources

* https://stackoverflow.com/questions/53285801/x11-authentication-error-when-run-as-a-docker-container
* https://stackoverflow.com/a/55763212/6310966
* http://wiki.ros.org/docker/Tutorials/GUI
* https://riptutorial.com/docker/example/21831/running-gui-apps-in-a-linux-container
