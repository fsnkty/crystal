{ lib, pkgs, ... }:
{
  _common = {
    nix = {
      config = true;
      flakePath = "/storage/repos/crystal";
      nh = true;
    };
    agenix.setup = true;
    cleanup = true;
  };
  _system = {
    timeZone.NZ = true;
    setHostKey = true;
    wired = {
      enable = true;
      ip = "192.168.0.3";
      name = "enp6s0";
    };
  };
  _user = {
    mediaGroup = true;
    disableRoot = true;
    immutable = true;
    main = {
      enable = true;
      shell = {
        setup = true;
        prompt = "'%F{magenta}圖書館%F{reset_color} %~ %# '";
      };
      loginKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBN4+lDQxOfTVODQS4d3Mm+y3lpzpsSkwxjbzN4NwJlJ" ];
    };
  };
  _programs = {
    neovim = true;
    git = true;
    ssh = true;
  };
  _services = {
    fail2ban = true;
    postgresql = true;
    openssh = true;
    prometheus = true;
    mailServer = true;
    synapse = true;
    nginx = true;
    web = {
      komga.enable = true;
      navidrome.enable = true;
      forgejo.enable = true;
      vaultwarden.enable = true;
      nextcloud.enable = true;
      qbittorrent.enable = true;
      grafana.enable = true;
      jellyfin.enable = true;
    };
  };
  # shouldn't be able to get to these anyway
  systemd = {
    services = {
      "getty@tty1".enable = false;
      "autovt@".enable = false;
      "serial-getty@ttyS0".enable = lib.mkDefault false;
      "serial-getty@hvc0".enable = false;
    };
    enableEmergencyMode = false;
  };
  ### networking
  networking = {
    domain = "shimeji.cafe";
    hostName = "library";
    hostId = "9a350e7b";
  };
  ### hardware
  powerManagement.cpuFreqGovernor = "powersave";
  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
  };
  boot = {
    kernelPackages = pkgs.linuxPackages_hardened;
    kernelModules = [ "kvm-intel" ];
    kernelParams = [
      "panic=1"
      "boot.panic_on_fail"
    ];
    loader = {
      timeout = 0;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = [ "zfs" ];
  };
  fileSystems = {
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
    "/boot" = {
      device = "/dev/disk/by-id/nvme-Samsung_SSD_980_500GB_S64DNF0R716712D-part1";
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
  zramSwap.enable = true;
  swapDevices = [ { device = "/dev/disk/by-id/nvme-Samsung_SSD_980_500GB_S64DNF0R716712D-part2"; } ];

  system.stateVersion = "23.11";
}
