{ pkgs, ... }:
{
  common = {
    lockdown = true;
    cleanup = true;
    nix = true;
    nz = true;
    shell.enable = true;
  };

  users.users.main = {
    isNormalUser = true;
    name = "fsnkty";
    description = "Madison";
    extraGroups = [ "networkmanager" "wheel" ];
  };
  programs.hyprland.enable = true;
  services = {
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
  };
  security.rtkit.enable = true;

  networking = {
    hostName = "portal";
    networkmanager.enable = true;
  };

  # finger print setup
  systemd.services.fprintd = {
    wantedBy = ["multi-user.target"];
    serviceConfig.Type = "simple";
  };
  nixpkgs.overlays = [
    (final: prev: {
      # Use gugah's libfprint fork with vfs009x support
      libfprint = prev.libfprint.overrideAttrs (old: rec {
        pname = "libfprint-vfs009x";

        # This is just cosmetic; set it to something that helps you remember
        version = "1.94.9+vfs009x";

        # Use the values from:
        #   nix-prefetch-git --url https://gitlab.archlinux.org/gugah/libfprint.git \
        #                    --rev refs/heads/vfs009x
        src = final.fetchgit {
          url    = "https://gitlab.archlinux.org/gugah/libfprint.git";
          rev    = "450e6aea0f5c92b3719d910c0defb2c85b0746df";
          sha256 = "sha256-Rm62zo2PRO1GlN8I9+r7MOl9q4AlUixrD1Y13Of8Xmw=";
        };
    buildInputs = (old.buildInputs or [ ]) ++ [ final.nss ];

        # Keep any patches Nixpkgs already applies to libfprint
        patches = (old.patches or [ ]);
      });

      # Optionally expose it explicitly as a separate name too
      libfprint-vfs009x = final.libfprint;
    })
  ];
  services.fprintd = {
    enable = true;
    tod.enable = false;
  };
  # rest of hardware
  boot = {
    plymouth = {
      enable = true;
    };
    zswap.enable = true;
    loader = {
      timeout = 0;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-intel" ];
    kernelParams = [
      "quiet"
      "udev.log_level=3"
      "systemd.show_status=auto"
    ];
    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
      systemd.enable = true;
      verbose = false;
    };
    consoleLogLevel = 3;
  };
  hardware = {
    cpu.intel.updateMicrocode = true;
    enableRedistributableFirmware = true;
  };
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/2906-7F1F";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
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
