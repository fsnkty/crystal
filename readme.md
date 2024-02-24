## ⚠ WARNING ⚠
just because this is public doesnt mean I endorse the use of any of it unless explicity stated otherwise.
seriously. this repo is in no way intended for ootb use. attempting to simply "adapt it" will be a nightmare.
learn nix, read docs.

<img align="right" src="./gay.png" width="300"/>

## nix(os) config for my system(s).

### hosts
- `factory`: desktop
- `library`: server <br>
hosts the following..
    - synapse
    - snoms
    - forgejo
    - jellyfin
    - komga
    - navidrome
    - nextcloud
    - qbittorrent
    - vaultwarden

### extras
- colours: [mountain](https://github.com/mountain-theme/Mountain), [my themes](https://github.com/nu-nu-ko/mountain-nix)
- `lib/homeFiles.nix`: thanks [eclairevoyant](https://github.com/eclairevoyant)
- `importAll`: thanks [Gerg-L](https://github.com/Gerg-L/)
- `pkgs/sfFonts.nix`: [San Francisco](https://developer.apple.com/fonts/)

### misc
- tf2: [DeerHud](https://tf2huds.dev/hud/DeerHud), [master comfig](https://comfig.app/app/) launch options `LD_PRELOAD=/usr/lib32/libtcmalloc_minimal.so  SDL_VIDEODRIVER=x11 %command% +exec autoexec -vulkan -full -novid -nojoy -nosteamcontroller -nohltv -particles 1 -precachefontchars -noquicktime`

