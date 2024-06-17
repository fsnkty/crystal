<h2 align="left">Personal nix/(os) config for my system(s)</h2>
<img align="right" src="./assets/pridemushienix.png" width="250"/>

> [!CAUTION]
> referencing parts of this repo is in no way endorsement for it as a whole. <br>
> I will frequently use functions/options/values and practices that you probably don't want yourself. <br>
> If you are here looking to learn more about Nix and or "get started" with Nixos, Please use these resources instead, [ [official wiki](https://wiki.nixos.org/) [nix.dev](https://nix.dev/) [noggle.dev](https://noogle.dev/) ]

### structure
- assets:
    - non nix resources
    - local packages, nix not needed for evals. (e.g.. disko)
- hosts:
    factory.nix
    library.nix
- libs:
    - common: e.g.. `_colours`
    - functions: e.g.. `lib._mkWebOpt`
    - options: e.g.. `_homeFile.`
- modules:
    - services:
        - web: any service providing a web interface
    - programs: config/setup, _not_ packages
    - system:
      - desktop.nix
      - server.nix
      - common.nix
      - user.nix

### oddities / rules
<img align="right" src="./assets/fuckwith.png" width="250"/>
mostly obvious, just writing here to shame myself into sticking to it..

- I think `with` makes ugly & iffy code, it should never be used as `inherit` exists
- actually using assertions
- common setup should always be a module

### todos
- add hosts for rpi, tablet, laptop(s), server assist

> [!NOTE]
> - `libs/options.nix{home.file}` first written by [eclairevoyant](https://github.com/eclairevoyant)
> - `libs/functions.nix{genAttrs'}` thank you [lilyinstarlight](https://github.com/lilyinstarlight)
> - recursive importing originally from an old stage of [Gerg-L's nixos repo](https://github.com/Gerg-L/nixos)
