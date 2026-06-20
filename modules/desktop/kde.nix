# largely a stripped back copy of
# https://github.com/NixOS/nixpkgs/blob/bb38195945cf64396b4997e3c84703b519be86b0/nixos/modules/services/desktop-managers/plasma6.nix
# re-implamenting locally to seperate concerns and remove some more "core" features
# use cases I dont have etc.
{ config
, lib
, pkgs
, ...
}:
{
  options.crystal.desktop.kde.enable = lib.mkEnableOption "";
  config = lib.mkIf config.crystal.desktop.kde.enable {
    nixpkgs.overlays = [
      (final: prev: {
        kdePackages = prev.kdePackages // {
          # remove plastik
          breeze = prev.kdePackages.breeze.overrideAttrs (oldAttrs: {
            postInstall = (oldAttrs.postInstall or "") + ''
              find $out -type d -name "plastik" -exec rm -rf {} +
            '';
          });
        };
      })
    ];
    # packages
    environment.systemPackages = [
      pkgs.xdg-user-dirs
      (lib.getBin pkgs.kdePackages.qttools)
    ] ++ builtins.attrValues {
      inherit (pkgs.kdePackages)
        # "requiredPackages"
        qtwayland# "Hack? To make everything run on Wayland"
        qtsvg# "Needed to render SVG icons"

        # "Framewprls with globally loadable bits"
        frameworkintegration# "provides Qt plugin" seems to be for QT apps to integrate with KDE more
        kauth# "provides helper service" privilege elevation
        kcoreaddons# "provides extra mime type info" seemingly does various file and text manip
        kded# "provides helper service" handles various background helper services, "KDED stands for KDE Daemon"
        kfilemetadata# "provides Qt plugins"
        kguiaddons# "provides geo URL handlers"
        kiconthemes# "provides Qt plugins"
        kimageformats# "provides Qt plugins"
        qtimageformats# "provides optional image formats such as .webp and .avif"
        kio# "helper service + a bunch of other stuff"
        kio-admin# "managing files as admin"
        #kio-extras # "MTP, AFC, etc"
        #kio-fuse # above for FUSE
        #knighttime # "night mode switching daemon" can probably be removed.
        kpackage# "provides kpackage tool
        kservice# "provides kbuildsyscoco6 tool"
        # kunifiedpush # "provides a background service and a KCM" seemingly requires manual setup and is only useful for select services? shouldnt be related to general notifications.
        kwallet# "provides helper service"
        kwallet-pam# "provides helper service"
        #kwalletmanager # "provides KCMs and stuff"
        plasma-activities# "provides plasma-activities-cli tool"
        solid# "provides solid-hardware6 tool" various hardware reading capabilities
        #phonon-vlc # "provides Phonon plugin" "multi-platform sound framework for application developers"

        # "Core Plasma parts"
        kwin# compositor / window management
        kscreen# screen management
        libkscreen# above lib
        kscreenlocker
        kactivitymanagerd
        # kde-cli-tools provides
        # keditfiletype, keditfiletype5, kinfo, kioclient, kioclient5
        # kmimetypefinder, kmimetypefinder5, kstart, kstart5, ksvgtopng, ksvgtopng5, plasma-open-settings
        kglobalacceld# "keyboard shorecut daemon"
        kwrited# "wall message proxy, not to be confused with kwrite"
        baloo# "system indexer"
        milou# "search engine atop baloo"
        kdegraphics-thumbnailers# "pdf etc thumbnailer"
        polkit-kde-agent-1# "polkit auth ui"
        plasma-desktop
        plasma-workspace
        drkonqi# "crash handler"
        kde-inotify-survey# "warns the user on low inotifywatch limits" inotify is related to filesystem events.

        # "Application integration"
        libplasma# "provides kirigami platform theme"
        plasma-integration# "provides Qt platform theme"
        kde-gtk-config# "syncs KDE settings to GTK"

        # "Artwork + themes"
        breeze
        breeze-icons
        breeze-gtk
        ocean-sound-theme
        # same theme, different framework? 
        qqc2-breeze-style
        qqc2-desktop-style

        #kdeplasma-addons # heavy package, should look into stripping

        systemsettings# settings app
        kcmutils# utilities for modules

        # "optional Packages"
        ark# gui 7zip? maybe useful ig
        gwenview# photo viewer
        dolphin# file manager
        spectacle# screenshots
        ffmpegthumbs# makes thumbnails of videos, prob just a dolphin dep
        kconfig# required for xdg-terminal from xdg-utils
        qtbase# for qtpaths which is required for xdg-mime from xdg-utils

        # union # only in master as of commit, this is a unified qt style handler

        # bluetooth
        bluedevil
        bluez-qt
        # plasma-nm # network manager
        plasma-pa# pulseaudio integ
        ;
    };
    environment = {
      pathsToLink = [
        # FIXME: modules should link subdirs of `/share` rather than relying on this
        "/share"
        "/libexec" # for drkonqi
      ];
      etc."X11/xkb".source = config.services.xserver.xkb.dir;
      sessionVariables = {
        XDG_CONFIG_DIRS = [ "$HOME/.config/kdedefaults" ];
        KPACKAGE_DEP_RESOLVERS_PATH = "${pkgs.kdePackages.frameworkintegration.out}/libexec/kf6/kpackagehandlers";
      };
    };

    qt = {
      enable = true;
      style = "breeze";
      platformTheme = "kde";
    };

    programs = {
      xwayland.enable = true;
      # "Enable GTK applications to load SVG icons"
      gdk-pixbuf.modulePackages = [ pkgs.librsvg ];
      gnupg.agent.pinentryPackage = pkgs.pinentry-qt;
      # kde-pim.enable = true; # packages for kmail kontact and the like
      ssh.askPassword = "${pkgs.kdePackages.ksshaskpass.out}/bin/ksshaskpass";
      dconf.enable = true;
      kdeconnect.package = pkgs.kdePackages.kdeconnect-kde;
      #chromium = {
      #  enablePlasmaBrowserIntegration = true;
      #  plasmaBrowserIntegrationPackage = pkgs.kdePackages.plasma-browser-integration;
      #};
    };

    xdg = {
      icons = {
        enable = true;
        fallbackCursorThemes = [ "breeze_cursors" ];
      };
      portal = {
        enable = true;
        extraPortals = [
          pkgs.kdePackages.kwallet
          pkgs.kdePackages.xdg-desktop-portal-kde
          pkgs.xdg-desktop-portal-gtk
        ];
        configPackages = [ pkgs.kdePackages.plasma-workspace ];
      };
    };

    services = {
      displayManager = {
        plasma-login-manager.enable = true;
        sessionPackages = [ pkgs.kdePackages.plasma-workspace.sessions ];
        defaultSession = "plasma";
      };
      # "Enable helpful DBus services."
      accounts-daemon.enable = true;
      power-profiles-daemon.enable = true;
      udisks2.enable = true;
      libinput.enable = true;
      geoclue2.enable = true;
      fwupd.enable = true;
      udev.packages = [
        # extras used by Solid
        pkgs.libmtp.out
        pkgs.media-player-info
      ];
    };

    systemd = {
      packages = [ pkgs.kdePackages.drkonqi ];
      services = {
        "drkonqi-coredump-processor@".wantedBy = [ "systemd-coredump@.service" ];
        # needs to read tmp pfp img
        accounts-daemon.serviceConfig.PrivateTmp = false;
        plasmalogin.serviceConfig.KeyringMode = "inherit";
      };
      user.services.nixos-rebuild-sycoca = {
        description = "Rebuild KDE system configuration cache";
        wantedBy = [ "graphical-session-pre.target" ];
        serviceConfig.Type = "oneshot";
        script = ''
          rm -fv "''${XDG_CACHE_HOME:-$HOME/.cache}/ksycoca"*
        '';
      };
    };

    security = {
      login.kwallet = {
        enable = true;
        package = pkgs.kdePackages.kwallet-pam;
      };
      pam.services = {
        kde = {
          kwallet = {
            enable = true;
            package = pkgs.kdePackages.kwallet-pam;
          };
          # "kde" must not have fingerprint authentication otherwise it can block password login.
          # See https://github.com/NixOS/nixpkgs/issues/239770 and https://invent.kde.org/plasma/kscreenlocker/-/merge_requests/163.
          fprintAuth = false;
          p11Auth = false;
        };
        kde-fingerprint = lib.mkIf config.services.fprintd.enable {
          fprintAuth = true;
          p11Auth = false;
        };
        plasmalogin-autologin.rules.auth = {
          systemd_loadkey = {
            order = 0;
            control = "optional";
            modulePath = "${pkgs.systemd}/lib/security/pam_systemd_loadkey.so";
          };
          plasmalogin = {
            order = 1;
            control = "include";
            modulePath = "plasmalogin";
          };
        };
      };
      wrappers = {
        kwin_wayland = {
          owner = "root";
          group = "root";
          capabilities = "cap_sys_nice+ep";
          source = "${lib.getBin pkgs.kdePackages.kwin}/bin/kwin_wayland";
        };
      };
    };
  };
}
