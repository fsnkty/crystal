# Only NixOS modules see the shims (via _module.args.pkgs), so nothing you
# build with pkgs.callPackage / overlays gets recompiled against them.
{ modulesPath
, config
, lib
, ...
}:

let
  cfg = config.laminix;

  # The package set as it would be without this module's pkgs override.
  # Shims are built from this one, so they can't depend on themselves.
  # Built like nixos/modules/misc/nixpkgs.nix builds its default set; the
  # public config.nixpkgs.pkgs is only a user-supplied override.
  base =
    let
      inherit (config.nixpkgs) hostPlatform buildPlatform;
    in
    import (modulesPath + "/../..") (
      { inherit (config.nixpkgs) config overlays; }
      // (
        if buildPlatform != hostPlatform
        then { localSystem = buildPlatform; crossSystem = hostPlatform; }
        else { localSystem = hostPlatform; }
      )
    );

  # Paths left out of the profile layers. A wrapper showed a dependency's
  # dirs to one program, but daemons, shells, menus, the session and the
  # Vulkan loader read these straight from the profile, so folding them in
  # would register that dependency's services, shortcuts, menu entries,
  # login scripts, Vulkan layers and completions for everyone. Each entry
  # names one directory or file directly below a searched path.
  exclude = [
    "share/dbus-1"
    "share/systemd"
    "share/polkit-1"
    "share/xdg-desktop-portal"
    "share/wayland-sessions"
    "share/xsessions"
    "share/applications"
    "share/desktop-directories"
    "share/kglobalaccel"
    "share/krunner"
    "share/kio"
    "share/solid"
    "share/kconf_update"
    "share/user-tmpfiles.d"
    "share/vulkan"
    "etc/xdg/autostart"
    "etc/xdg/systemd"
    "etc/xdg/menus"
    "etc/xdg/plasma-workspace"
    "etc/xdg/mimeapps.list"
    "share/fish"
    "share/bash-completion"
    "share/zsh"
  ];

  # Wrappers set NIXPKGS_QT*_QML_IMPORT_PATH; the session sets QML2_IMPORT_PATH.
  session = config.environment.profileRelativeSessionVariables;
  qml = session.QML2_IMPORT_PATH or [ ];

  # PATH stays in the wrappers: folding it into the profile would put every
  # dependency's commands on everyone's PATH.
  searchedVars = removeAttrs
    (session // {
      NIXPKGS_QT5_QML_IMPORT_PATH = qml;
      NIXPKGS_QT6_QML_IMPORT_PATH = qml;
    })
    [ "PATH" ];

  # "VAR:relative/dir" pairs the session already searches in the profile.
  pairs = lib.concatLists (
    lib.mapAttrsToList (var: map (s: "${var}:${lib.removePrefix "/" s}")) searchedVars
  );

  # Profile dirs those pairs point at. Shims drop whole package dirs, so the
  # profile must link them whole.
  searched = map (p: "/" + lib.last (lib.splitString ":" p)) pairs;

  # Nothing runs from these outputs, so a shim doesn't read them.
  passthroughOutputs = [ "dev" "debug" "devdoc" "devtools" "python" ];

  shim =
    pkg:
    let
      outputs = lib.subtractLists passthroughOutputs pkg.outputs;
      forwarded = lib.intersectLists passthroughOutputs pkg.outputs;
      toInstall = lib.intersectLists outputs (pkg.meta.outputsToInstall or [ ]);
    in
    base.runCommandLocal pkg.name
      {
        inherit outputs;
        srcPaths = map (o: "${pkg.${o}}") outputs; # index-aligned with `outputs`
        pairs = toString pairs;
        exclude = toString exclude;
        inherit (base.makeBinaryWrapper) extractCmd;
        # 26.05's extractCmd runs strings from PATH.
        nativeBuildInputs = [
          base.makeBinaryWrapper
          base.binutils-unwrapped
        ];

        # Never name an output the shim doesn't have. If nothing is left,
        # mkDerivation falls back to its own default.
        meta =
          removeAttrs pkg.meta [ "outputsToInstall" ]
          // lib.optionalAttrs (toInstall != [ ]) { outputsToInstall = toInstall; };

        passthru =
          (pkg.passthru or { })
          // lib.getAttrs forwarded pkg # pkg.dev etc. still resolve, to the original
          // lib.intersectAttrs { pname = null; version = null; } pkg
          // {
            plasmaLamina = true;
            plasmaLaminaOriginal = pkg;
          };
      }
      ''
        # makeBinaryWrapper is a shell function of this builder; export the
        # functions so the script's bash children can call it.
        for fn in $(declare -F | cut -d' ' -f3); do export -f "$fn" || true; done
        ${base.python3.interpreter} ${./shim.py}
      '';

  # Re-shim anything derived from a shim, so overrides can't silently
  # hand back the unshimmed original.
  install =
    pkg:
    shim pkg
    // lib.optionalAttrs (pkg ? override) {
      override = args: install (pkg.override args);
    }
    // lib.optionalAttrs (pkg ? overrideAttrs) {
      overrideAttrs = f: install (pkg.overrideAttrs f);
    };

  # A typo in laminix.packages fails evaluation rather than being skipped.
  shimmed = lib.updateManyAttrsByPath
    (map
      (p: {
        path = lib.splitString "." p;
        update = install;
      })
      (lib.unique cfg.packages))
    base;
in
{
  options.laminix = {
    enable = lib.mkEnableOption "plasma-lamina package shims";
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = map (p: "kdePackages.${p}") [
        "plasma-workspace"
        "kio"
        "kio-extras"
        "kded"
        "kservice"
        "kconfig"
        "kiconthemes"
        "kfilemetadata"
        "kglobalacceld"
        "kactivitymanagerd"
        "libksysguard"
        "ksystemstats"
        "kcmutils"
        "kscreen"
        "dolphin"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    _module.args.pkgs = lib.mkOverride 99 shimmed;
    environment.pathsToLink = searched;
  };
}
