# #steam-shortcuts
## #before
https://gist.github.com/rondhi/f9163e7649aa734b5421a8f58bd6c49e
### #Disable read-only
```
sudo steamos-readonly disable
```
## #Install Dependencies
### #for Steam Deck
```
sudo pacman -Syu \
  base-devel \
  holo-rel/linux-headers \
  linux-neptune-headers \
  holo-rel/linux-lts-headers \
  git glibc gcc gcc-libs \
  fakeroot linux-api-headers \
  libarchive \
  go \
  wget \
  --noconfirm
```
### #for All
```
sudo pacman -Syu \
  base-devel \
  go \
  wget \
  --noconfirm
```
### #nvm
```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
```
### #npm
```
nvm install --lts
nvm use --lts
```
### #pnpm
```
sudo npm i -g pnpm
```
### #brew
```
curl -LsSf https://raw.githubusercontent.com/raccl/packages/archlinux/packages/brew.sh | sh
```
### #flatpak
```
sudo pacman -Syu \
  flatpak \
  --noconfirm
```
### #tailscale
```
mkdir -p ~/.local/tailscale/steamos
cd ~/.local/tailscale/steamos
curl -LsSf https://pkgs.tailscale.com/stable/tailscale_1.24.2_amd64.tgz -o tailscale_1.24.2_amd64.tgz
tar xzf tailscale_1.24.2_amd64.tgz
cd tailscale_1.24.2_amd64
touch ~/.bashrc
find ~/ -type f -name '.*shrc' -maxdepth 1 -exec sh -c 'echo "export PATH:\${PATH}:$(pwd)" >> {}' \;
export PATH=${PATH}:$(pwd)
```
### #Microsoft Edge
```
flatpak install flathub com.microsoft.Edge --assumeyes
```
### #OBS Studio
```
flatpak install com.obsproject.Studio.Plugin.OBSVkCapture --assumeyes
flatpak install org.freedesktop.Platform.VulkanLayer.OBSVkCapture --assumeyes
flatpak install flathub com.obsproject.Studio --assumeyes
```

## #Build
```
cd ~/
git clone https://github.com/TaYaKi71751/steam-shortcuts.git
cd ~/steam-shortcuts
bash ./build.sh
```
## #Add to Steam
```
pnpm i
pnpm add:steam
```
