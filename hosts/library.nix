{ pkgs, config, ... }:
{
  misc = {
    nix = {
      config = true;
      flakePath = "/storage/repos/crystal";
      nh = true;
    };
    shell = {
      enable = true;
      prompt = "'%F{magenta}圖書館%F{reset_color} %~ %% '";
    };
    ageSetup = true;
    cleanDefaults = true;
    disableRoot = true;
  };
  service = {
    web = {
      enable = true;
      domain = "nuko.city";
      forgejo = true;
      jellyfin = true;
      qbit = true;
      nextcloud = true;
      vaultwarden = true;
      matrixhome = true;
      navidrome = true;
      komga = true;
    };
    fail2ban = true;
    postgres = true;
    mailserver = true;
    openssh = true;
  };
  program = {
    htop = true;
    neovim = true;
    git = true;
  };
  ### misc
  time.timeZone = "NZ";
  i18n.defaultLocale = "en_NZ.UTF-8";
  security.sudo.execWheelOnly = true;
  ### management user stuff
  age.secrets.user = {
    file = ../shhh/user.age;
    owner = config.users.users.main.name;
  };
  users = {
    groups.media = { };
    mutableUsers = false;
    users = {
      main = {
        name = "nuko";
        uid = 1000;
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "media"
        ];
        hashedPasswordFile = config.age.secrets.user.path;
        packages = builtins.attrValues {
          inherit (pkgs)
            wget
            rsync
            eza
            yazi
            ;
        };
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBN4+lDQxOfTVODQS4d3Mm+y3lpzpsSkwxjbzN4NwJlJ" # factory
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIrSQqI/X+I9fcQGOxgvTzZ2p/9SG4abc4xXkrAdRxBc" # lunar
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJZH8voUTYblnUaSThDyB+JrdFTVMVVxT4kA+EE+XrCG" # orbit
        ];
      };
    };
  };
  ### hardware
  networking = {
    hostName = "library";
    hostId = "9a350e7b";
    firewall.enable = true;
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
