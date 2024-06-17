_:
{
  _user = {
    immutable = true;
    disableRoot = true;
    main = {
      enable = true;
      shell = true;
      loginKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBN4+lDQxOfTVODQS4d3Mm+y3lpzpsSkwxjbzN4NwJlJ" ];
    };
    mediaGroup = true;
  };
  _programs.htop = true;
  _services = {
    openssh = true;
    synapse = true;
    nginx = true;
    web = {
      komga.enable = true;
      navidrome.enable = true;
      vaultwarden.enable = true;
      nextcloud.enable = true;
      qbittorrent.enable = true;
      jellyfin.enable = true;
    };
  };
  _system = {
    nix.config = true;
    cleanup = true;
    timeZone.NZ = true;
    setHostKey = true;
    wired = {
      enable = true;
      ip = "192.168.0.3";
      name = "enp6s0";
    };
    server.headless = true;
  };
  networking = {
    domain = "shimeji.cafe";
    hostName = "library";
    hostId = "9a350e7b";
  };
  powerManagement.cpuFreqGovernor = "powersave";
  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
  };
  boot = {
    loader.systemd-boot.enable = true;
    kernelModules = [ "kvm-intel" ];
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
