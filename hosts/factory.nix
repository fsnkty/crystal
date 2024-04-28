{ pkgs, lib, ... }:
{
  _common = {
    nix = {
      config = true;
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
      ip = "192.168.0.4";
      name = "enp39s0";
    };
  };
  _user = {
    disableRoot = true;
    immutable = true;
    main = {
      enable = true;
      shell.setup = true;
      packages = builtins.attrValues {
        inherit (pkgs)
          element-desktop
          teams-for-linux
          krita
          imv
          mpv
          ueberzugpp
          osu-lazer
          ;
        vesktop = pkgs.vesktop.override { withTTS = false; };
      };
      loginKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFhTVx3lCAqu9xxn8kPwH0bl0Qg0cE6E0TSJILErD3mq" ];
    };
  };
  _programs = {
    firefox = true;
    steam = true;
    prismlauncher = true;
    git = true;
    ssh = true;
    neovim = true;
    htop = true;
  };
  _desktop.enable = true;
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
  ### networking
  networking = {
    hostName = "factory";
    hostId = "007f0200";
  };
  ### hardware
  zramSwap.enable = true;
  systemd = {
    services.systemd-udev-settle.enable = false;
    network.wait-online.enable = false;
  };
  powerManagement.cpuFreqGovernor = "schedutil";
  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = true;
  };
  boot = {
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
