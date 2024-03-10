{ pkgs, lib, ... }:
{
  misc = {
    nix = {
      config = true;
      nh = true;
    };
    secrets = true;
    users = {
      noRoot = true;
      main = {
        shell.setup = true;
        packages = builtins.attrValues {
          inherit (pkgs)
            krita
            element-desktop
            vesktop
            teams-for-linux
            imv
            mpv
            yazi
            ueberzugpp
            ;
        };
        keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFhTVx3lCAqu9xxn8kPwH0bl0Qg0cE6E0TSJILErD3mq" ];
      };
    };
    cleanDefaults = true;
  };
  ### user setup
  home.file =
    lib.genAttrs
      [
        "Documents"
        "Downloads"
        "Pictures"
        "Videos"
        "Repos"
      ]
      (name: {
        source = "/storage/${name}";
      });
  desktop = {
    sway = true;
    hyprland = true;
    setup = {
      audio = true;
      greeter = {
        enable = true;
        command = "sway";
      };
    };
    theme = {
      fonts = true;
      gtkqt = true;
      console = true;
    };
  };
  program = {
    git = true;
    htop = true;
    neovim = true;

    alacritty = true;
    firefox = true;
    waybar = true;
    wofi = true;

    prism = true;
    steam = true;
  };
  service.openssh = true;
  ### misc
  time.timeZone = "NZ";
  i18n.defaultLocale = "en_NZ.UTF-8";
  security = {
    sudo.execWheelOnly = true;
    tpm2.enable = true;
  };
  ### networking
  networking = {
    hostName = "factory";
    hostId = "007f0200";
    enableIPv6 = false;
    useDHCP = false;
  };
  systemd = {
    services.systemd-udev-settle.enable = false;
    network = {
      enable = true;
      wait-online.enable = false;
      networks.enp39s0 = {
        enable = true;
        name = "enp39s0";
        networkConfig = {
          DHCP = "no";
          DNSSEC = "yes";
          DNSOverTLS = "yes";
          DNS = [
            "1.1.1.1"
            "1.1.0.0"
          ];
        };
        address = [ "192.168.0.4/24" ];
        routes = [ { routeConfig.Gateway = "192.168.0.1"; } ];
      };
    };
  };
  services.openssh.hostKeys = [
    {
      comment = "factory host";
      path = "/etc/ssh/factory_ed25519_key";
      type = "ed25519";
    }
  ];
  # hardware
  powerManagement.cpuFreqGovernor = "schedutil";
  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = true;
  };
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };
  boot = {
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
    loader = {
      timeout = 0; # hold space to open the menu.
      systemd-boot.enable = true;
    };
    plymouth.enable = true;
    initrd = {
      verbose = false;
      systemd.enable = true;
      kernelModules = [ "amdgpu" ];
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
    };
    kernelModules = [
      "kvm-amd"
      "amd_pstate"
    ];
    supportedFilesystems = [ "zfs" ];
    kernelParams = [
      "quiet"
      "splash"
      "amd_pstate=guided"
    ];
  };
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-id/nvme-Samsung_SSD_980_500GB_S64DNF0R716711A-part1";
      fsType = "vfat";
      options = [
        "rw"
        "noatime"
        "fmask=0077"
        "dmask=0077"
        "x-systemd.automount"
      ];
    };
    "/" = {
      device = "rpool/root";
      fsType = "zfs";
    };
    "/storage" = {
      device = "spool/storage";
      fsType = "zfs";
    };
  };
  swapDevices = [ { device = "/dev/disk/by-id/nvme-Samsung_SSD_980_500GB_S64DNF0R716711A-part2"; } ];
  ### remember the warning.. ###
  system.stateVersion = "23.11";
}
