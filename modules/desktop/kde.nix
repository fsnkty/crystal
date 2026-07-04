{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.crystal.desktop.kde;

  inherit (pkgs) kdePackages;
  inherit (lib)
    getBin
    mkDefault
    mkIf
    mkMerge
    mkOption
    optional
    optionals
    types
    ;

  activationScript = ''
    # will be rebuilt automatically
    rm -fv "''${XDG_CACHE_HOME:-$HOME/.cache}/ksycoca"*
  '';
in
{
  options.crystal.desktop.kde = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable the Plasma 6 (KDE 6) desktop environment.";
    };
    manageKCM = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      nixpkgs.overlays = [
        (final: prev: {
          kdePackages = prev.kdePackages.overrideScope (
            kdeFinal: kdePrev: {
              # https://old.reddit.com/r/NixOS/comments/1pdtc3v/kde_plasma_is_slow_compared_to_any_other_distro/
              # https://github.com/NixOS/nixpkgs/issues/126590#issuecomment-3194531220
              plasma-workspace =
                let
                  basePkg = kdePrev.plasma-workspace;
                  # a helper package that merges all the XDG_DATA_DIRS into a single directory
                  xdgdataPkg = final.stdenv.mkDerivation {
                    name = "${basePkg.name}-xdgdata";
                    buildInputs = [ basePkg ];
                    dontUnpack = true;
                    dontFixup = true;
                    dontWrapQtApps = true;
                    installPhase = ''
                      mkdir -p $out/share
                      ( IFS=:
                        for DIR in $XDG_DATA_DIRS; do
                          if [[ -d "$DIR" ]]; then
                            ${prev.lib.getExe prev.lndir} -silent "$DIR" $out
                          fi
                        done
                      )
                    '';
                  };
                  derivedPkg = basePkg.overrideAttrs (oldAttrs: {
                    # undo the XDG_DATA_DIRS injection that is usually done in the qt wrapper
                    # script and instead inject the path of the above helper package
                    preFixup = ''
                      for index in "''${!qtWrapperArgs[@]}"; do
                        if [[ ''${qtWrapperArgs[$((index+0))]} == "--prefix" ]] && [[ ''${qtWrapperArgs[$((index+1))]} == "XDG_DATA_DIRS" ]]; then
                          unset -v "qtWrapperArgs[$((index+0))]"
                          unset -v "qtWrapperArgs[$((index+1))]"
                          unset -v "qtWrapperArgs[$((index+2))]"
                          unset -v "qtWrapperArgs[$((index+3))]"
                        fi
                      done
                      qtWrapperArgs=("''${qtWrapperArgs[@]}")
                      qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "${xdgdataPkg}/share")
                      qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "$out/share")
                    '';
                  });
                in
                derivedPkg;
            }
          );
        })
      ];
      qt.enable = true;
      programs.xwayland.enable = true;
      environment.systemPackages =
        let
          inherit (config)
            services
            hardware
            networking
            powerManagement
            ;
        in
        (builtins.attrValues {
          inherit (kdePackages)
            qtwayland# Hack? To make everything run on Wayland
            qtsvg# Needed to render SVG icons

            # Frameworks with globally loadable bits
            frameworkintegration# provides Qt plugin
            kauth# provides helper service
            kcoreaddons# provides extra mime type info
            kded# provides helper service
            kfilemetadata# provides Qt plugins
            kguiaddons# provides geo URL handlers
            kiconthemes# provides Qt plugins
            kimageformats# provides Qt plugins
            qtimageformats# provides optional image formats such as .webp and .avif
            kio# provides helper service + a bunch of other stuff
            kio-admin# managing files as admin
            kio-extras# stuff for MTP, AFC, etc
            kpackage# provides kpackagetool tool
            kservice# provides kbuildsycoca6 tool
            plasma-activities# provides plasma-activities-cli tool
            solid# provides solid-hardware6 tool

            # Core Plasma parts
            kwin
            kscreen
            libkscreen
            kscreenlocker
            kactivitymanagerd
            kde-cli-tools
            kglobalacceld# keyboard shortcut daemon
            kwrited# wall message proxy, not to be confused with kwrite
            kdegraphics-thumbnailers# pdf etc thumbnailer
            polkit-kde-agent-1# polkit auth ui
            plasma-desktop
            plasma-workspace
            kde-inotify-survey# warns the user on low inotifywatch limits

            # Application integration
            libplasma# provides Kirigami platform theme
            plasma-integration# provides Qt platform theme
            kde-gtk-config# syncs KDE settings to GTK

            # Plasma utilities
            ksystemstats
            libksysguard
            systemsettings
            kcmutils

            # "optional"
            gwenview
            dolphin
            spectacle
            ffmpegthumbs
            kconfig# required for xdg-terminal from xdg-utils
            qtbase# for qtpaths which is required for xdg-mime from xdg-utils
            # kwallet
            kwallet
            kwallet-pam
            kwalletmanager
            drkonqi
            ;
        })
        ++ [
          pkgs.hicolor-icon-theme # fallback icons
          pkgs.xdg-user-dirs # recommended upstream
          (getBin kdePackages.qttools) # Expose qdbus in PATH
        ]
        # Optional and hardware support features
        ++ optionals hardware.bluetooth.enable [
          kdePackages.bluedevil
          kdePackages.bluez-qt
        ]
        ++ optionals networking.networkmanager.enable [
          kdePackages.qrca
          kdePackages.plasma-nm
        ]
        ++ optional hardware.sensor.iio.enable kdePackages.qtsensors
        ++ optional services.pulseaudio.enable kdePackages.plasma-pa
        ++ optional services.pipewire.pulse.enable kdePackages.plasma-pa
        ++ optional powerManagement.enable kdePackages.powerdevil
        ++ optional services.printing.enable kdePackages.print-manager
        ++ optional hardware.sane.enable kdePackages.skanpage
        ++ optional services.colord.enable kdePackages.colord-kde
        ++ optional services.hardware.bolt.enable kdePackages.plasma-thunderbolt
        ++ optional services.samba.enable kdePackages.kdenetwork-filesharing
        ++ optional services.xserver.wacom.enable kdePackages.wacomtablet;

      # FIXME: modules should link subdirs of `/share` rather than relying on this
      environment = {
        pathsToLink = [
          "/share"
          "/libexec" # drkonqi
        ];
        etc."X11/xkb".source = config.services.xserver.xkb.dir;
      };
      systemd = {
        services = {
          # when changing an account picture the accounts-daemon reads a temporary file containing the image which systemsettings5 may place under /tmp
          accounts-daemon.serviceConfig.PrivateTmp = false;
          # allow luks to unlock kwallet
          plasmalogin.serviceConfig.KeyringMode = "inherit";
          "drkonqi-coredump-processor@".wantedBy = [ "systemd-coredump@.service" ];
        };
        packages = [ kdePackages.drkonqi ];
        # FIXME: ugly hack. See #292632 in nixpkgs for details.
        user.services.nixos-rebuild-sycoca = {
          description = "Rebuild KDE system configuration cache";
          wantedBy = [ "graphical-session-pre.target" ];
          serviceConfig.Type = "oneshot";
          script = activationScript;
        };
      };
      system.userActivationScripts.rebuildSycoca = activationScript;

      xdg = {
        portal = {
          enable = true;
          extraPortals = [
            kdePackages.xdg-desktop-portal-kde
            pkgs.xdg-desktop-portal-gtk
            kdePackages.kwallet
          ];
          configPackages = mkDefault [ kdePackages.plasma-workspace ];
        };
      };
      programs = {
        gnupg.agent.pinentryPackage = mkDefault pkgs.pinentry-qt;
        kde-pim.enable = mkDefault true;
        ssh.askPassword = mkDefault "${kdePackages.ksshaskpass.out}/bin/ksshaskpass";
      };
      services = {
        pipewire.enable = mkDefault true;
        displayManager = {
          sessionPackages = [ kdePackages.plasma-workspace.sessions ];
          defaultSession = mkDefault "plasma";
        };
        # Extra UDEV rules used by Solid
        udev.packages = [
          # libmtp has "bin", "dev", "out" outputs. UDEV rules file is in "out".
          pkgs.libmtp.out
          pkgs.media-player-info
        ];
        # Enable helpful DBus services.
        accounts-daemon.enable = true;
        power-profiles-daemon.enable = mkDefault true;
        system-config-printer.enable = mkIf config.services.printing.enable (mkDefault true);
        udisks2.enable = true;
        upower.enable = config.powerManagement.enable;
        libinput.enable = mkDefault true;
        geoclue2.enable = mkDefault true;
        fwupd.enable = mkDefault true;
      };

      security = {
        pam.services = {
          kde = {
            allowNullPassword = true;
            # "kde" must not have fingerprint authentication otherwise it can block password login.
            # See https://github.com/NixOS/nixpkgs/issues/239770 and https://invent.kde.org/plasma/kscreenlocker/-/merge_requests/163.
            fprintAuth = false;
            p11Auth = false;
          };
          kde-fingerprint = mkIf config.services.fprintd.enable {
            fprintAuth = true;
            p11Auth = false;
          };
          kde-smartcard = mkIf config.security.pam.p11.enable {
            p11Auth = true;
            fprintAuth = false;
          };
          # kwallet
          login.kwallet = {
            enable = true;
            package = kdePackages.kwallet-pam;
          };
          kde.kwallet = {
            enable = true;
            package = kdePackages.kwallet-pam;
          };
          # unlock with luks
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
            source = "${getBin pkgs.kdePackages.kwin}/bin/kwin_wayland";
          };
          ksystemstats_intel_helper = {
            owner = "root";
            group = "root";
            capabilities = "cap_perfmon+ep";
            source = "${pkgs.kdePackages.ksystemstats}/libexec/ksystemstats_intel_helper";
          };
          ksgrd_network_helper = {
            owner = "root";
            group = "root";
            capabilities = "cap_net_raw+ep";
            source = "${pkgs.kdePackages.libksysguard}/libexec/ksysguard/ksgrd_network_helper";
          };
        };
      };

    })
    (mkIf cfg.manageKCM {
      environment.etc."xdg/kdeglobals".text =
        lib.generators.toINI
          {
            # avoid the generator escaping inner "]["
            mkSectionName = name: name;
          }
          {
            # list from "kcmshell6 --list" as of kcmshell6 6.27.0
            # a form of alert when kcmshell6 updates could help keep track of new/removed entries to this list.
            "KDE Control Module Restrictions][$i" = {
              kcm_baloofile = builtins.elem kdePackages.baloo config.environment.systemPackages;
              kcm_bluetooth = config.hardware.bluetooth.enable;
              # theme related.
              kcm_lookandfeel = config.crystal.desktop.theme.enable;
              kcm_cursortheme = config.crystal.desktop.theme.enable;
              kcm_desktoptheme = config.crystal.desktop.theme.enable;
              kcm_splashscreen = config.crystal.desktop.theme.enable;
              kcm_style = config.crystal.desktop.theme.enable;
              kcm_icons = config.crystal.desktop.theme.enable;
              kcm_soundtheme = config.crystal.desktop.theme.enable;
              #kcm_desktoppaths = # xdg-user-dirs related
              #kcm_recentFIles = # potential xdg dep
              #kcm_webshortcuts = # likely xdg dep
              kcm_feedback = false; # this module does not behave how upstream would expect at all, feedback is likely useless.
              kcm_fontinst = false; # `fonts.*` instead.
              kcm_fonts = false; # above
              kcm_mobile_power = config.services.power-profiles-daemon.enable;
              kcm_nighttime = builtins.elem kdePackages.knighttime config.environment.systemPackages;
              #kcm_plasmalogin = # plasma-login-manager?
              #kcm_plasmasearch = # baloo? milou? krunner?
              kcm_powerdevilprofilesconfig = config.services.power-profiles-daemon.enable;
              kcm_pulseaudio = config.services.pulseaudio.enable || config.services.pipewire.pulse.enable;
              #kcm_qtquicksettings = # user pref
              kcm_regionandlang = false; # shouldnt be touched
              #kcm_screenlocker = # includes relavent deps
              kcm_users = config.users.mutableUsers;
              kcm_virtualkeyboard = false; # depdend on relavent deps being included
              #kcmspellchecking = # maybe dep on dictionaries being available
            };
          };
    })
  ];
}
