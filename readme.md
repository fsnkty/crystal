## ⚠ WARNING ⚠
This not intended to be a resource to learn from, I also make zero effort to make this portable or adaptable.
please look elsewhere for that, I promise trying to use this would be more pain than its worth if you are just starting out.

Please feel free to comment on where I can improve! I really appreciate it

<img align="right" src="./gay.png" width="300"/>

## nix(os) config for my system(s).

### hosts
- `factory`: desktop
- `library`: server
- `portal` : wsl
- there are others I need to add I'm just lazy..

### structure oddities
- program module(s) can only apply to the `main` user
- many services assume others are enabled ( mostly postgresql, nginx & snoms )
- nuke.nix ( this is super pointless )
- most everything assumes `secrets` is enabled

### potential todos
- replace `nh` I don't make use of most of it.
- replace `agenix` I want to learn more about how my secrets are deployed and there is a fair amount of it which I don't use, also a file per secret is messy imo.
- move most theme resources to another flake.
- improve the `nginx module` vhosts generation.

### extras
- `lib/homeFiles.nix`: thanks [eclairevoyant](https://github.com/eclairevoyant)
- `importAll`: thanks [Gerg-L](https://github.com/Gerg-L/) ( I've since just made it take a list )
- colours: [mountain](https://github.com/mountain-theme/Mountain), [my themes](https://github.com/nu-nu-ko/mountain-nix)
- `pkgs/sfFonts.nix`: [San Francisco](https://developer.apple.com/fonts/) 

### misc
- tf2: [DeerHud](https://tf2huds.dev/hud/DeerHud), [master comfig](https://comfig.app/app/) launch options `LD_PRELOAD=/usr/lib32/libtcmalloc_minimal.so  SDL_VIDEODRIVER=x11 %command% +exec autoexec -vulkan -full -novid -nojoy -nosteamcontroller -nohltv -particles 1 -precachefontchars -noquicktime`

