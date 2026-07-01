{
  pkgs,
  ...
}:
{
  crystal = {
    system = {
      cleanup = true;
      nix.setup = true;
      timezone.nz = true;
      hardware = {
        cpu.amd = true;
        gpu.amd = true;
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
      htop.enable = true;
      fonts.setup = true;
      audio.setup = true;
      fastboot.enable = true;
      gaming = {
        steam.enable = true;
        thunderStore.enable = true;
        prism.enable = true;
      };
      plymouth.setup = true;
      theme.enable = true;
      plasma6 = {
        enable = true;
        excludePackages = builtins.attrValues {
          inherit (pkgs.kdePackages)
            aurorae
            kwin-x11
            plasma-workspace-wallpapers
            konsole
            ark
            elisa
            okular
            kate
            ktexteditor
            khelpcenter
            krdp
            plasma-keyboard
            qtvirtualkeyboard
            baloo-widgets
            dolphin-plugins
            kmenuedit
            plasma-systemmonitor
            phonon-vlc
            kdeplasma-addons
            baloo
            milou
            ;
        };
      };
    };
  };
  services.displayManager.plasma-login-manager.enable = true;

  users.users.main.packages = builtins.attrValues {
    inherit (pkgs)
      ungoogled-chromium
      discord
      vscodium
      alacritty
      ;
  };

  networking = {
    useNetworkd = true;
    enableIPv6 = true;
    useDHCP = false;
    hosts = {
      "119.224.63.166" = [ "library" ];
      "192.168.0.121" = [ "portal" ];
    };
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
  hardware.bluetooth.enable = true;

  boot = {
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
    kernelParams = [
      # hopefully reduce mode switching
      "video=DP-1:1920x1080@144"
    ];
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
      options = [
        "x-systemd.automount"
      ];
    };
    "/library" = {
      device = "//library/storage";
      fsType = "cifs";
      options = [
        "x-systemd.automount"
        "noauto"
        "x-systemd.idle-timeout=60"
        "x-systemd.device-timeout=5s"
        "x-systemd.mount-timeout=5s"
        "credentials=/keys/librarysmb"
        "uid=1000"
        "gid=1000"
      ];
    };
  };
  system.stateVersion = "26.05";
}
