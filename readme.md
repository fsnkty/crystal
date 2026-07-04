<h2 align="left">Personal nix/(os) config for my system(s)</h2>
<img align="right" src="./assets/pridemushienix.png" width="150"/>

> [!CAUTION]
> If you are here looking to learn more about Nix and or get started with Nixos, Please use these resources instead, [ [official wiki](https://wiki.nixos.org/), [nix.dev](https://nix.dev/), [noggle.dev](https://noogle.dev/) ]

# hosts
## cafe
desktop
## library
server
## portal
laptop
## generic
enroll tpm2 to root crypt, this could be done properly with lanzaboote's measured boot options, but its not very reliable in my experience.
```bash
sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=4+7+8+9 /dev/<root uuid>
```