{
  pkgs,
  lib,
  config,
  ...
}:
{
  _user = {
    immutable = true;
    disableRoot = true;
    main = {
      enable = true;
      shell = true;
      packages = builtins.attrValues {
        inherit (pkgs)
          colmena
          age
          krita
          ueberzugpp
          chromium
          vscodium
          vim
          teams-for-linux
          element-desktop
          ;
        vesktop = pkgs.vesktop.override { withTTS = false; };
      };
    };
  };
  _programs = {
    steam = true;
    prismlauncher = true;
    alacritty = true;
    git = true;
    ssh = true;
    htop = true;
  };
  _homeFile =
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
  _system = {
    nix.config = true;
    cleanup = true;
    timeZone.NZ = true;
    setHostKey = true;
    wired = {
      enable = true;
      ip = "192.168.0.4";
      name = "enp39s0";
    };
    desktop = {
      kde = true;
      rgb = true;
      gtk = true;
      audio = true;
      fonts = true;
      plymouth = true;
      noNetBoot = true;
    };
  };
  networking = {
    hostName = "factory";
    hostId = "007f0200";
  };
  zramSwap.enable = true;
  powerManagement.cpuFreqGovernor = "schedutil";
  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = true;
  };
  boot = {
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    kernelModules = [
      "kvm-amd"
      "amd_pstate"
      "amdgpu"
    ];
    kernelParams = [ "amd_pstate=guided" ];
    loader = {
      timeout = 0; # hold space to open the menu.
      systemd-boot.enable = true;
    };
    initrd.systemd.enable = true;
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
  };
  system.stateVersion = "23.11";
}
