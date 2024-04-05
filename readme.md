<img align="right" src="./assets/pridenixlogo.png" width="200"/>

# nix(os) config for my system(s)

### ⚠ READ ME ⚠
I will link to this repo as a demonstration but I do **not** endorse the use of practically any section of it "as is". <br>
I will frequently use functions/options/values and practices that you probably don't want yourself. <br>
if you are here looking to learn more about Nix and or "get started" with Nixos, Please use the manuals instead! I promise nothing here is worth your time.


## hosts
- factory: desktop
- library: server
- portal: wsl

## structure
- assets:
    - local packages, agenix files, nix not needed for host evals.
    - non nix resources
- hosts:
    - hostname.nix: each host gets one file for hardware setup and module options.
- libs:
    - common: self-explanatory, commonly used values
    - functions: e.g. `mkWebOpt` etc
    - options: e.g. `homeFile.`
- modules:
    - services:
        - web: any service providing a web interface
    - programs: config, _not_ packages
    - desktop.nix: the "desktop experience" e.g. fuzzel, hyprland, ags
    - user.nix: user & group setup, e.g. noroot, shell setup, media groups etc
    - common.nix: e.g.. common nix/(os) options 
    - system.nix: wired net, hostkeys (might merge with common.nix)

## oddities / rules
most of this is a no brainer, just writing it down to help push myself to stick to it lol
- I strongly dislike `with`, I will refuse to use it at all
- I dislike managing what imports what, as such all hosts import all mods and libs.
( this also forces me to manage module options properly.

- assertions for when a module MUST be enabled for another to work
- mkIf for sections only required when a module is enabled

- common setup should always be a module, even if a single line.. (e.g. postgresql) (although painful is likely a net positive for readability.. )

## todos
- look into writing my solution for managing encrypting secrets
- replace nh, as I only use `nh os *`
- improve deployment of updates to different hosts. ( will become more important as I make more changes requiring rebuilds )
- add hosts for rpi, tablet, laptop(s), server assist

## notes
- `libs/options.nix{home.file}`: written by [eclairevoyant](https://github.com/eclairevoyant)
- `libs/functions.nix{genAttrs'}`: thanks [lilyinstarlight](https://github.com/lilyinstarlight)
- recursive importing taken from an old stage of [Gerg-L](https://github.com/Gerg-L)'s nixos repo, I've since changed it.
- `nix eval .#nixosConfigurations.host.config.*`, also the repl exists..
