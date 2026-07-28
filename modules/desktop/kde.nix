{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.crystal.desktop.kde;
  inherit (pkgs) kdePackages;
in
{
  options.crystal.desktop.kde.enable = lib.mkEnableOption "";
  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      (final: prev: {
        kdePackages = prev.kdePackages.overrideScope (
          kdeFinal: kdePrev: {
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
    environment.systemPackages =
      (builtins.attrValues {
        inherit (kdePackages)
          qtwayland # Hack? To make everything run on Wayland
          qtsvg # Needed to render SVG icons

          # Frameworks with globally loadable bits
          frameworkintegration # provides Qt plugin
          kauth # provides helper service
          kcoreaddons # provides extra mime type info
          kded # provides helper service
          kfilemetadata # provides Qt plugins
          kguiaddons # provides geo URL handlers
          kiconthemes # provides Qt plugins
          kimageformats # provides Qt plugins
          qtimageformats # provides optional image formats such as .webp and .avif
          kio # provides helper service + a bunch of other stuff
          kio-admin # managing files as admin
          kio-extras # stuff for MTP, AFC, etc
          kpackage # provides kpackagetool tool
          kservice # provides kbuildsycoca6 tool
          plasma-activities # provides plasma-activities-cli tool
          solid # provides solid-hardware6 tool

          # Core Plasma parts
          kwin
          kscreen
          libkscreen
          kscreenlocker
          kactivitymanagerd
          kde-cli-tools
          kglobalacceld # keyboard shortcut daemon
          kwrited # wall message proxy, not to be confused with kwrite
          kdegraphics-thumbnailers # pdf etc thumbnailer
          polkit-kde-agent-1 # polkit auth ui
          plasma-desktop
          plasma-workspace
          kde-inotify-survey # warns the user on low inotifywatch limits

          # Application integration
          libplasma # provides Kirigami platform theme
          plasma-integration # provides Qt platform theme
          # kde-gtk-config# syncs KDE settings to GTK # deps on xsettingsd, not needed after setting.

          # Plasma utilities
          ksystemstats
          libksysguard
          systemsettings
          kcmutils

          # "optional"
          gwenview
          dolphin
          ark
          spectacle
          ffmpegthumbs
          kconfig # required for xdg-terminal from xdg-utils
          qtbase # for qtpaths which is required for xdg-mime from xdg-utils
          # kwallet
          kwallet
          kwallet-pam
          kwalletmanager
          drkonqi

          # audio
          plasma-pa
          # power management
          powerdevil
          ;
      })
      ++ [
        pkgs.hicolor-icon-theme # fallback icons
        pkgs.xdg-user-dirs # recommended upstream
        (lib.getBin kdePackages.qttools) # Expose qdbus in PATH
      ]
      # Optional and hardware support features
      ++ lib.optionals config.hardware.bluetooth.enable [
        kdePackages.bluedevil
        kdePackages.bluez-qt
      ]
      ++ lib.optionals config.networking.networkmanager.enable [
        kdePackages.qrca
        kdePackages.plasma-nm
      ];

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
    };

    xdg = {
      portal = {
        enable = true;
        extraPortals = [
          kdePackages.xdg-desktop-portal-kde
          kdePackages.kwallet
        ];
        configPackages = [ kdePackages.plasma-workspace ];
      };
    };
    programs = {
      xwayland.enable = true;
      gnupg.agent.pinentryPackage = pkgs.pinentry-qt;
      kde-pim.enable = true;
      ssh.askPassword = "${kdePackages.ksshaskpass.out}/bin/ksshaskpass";
    };
    services = {
      power-profiles-daemon.enable = true;
      speechd.enable = lib.mkForce false;
      pipewire.enable = true;
      displayManager = {
        sessionPackages = [ kdePackages.plasma-workspace.sessions ];
        defaultSession = "plasma";
      };
      # Extra UDEV rules used by Solid
      udev.packages = [
        # libmtp has "bin", "dev", "out" outputs. UDEV rules file is in "out".
        pkgs.libmtp.out
        pkgs.media-player-info
      ];
      # Enable helpful DBus services.
      accounts-daemon.enable = true;
      udisks2.enable = true;
      upower.enable = config.powerManagement.enable;
      libinput.enable = true;
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
        kde-fingerprint = lib.mkIf config.services.fprintd.enable {
          fprintAuth = true;
          p11Auth = false;
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
      wrappers.kwin_wayland = {
        owner = "root";
        group = "root";
        capabilities = "cap_sys_nice+ep";
        source = "${lib.getBin pkgs.kdePackages.kwin}/bin/kwin_wayland";
      };
    };
  };
}
