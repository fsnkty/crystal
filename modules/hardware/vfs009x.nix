{ config, lib, ... }:
{
  options.crystal.system.hardware.vfs009x = lib.mkEnableOption "";
  config = lib.mkIf config.crystal.system.hardware.vfs009x {
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
  };
}
