{ pkgs, ... }:
{
  crystal = {
    system = {
      cleanup = true;
      nix.setup = true;
      timezone.nz = true;
      hardware = {
        cpu.intel = true;
        gpu.intel = true;
        vfs009x = true;
      };
    };
    users = {
      main = {
        setup = true;
        shell.setup = true;
        git.setup = true;
      };
      root.disable = true;
    };
    desktop = {
      kde-std.enable = true;
      darkmode.enable = true;
      fonts.setup = true;
      audio.setup = true;
      plymouth.setup = true;
      fastboot.enable = true;
      gaming.steam.enable = true;
    };
    server.networking.ssh = true;
  };

  users.users.main = {
    extraGroups = [ "networkmanager" ];
    packages = builtins.attrValues {
      inherit (pkgs)
        firefox
        vscode
        vim
        wget
        ;
    };
  };

  networking.networkmanager.enable = true;
  
  boot = {
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      systemd.enable = true;
      luks.devices = {
        "rootcrypt" = {
          device = "/dev/disk/by-uuid/4b906d09-a291-448f-b93f-ad8688ef6a6d";
          crypttabExtraOpts = [ "tpm-device=auto" ];
        };
        "swapcrypt" = {
          device = "/dev/disk/by-uuid/d4ef99d7-eeb8-4a9b-bfee-c9f4bf45cfe0";
          crypttabExtraOpts = [ "tpm-device=auto" ];
        };
      };
    };
  };
  fileSystems = {
    "/" = {
      device = "/dev/mapper/rootcrypt";
      fsType = "ext4";
      options = [ "noatime" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/52A5-10D0";
      fsType = "vfat";
      options = [
        "rw"
        "noatime"
        "fmask=0077"
        "dmask=0077"
        "x-systemd.automount"
      ];
    };
  };
  swapDevices = [ { device = "/dev/mapper/swapcrypt"; } ];

  system.stateVersion = "25.11";
}
