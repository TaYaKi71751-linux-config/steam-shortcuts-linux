# #steam-shortcuts
## #before
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
  --noconfirm
```
### #for All
```
sudo pacman -Syu \
  base-devel \
  go \
  --noconfirm
```
### #npm
```
sudo pacman -S npm
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
brew install tailscale
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
