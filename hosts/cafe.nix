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
      darkmode.enable = true;
      fonts.setup = true;
      audio.setup = true;
      plymouth.setup = true;
      fastboot.enable = true;
      gaming = {
        steam.enable = true;
        thunderStore.enable = true;
      };
      shell.enable = true;
    };
  };
  
  networking = {
    useNetworkd = true;
    enableIPv6 = true;
    useDHCP = false;
  };
  systemd.network = {
    enable = true;
    networks.enp39s0 = {
      name = "enp39s0";
      dns = [ "1.1.1.1" ];
      address = [ "192.168.0.4/24" ];
      routes = [ { Gateway = "192.168.0.1"; } ];
    };
  };
  users.users.main.packages = builtins.attrValues {
    inherit (pkgs)
      alacritty
      chromium
      vscodium
      discord
      proton-pass
      phinger-cursors;
  };

  # nothing graphical target critical actually *needs* to be online immediately.
  # saves 0.3~s on boot
  systemd.services.NetworkManager-wait-online.enable = false;
  boot = {
    # limine seemingly has no hold key for timeout skip
    loader.systemd-boot.enable = lib.mkForce false;
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
    # faster init for RNG, saves 1~s on boot
    kernelParams = [ "random.trust_cpu=on" ];
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
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
      options = [
        "rw"
        "noatime"
        "fmask=0077"
        "dmask=0077"
      ];
    };
    "/" = {
      device = "/dev/disk/by-label/root";
      fsType = "ext4";
    };
    "/games" = {
      device = "/dev/disk/by-label/games";
      fsType = "ext4";
    };
  };
  system.stateVersion = "26.05";
}
