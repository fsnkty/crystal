_: {
  system = {
    cleanup = true;
    nix = true;
    nz = true;
    desktop = {
      darkmode = true;
      fonts = true;
      audio = true;
      plymouth = true;
      hyprland = {
        enable = true;
        greetd-autologin = true;
      };
    };
  };

  users = {
    mainSetup = true;
    disableRoot = true;
    shell = {
      setup = true;
      prompt = "'%F{red}%m%f %~ %# '";
    };
    git.setup = true;
  };
  networking.networkmanager.enable = true;
  server.networking.ssh = true;
  # fingerprint scanner
  nixpkgs.overlays = [
    (final: prev: {
      libfprint = prev.libfprint.overrideAttrs (old: {
        pname = "libfprint-vfs009x";
        # version = "1.94.9+vfs009x";
        src = final.fetchgit {
          url = "https://gitlab.archlinux.org/gugah/libfprint.git";
          rev = "450e6aea0f5c92b3719d910c0defb2c85b0746df"; # refs/head/vfs009x
          sha256 = "sha256-Rm62zo2PRO1GlN8I9+r7MOl9q4AlUixrD1Y13Of8Xmw=";
        };
        buildInputs = (old.buildInputs or [ ]) ++ [ final.nss ];
        # Keep any patches Nixpkgs already applies to libfprint
        patches = old.patches or [ ];
      });
    })
  ];
  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };
  services.fprintd = {
    enable = true;
    tod.enable = false;
  };
  # rest of hardware
  boot = {
    zswap.enable = true;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelModules = [ "kvm-intel" ];
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "usb_storage"
      "sd_mod"
      "rtsx_pci_sdmmc"
    ];
  };
  hardware = {
    cpu.intel.updateMicrocode = true;
    enableRedistributableFirmware = true;
  };
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/2906-7F1F";
      fsType = "vfat";
      options = [
        "rw"
        "noatime"
        "fmask=0077"
        "dmask=0077"
        "x-systemd.automount" # only mount when requested
      ];
    };
    "/" = {
      device = "/dev/disk/by-uuid/30981d97-ba12-4c25-9e69-ff8874a2d9d2";
      fsType = "ext4";
    };
  };
  swapDevices = [
    { device = "/dev/disk/by-uuid/238ef32e-be79-4dce-8fd9-c1a5a9b39f9e"; }
  ];
  system.stateVersion = "25.05";
}
