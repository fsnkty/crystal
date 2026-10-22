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
      };
      root.disable = true;
    };
    desktop = {
      kde = {
        enable = true;
        excludePackages = 
          (builtins.attrValues {
            inherit (pkgs.kdePackages)
            kio-fuse
            knighttime
            kunifiedpush
            phonon-vlc
            kwrited
            baloo
            milou
            kde-inotify-survey
            kde-gtk-config
            qqc2-breeze-style
            qqc2-desktop-style
            kdeplasma-addons
            kmenuedit
            kinfocenter
            plasma-systemmonitor
            aurorae
            plasma-browser-integration
            plasma-workspace-wallpapers
            konsole
            elisa
            okular
            kate
            ktexteditor
            khelpcenter
            baloo-widgets
            dolphin-plugins
            krdp
            plasma-keyboard
            qtvirtualkeyboard
            union
            ;
          }) ++ [
            #(lib.getBin pkgs.kdePackages.qttools)
            pkgs.hicolor-icon-theme
            #pkgs.xdg-user-dirs
          ];
        kwallet = {
          enable = true;
          luks = true;
        };
        drkonqi = true;
      };
      fastboot = true;
      plymouth = true;
      fonts = true;
      theme = {
        gtk = true;
        qt = true;
      };
      xdg = true;
    };
    server.networking.tailscale.enable = true;
    programs = {
      discord = true;
      vscodium = true;
      git.setup = true;
      neovim = true;
      htop = true;
      alacritty = true;
      firefox = true;
      obs = true;
      gaming = {
        steam = true;
        thunderStore = true;
        prism = true;
        others = true;
      };
    };
  };
  services.displayManager.plasma-login-manager.enable = true;
  services.speechd.enable = false;

  users.users.main.packages = builtins.attrValues {
    inherit (pkgs)
      obsidian
      vlc
      protonmail-desktop
      bitwarden-desktop
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
  hardware.bluetooth = {
    enable = true;
    settings.general = {
      Privacy = "device";
      JustWorksRepairing = "confirm";
    };
  };

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

  # https://github.com/NixOS/nixpkgs/pull/351002/changes#diff-592dc0e631b55d09601fabca093a5a5cfc337eeb5e58a16750263dffc5f76637R162
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };
  boot.kernel.sysctl = {
    "vm.swappiness" = 150;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
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
        "uid=1001"
        "gid=100"
      ];
    };
  };
  system.stateVersion = "26.05";
}
