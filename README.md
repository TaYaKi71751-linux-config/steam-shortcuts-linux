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
  git \
  wget \
  --noconfirm
```
### #for All
```
sudo pacman -Syu \
  base-devel \
  go \
  git \
  wget \
  --noconfirm
```
### #yay
```
cd /tmp
rm -rf /tmp/yay/
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd /tmp/yay
makepkg -Si --force
makepkg -i --noconfirm
```
### #shc
```
yay -S shc --noconfirm
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
mkdir -p tailscale
cd tailscale
git init
git remote add origin https://github.com/tailscale/tailscale.git
git pull origin main
git checkout origin/main
./build_dist.sh tailscale.com/cmd/tailscale
./build_dist.sh tailscale.com/cmd/tailscaled
touch ~/.bashrc
find ~/ -type f -name '.*shrc' -maxdepth 1 -exec sh -c 'grep -w "export PATH=\${PATH}:$(pwd)$" {} || echo "export PATH=\${PATH}:$(pwd)" >> {}' \;
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
