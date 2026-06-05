{ pkgs, lib, ... }: {
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
      discord
      proton-pass;
  };

  boot = {
    # limine seemingly has no hold key for timeout skip
    loader.systemd-boot.enable = lib.mkForce false;
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
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
      luks.devices."root" = {
	      device = "/dev/disk/by-label/rootcrypt";
	      crypttabExtraOpts = [ "tpm2-device=auto" ];
      };
    };
  };
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/root";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
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
  system.stateVersion = "26.05";
}
