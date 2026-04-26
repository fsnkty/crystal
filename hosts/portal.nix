{ config, pkgs, ... }:
{
  system = {
    lockdown = true;
    cleanup = true;
    nix = true;
    nz = true;
    plymouth.setup = true;
  };
  shell.setup = true;

  vscode.remote.setup = true;

  users.users.main = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILzo6UVJ72vS2sNW20QjMCmfCeChGPUT4YfY8VHiMVjv fsnkty@factory"
    ];
    isNormalUser = true;
    name = "fsnkty";
    description = "Madison";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = builtins.attrValues {
      inherit (pkgs) alacritty chromium;
    };
  };

  programs = {
    hyprland.enable = true;
    hyprlock.enable = true;
  };
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "start-hyprland > /dev/null";
      user = config.users.users.main.name;
    };
  };
  console = {
    font = "${pkgs.terminus_font}/share/consolefonts/ter-116n.psf.gz";
  };
  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        settings."org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          font-name = "SF Pro Text 12";
          monospace-font-name = "Liga SFMono Nerd Font";
          document-font-name = "SF Pro Text 12";
        };
      }
    ];
  };
  environment.etc = {
    "xdg/gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-application-prefer-dark-theme=1
      gtk-font-name=SF Pro Text 12
    '';
  };
  qt = {
    enable = true;
    style = "adwaita-dark";
  };

  services = {
    openssh.enable = true;
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
        patches = (old.patches or [ ]);
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
    plymouth = {
      enable = true;
    };
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
