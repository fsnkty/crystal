#nixos-rebuild switch --target-host library --flake .#library --sudo --ask-sudo-password
{ pkgs, lib, ... }: {
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
      dataDir = "/storage/gtnh";
      openFirewall = true;
    };
    media = {
      group = true;
      jellyfin = true;
      qbit = true;
    };
    networking = {
      nginx = true;
      samba = true;
      ssh = {
        enable = true;
        headless = true;
      };
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
  };

  services.openssh.hostKeys = [{
    comment = "library host";
    path = "/etc/ssh/library_ed25519_key"; # library priv
    type = "ed25519";
  }];
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
      routes = [{ Gateway = "192.168.0.1"; }];
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
      device =
        "/dev/disk/by-id/nvme-Samsung_SSD_980_500GB_S64DNF0R716712D-part1";
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
  swapDevices = [{
    device = "/dev/disk/by-id/nvme-Samsung_SSD_980_500GB_S64DNF0R716712D-part2";
  }];
  system.stateVersion = "23.11";
}
