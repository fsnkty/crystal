{ pkgs, ... }: {
  crystal = {
    system = {
      cleanup = true;
      nix.setup = true;
      timezone.nz = true;
      hardware = {
        cpu.amd.enable = true;
        gpu.amd.enable = true;
      };
    };
    users = {
      main = {
        setup = true;
        shell = {
          setup = true;
          prompt = "'%F{red}%m%f %~ %# '";
        };
        git.setup = true;
      };
      root.disable = true;
    };
    desktop = {
      kde.enable = true;
      darkmode.enable = true;
      fonts.setup = true;
      audio.setup = true;
      plymouth.setup = true;
      fastboot.enable = true;
      gaming = {
        steam.enable = true;
        thunderStore.enable = true;
      };
    };
  };

  networking.networkmanager.enable = true;
  users.users.main.packages = builtins.attrValues {
    inherit (pkgs)
      alacritty
      chromium
      vscodium
      discord;
  };

  boot = {
    loader = {
      limine.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      systemd.enable = true;
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      luks.devices."rootcrypt".device = "/dev/disk/by-uuid/b1bfd3ca-6793-44b1-97ee-662ff0ec6eb1";
    };
  };
  fileSystems = {
    "/" = {
      device = "/dev/mapper/rootcrypt";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/0859-D0D6";
      fsType = "vfat";
      options = [
        "rw"
        "noatime"
        "fmask=0077"
        "dmask=0077"
        "x-systemd.automount"
      ];
    };
    "/mnt/gaming" = {
      device = "/dev/sda1";
      fsType = "ntfs3";
      options = [ "uid=1000" ];
    };
    "/mnt/gaming2" = {
      device = "/dev/sdb1";
      fsType = "ntfs3";
      options = [ "uid=1000" ];
    };
  };
  system.stateVersion = "26.05";
}
