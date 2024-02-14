{
  pkgs,
  lib,
  config,
  ...
}:
{
  misc = {
    nix = {
      config = true;
      flakePath = "/storage/crystal";
      nh = true;
    };
    shell = {
      enable = true;
      prompt = "'%~ %% '";
    };
    ageSetup = true;
    cleanDefaults = true;
    disableRoot = true;
  };
  desktop = {
    console = true;
    audio = true;
    sway = true;
    theme = true;
    waybar = true;
    wofi = true;
  };
  program = {
    alacritty = true;
    firefox = true;
    htop = true;
    neovim = true;
    prism = true;
    git = true;
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
  ### user stuff
  age.secrets.user = {
    file = ../shhh/user.age;
    owner = config.users.users.main.name;
  };
  users = {
    mutableUsers = false;
    users.main = {
      name = "nuko";
      uid = 1000;
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      hashedPasswordFile = config.age.secrets.user.path;
      packages = builtins.attrValues {
        inherit (pkgs)
          krita
          obs-studio
          cinny-desktop
          vesktop
          imv
          mpv
          eza
          yazi
          ueberzugpp
          ;
      };
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFhTVx3lCAqu9xxn8kPwH0bl0Qg0cE6E0TSJILErD3mq"
      ];
    };
  };
  home.file =
    lib.genAttrs
      [
        "Documents"
        "Downloads"
        "Pictures"
        "Videos"
        "crystal"
      ]
      (name: { source = "/storage/${name}"; });
  ### hardware
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
      "video=DP-1:1920x1080@144"
    ];
  };
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-id/nvme-Samsung_SSD_980_500GB_S64DNF0R716711A-part1";
      fsType = "vfat";
      options = [
        "rw"
        "noatime"
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
