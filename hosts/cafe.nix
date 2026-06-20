{ config, pkgs, lib, ... }: {
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
        prism.enable = true;
      };
      kde.enable = true;
    };
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
  users.users.main.packages = builtins.attrValues {
    inherit (pkgs)
      alacritty
      chromium
      vscodium
      discord
      proton-pass
      protonmail-desktop
      ;
  };

  hardware.bluetooth.enable = true;
    
    environment = {
      etc = {
        "xdg/kdeglobals" = {
          text = ''
            [KDE Control Module Restrictions][$i]
            kcm_updates=false
            kcm_feedback=false
            kcm_baloofile=false
            kcm_componentchooser=false
            kcm_fontinst=false
            kcm_fonts=false
            kcm_users=false
          '';
        };
      };
      sessionVariables = {
        XDG_CONFIG_DIRS = [ "$HOME/.config/kdedefaults" ];
        XDG_DESKTOP_DIR = "$HOME/";
        XDG_DOWNLOAD_DIR = "$HOME/Downloads";
        XDG_DOCUMENTS_DIR = "$HOME/Documents";
        XDG_TEMPLATES_DIR = "$HOME/Documents/Templates";
        XDG_PUBLICSHARE_DIR = "$HOME/Documents/Public";
        XDG_PICTURES_DIR = "$HOME/Pictures";
        XDG_VIDEOS_DIR = "$HOME/Pictures/Videos";
        XDG_MUSIC_DIR = "$HOME/Pictures/Music";
        XDG_PROJECTS_DIR = "$HOME/Projects";
        KPACKAGE_DEP_RESOLVERS_PATH = "${pkgs.kdePackages.frameworkintegration.out}/libexec/kf6/kpackagehandlers";
      };
    };

  boot = {
    # limine seemingly has no hold key for timeout skip
    loader.systemd-boot.enable = lib.mkForce false;
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
    kernelParams = [
      # faster init for RNG, saves 1~s on boot
      "random.trust_cpu=on"
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
        "uid=${toString config.users.users.main.uid}"
        "gid=${toString config.users.groups.users.gid}"
      ];
    };
  };
  system.stateVersion = "26.05";
}
