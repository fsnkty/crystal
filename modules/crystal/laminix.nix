# a trimmed, standalone take on https://github.com/jackboykin/laminix
#
# What it does: Qt/KDE wrappers (makeBinaryWrapper) normally carry one
# --prefix/--suffix entry per dependency for XDG_DATA_DIRS, QT_PLUGIN_PATH,
# QML import paths and so on. Every lookup walks all of them. For each listed
# package this builds a "shim": the same package, symlinked, but with those
# wrapper entries removed. The directories they pointed at are added to the
# profile that installs the shim, which the session already searches.
#
# Only NixOS modules see the shims (via _module.args.pkgs), so nothing you
# build with pkgs.callPackage / overlays gets recompiled against them.
{ config
, options
, lib
, pkgs
, ...
}:

let
  cfg = config.environment.laminix;
  inherit (lib) mkOption types;

  # Wrappers set NIXPKGS_QT*_QML_IMPORT_PATH; the session sets QML2_IMPORT_PATH.
  aliases = {
    NIXPKGS_QT5_QML_IMPORT_PATH = "QML2_IMPORT_PATH";
    NIXPKGS_QT6_QML_IMPORT_PATH = "QML2_IMPORT_PATH";
  };

  # Folding PATH dirs into the profile would put every dependency's commands
  # on everyone's PATH, so PATH stays in the wrappers.
  keepVariables = [ "PATH" ];

  session = config.environment.profileRelativeSessionVariables;

  suffixes = removeAttrs
    (
      session // lib.mapAttrs (_: var: session.${var} or [ ]) aliases
    )
    keepVariables;

  # "VAR:relative/dir" pairs the session already searches in the profile.
  pairs = lib.concatLists (
    lib.mapAttrsToList (var: map (s: "${var}:${lib.removePrefix "/" s}")) suffixes
  );

  searched = lib.unique (map (p: lib.last (lib.splitString ":" p)) pairs);

  # The package set as it would be without this module's pkgs override.
  # Shims are built from this one, so they can't depend on themselves.
  args = options._module.args;
  base =
    (lib.modules.mergeAttrDefinitionsWithPrio (
      args
      // {
        definitionsWithLocations = lib.filter (d: d.file != __curPos.file) args.definitionsWithLocations;
      }
    )).pkgs.value;

  # Nothing runs from these outputs, so a shim doesn't read them.
  passthroughOutputs = [
    "dev"
    "debug"
    "devdoc"
    "devtools"
    "python"
  ];

  shim =
    pkg:
    let
      outputs = lib.subtractLists passthroughOutputs pkg.outputs;
    in
    base.runCommandLocal pkg.name
      {
        inherit outputs;
        srcPaths = map (o: "${pkg.${o}}") outputs;
        pairs = toString pairs;
        exclude = toString cfg.exclude;
        inherit (base.makeBinaryWrapper) extractCmd;
        # 26.05's extractCmd runs strings from PATH.
        nativeBuildInputs = [
          base.makeBinaryWrapper
          base.binutils-unwrapped
        ];
        passthru =
          (pkg.passthru or { })
          // lib.intersectAttrs
            {
              pname = null;
              version = null;
            }
            pkg
          // lib.genAttrs (lib.intersectLists passthroughOutputs pkg.outputs) (o: pkg.${o})
          // {
            plasmaLamina = true;
          };
        inherit (pkg) meta;
      }
      "source ${./shim.sh}";

  userPaths = map (lib.splitString ".") cfg.packages;
  paths = lib.unique userPaths;
  present = lib.filter (p: lib.hasAttrByPath p base) paths;

  install =
    pkg:
    shim pkg
    // lib.intersectAttrs
      {
        override = null;
        overrideAttrs = null;
      }
      pkg;

  shimmed = lib.updateManyAttrsByPath
    (map
      (path: {
        inherit path;
        update = install;
      })
      present)
    base;
in
{
  _file = __curPos.file;

  options.environment.laminix = {
    enable = lib.mkEnableOption "";
    packages = mkOption {
      type = types.listOf types.str;
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
    exclude = mkOption {
      type = types.listOf types.str;
      default = [
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
      description = ''
        Paths left out of the profile layers. A wrapper showed a dependency's
        dirs to one program, but daemons, shells, menus, the session and the
        Vulkan loader read these straight from the profile, so folding them in
        would register that dependency's services, shortcuts, menu entries,
        login scripts, Vulkan layers and completions for everyone. Each entry
        names one directory or file directly below a searched path.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    _module.args.pkgs = lib.mkOverride 99 shimmed;

    # Shims drop whole PKG/share dirs, so the profile must link them whole.
    environment.pathsToLink = lib.mkIf (present != [ ]) (map (s: "/${s}") searched);

    # Build-time guard: fail the system build, not the login session, if a
    # shim would split a KPackage or lose KWin's trust.
    environment.extraSetup = lib.mkIf (present != [ ]) ''
      extractCmd=${pkgs.makeBinaryWrapper.extractCmd}
      PATH=$PATH:${pkgs.buildPackages.binutils-unwrapped}/bin
      source ${./check-profile.sh}
    '';
  };
}
