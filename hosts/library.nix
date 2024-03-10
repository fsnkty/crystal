{ lib, ... }:
{
  misc = {
    nix = {
      config = true;
      flakePath = "/storage/repos/crystal";
      nh = true;
    };
    secrets = true;
    cleanDefaults = true;
    nztz = true;
  };
  users = {
    noRoot = true;
    main = {
      enable = true;
      shell = {
        setup = true;
        prompt = "'%F{magenta}圖書館%F{reset_color} %~ %# '";
      };
      keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBN4+lDQxOfTVODQS4d3Mm+y3lpzpsSkwxjbzN4NwJlJ" ];
    };
  };
  program = {
    htop = true;
    neovim = true;
    git = true;
    ssh = true;
  };
  service = {
    web =
      lib.genAttrs
        [
          "nginx"
          "forgejo"
          "jellyfin"
          "qbittorrent"
          "nextcloud"
          "vaultwarden"
          "synapse"
          "navidrome"
          "komga"
          "grafana"
        ]
        (_: {
          enable = true;
        });
    fail2ban = true;
    postgresql = true;
    mailserver = true;
    openssh = true;
    blocky = false;
  };
  ### misc
  security.sudo.execWheelOnly = true;
  ### management user stuff
  users.groups.media = { };
  ### networking
  networking = {
    domain = "shimeji.cafe";
    hostName = "library";
    hostId = "9a350e7b";
    enableIPv6 = false;
    useDHCP = false;
  };
  systemd.network = {
    enable = true;
    networks.enp6s0 = {
      enable = true;
      name = "enp6s0";
      networkConfig = {
        DHCP = "no";
        DNSSEC = "yes";
        DNSOverTLS = "yes";
        DNS = [
          "1.1.1.1"
          "1.1.0.0"
        ];
      };
      address = [ "192.168.0.3/24" ];
      routes = [ { routeConfig.Gateway = "192.168.0.1"; } ];
    };
  };
  services.openssh.hostKeys = [
    {
      comment = "library host";
      path = "/etc/ssh/library_ed25519_key";
      type = "ed25519";
    }
  ];
  ### hardware
  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
  };
  powerManagement.cpuFreqGovernor = "performance";
  boot = {
    loader = {
      timeout = 0;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "sd_mod"
    ];
    kernelModules = [ "kvm-intel" ];
    supportedFilesystems = [ "zfs" ];
  };
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-id/ata-KINGSTON_SA400M8120G_50026B7682AD48A0-part1";
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
    "/var/lib" = {
      device = "spool/state";
      fsType = "zfs";
    };
  };
  swapDevices = [ { device = "/dev/disk/by-id/ata-KINGSTON_SA400M8120G_50026B7682AD48A0-part2"; } ];
  ### remember the warning.. ###
  system.stateVersion = "23.11";
}
