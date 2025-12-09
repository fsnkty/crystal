# nix build .#nixosConfigurations.recovery.config.system.build.isoImage
{ pkgs, lib, modulesPath, ... }: {
    imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];
    isoImage.squashfsCompression = "gzip -Xcompression-level 1";
    common = {
        cleanup = true;
        nix = true;
        nz = true;
    };
    systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
    users.users.nixos = {
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILzo6UVJ72vS2sNW20QjMCmfCeChGPUT4YfY8VHiMVjv fsnkty@factory"];
        password = "remote";
        initialHashedPassword = lib.mkForce null;
    };    
}