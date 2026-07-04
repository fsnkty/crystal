{ config
, lib
, ...
}:
{
  options.crystal.system.nix.cafe = lib.mkEnableOption "";
  config = lib.mkIf config.crystal.system.nix.cafe {
    nixpkgs.overlays = [
      (self: super: {
        ccacheWrapper = super.ccacheWrapper.override {
          extraConfig = ''
            export CCACHE_COMPRESS=1
            export CCACHE_DIR="${config.programs.ccache.cacheDir}"
            export CCACHE_UMASK=007
            if [ ! -d "$CCACHE_DIR" ]; then
              echo "====="
              echo "Directory '$CCACHE_DIR' does not exist"
              echo "Please create it with:"
              echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
              echo "  sudo chown root:nixbld '$CCACHE_DIR'"
              echo "====="
              exit 1
            fi
            if [ ! -w "$CCACHE_DIR" ]; then
              echo "====="
              echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
              echo "Please verify its access permissions"
              echo "====="
              exit 1
            fi
          '';
        };
      })
    ];
    nix.settings = {
      max-jobs = 12; # 16 causes such heavy memory pressure that even bailing to zram or disk is too much.
      system-features = [
        # cafe
        "gccarch-znver3"
        # defaults
        "kvm"
        "big-parallel"
        "benchmark"
        "nixos-test"
      ];
      extra-sandbox-paths = [ config.programs.ccache.cacheDir ];
    };
    programs.ccache.enable = true;
    # builds run in this slice
    systemd.oomd.enableUserSlices = true;
  };
}
