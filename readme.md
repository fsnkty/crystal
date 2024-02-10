# ⚠ DONT COPY BLINDLY ⚠
just because this is public doesnt mean I endorse the use of any of it unless explicity stated otherwise.
seriously. this repo is in no way intended for ootb use. attempting to simply "adapt it" will be a nightmare.
learn nix, read docs.

<img align="right" src="./gay.png" width="300"/>

## nix(os) config and modules for my system(s).

### hosts
- `factory` - desktop, all AMD, wayland (sway)
- `library` - server, all Intel, <br>
hosts the following..
    - conduit (matrix home server)
    - snoms (simple nixos mail server)
    - forgejo (selfhost git web)
    - jellyfin (media server)
    - komga (book server)
    - navidrome (music server)
    - nextcloud (file hosting)
    - qbittorrent (torrent web client)
    - vaultwarden (password manager)

### extras
- colorsceme - [mountain](https://github.com/mountain-theme/Mountain), [my themes](https://github.com/nu-nu-ko/mountain-nix)
- `home.file` - replaced with `lib/homeFiles.nix` yoinked from [eclairevoyant](https://github.com/eclairevoyant)
- `importAll` - yoinked from [Gerg-L](https://github.com/Gerg-L/)
- fonts - Apple's [San Francisco](https://developer.apple.com/fonts/), packaged under `pkgs/sfFonts.nix` as I dont think it belongs in nixpkgs

### misc
- tf2 - [DeerHud](https://tf2huds.dev/hud/DeerHud), [master comfig](https://comfig.app/app/) launch options `LD_PRELOAD=/usr/lib32/libtcmalloc_minimal.so  SDL_VIDEODRIVER=x11 %command% +exec autoexec -vulkan -full -novid -nojoy -nosteamcontroller -nohltv -particles 1 -precachefontchars -noquicktime`

