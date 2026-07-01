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
      fonts.setup = true;
      audio.setup = true;
      plymouth.setup = true;
      fastboot.enable = true;
      gaming.steam.enable = true;
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
    server.networking.ssh = true;
  };
  services.displayManager.plasma-login-manager.enable = true;

  users.users.main = {
    extraGroups = [ "networkmanager" ];
    packages = builtins.attrValues {
      inherit (pkgs)
        ungoogled-chromium
        discord
        vscodium
        alacritty
        vim
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
