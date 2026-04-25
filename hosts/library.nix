#nixos-rebuild switch --target-host library --flake .#library --sudo --ask-sudo-password
{ pkgs, ... }:
{
  system = {
    lockdown = true;
    cleanup = true;
    nix = true;
    nz = true;
  };
  shell = {
    setup = true;
    prompt = "'%F{cyan}%m%f %~ %# '";
  };
  server = {
    gtnh = {
      enable = true;
      dataDir = "/storage/games/gtnh";
      openFirewall = true;
      serverPort = 25566;
      jvmOpts = "-Xms6G -Xmx6G -Dfml.readTimeout=180 @java9args.txt -jar lwjgl3ify-forgePatches.jar";
      jvmPackage = pkgs.jre;
    };
    paper = {
      enable = true;
      dataDir = "/storage/games/paper";
      openFirewall = true;
      jvmOpts =
        "-Xms4G -Xmx4G -XX:+UseCompactObjectHeaders -XX:+UseTransparentHugePages"
        + " -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+ParallelRefProcEnabled"
        + " -XX:+PerfDisableSharedMem -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC"
        + " -XX:G1HeapRegionSize=8M -XX:G1HeapWastePercent=5 -XX:G1MaxNewSizePercent=40"
        + " -XX:G1MixedGCCountTarget=4 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1NewSizePercent=30"
        + " -XX:G1RSetUpdatingPauseTimePercent=5 -XX:G1ReservePercent=20 -XX:InitiatingHeapOccupancyPercent=15"
        + " -XX:MaxGCPauseMillis=200 -XX:MaxTenuringThreshold=1 -XX:SurvivorRatio=32"
        + " -jar paper.jar";
      jvmPackage = pkgs.jdk25_headless;
    };
    media = {
      group = true;
      jellyfin = true;
      qbit = true;
      arrs = {
        radarr = true;
        sonarr = true;
        prowlarr = true;
        jellyseerr = true;
      };
    };
    networking = {
      nginx = true;
      samba = true;
      headless = true;
    };
  };

  users = {
    mutableUsers = false;
    users.main = {
      name = "fsnkty";
      hashedPasswordFile = "/keys/user";
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      uid = 1000;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILzo6UVJ72vS2sNW20QjMCmfCeChGPUT4YfY8VHiMVjv fsnkty@factory"
      ];
    };
    users.amber = {
      name = "amber";
      hashedPasswordFile = "keys/user_amber";
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      uid = 1002;
    };
  };

  services.openssh = {
    enable = true;
    hostKeys = [
      {
        comment = "library host";
        path = "/etc/ssh/library_ed25519_key"; # library priv
        type = "ed25519";
      }
    ];
  };

  networking = {
    firewall.enable = true;
    useNetworkd = true;
    hostName = "library";
    hostId = "9a350e7b";
    enableIPv6 = false; # no ipv6 provided by ISP
    useDHCP = false; # static IP
    nameservers = [ "1.1.1.1" ];
  };
  systemd.network = {
    enable = true;
    networks.enp6s0 = {
      enable = true;
      name = "enp6s0";
      dns = [ "1.1.1.1" ];
      address = [ "192.168.0.3/24" ];
      routes = [ { Gateway = "192.168.0.1"; } ];
    };
  };

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
  };
  boot = {
    loader.systemd-boot.enable = true;
    kernelModules = [ "kvm-intel" ];
    supportedFilesystems = [ "zfs" ];
  };
  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot = {
      enable = true;
      flags = "-k -p --utc";
    };
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
        "x-systemd.automount" # only mount when requested
      ];
    };
  };
  swapDevices = [
    {
      device = "/dev/disk/by-id/nvme-Samsung_SSD_980_500GB_S64DNF0R716712D-part2";
    }
  ];
  system.stateVersion = "23.11";
}
