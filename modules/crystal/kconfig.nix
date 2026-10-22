{ lib
, pkgs
, config
, inputs
, ...
}:
let
  inherit (lib) types;
  format = pkgs.formats.json { };
  inherit (lib) mkOption literalExpression;
in
{

  options = {
    kconfig = mkOption {
      default = { };
      type = types.submodule {
        options = {
          settings = lib.mkOption {
            type = types.attrsOf format.type;
            default = { };
            description = "Configuration for each KDE Plasma file. The value can be anything serializable to json";
            example = literalExpression ''
              {
                kwinrc = {
                  Desktops.Number = 4;
                };
              }
            '';
          };

          manifest = lib.mkOption {
            visible = false;
            readOnly = true;
            default = format.generate "kconfig-manifest.json" {
              files = config.kconfig.settings;
            };
          };
          package = lib.mkOption {
            type = types.package;
            description = "The kconfig-declarative package to use.";
            default = pkgs.callPackage (inputs.kconfig-declarative + "/default.nix") { };
            defaultText = literalExpression "<internal>";
          };
        };
      };
    };
  };

  config = {
    systemd.services.maid-kconfig =
      lib.mkIf ((builtins.attrNames config.kconfig.settings) != [ ])
        {
          wantedBy = [ "plasma-plasmashell.service" ];
          before = [ "plasma-plasmashell.service" ];
          restartIfChanged = true;
          restartTriggers = [ config.kconfig.manifest ];
          serviceConfig = {
            RemainAfterExit = true;
            Type = "oneshot";
            ExecStart = "${lib.getExe config.kconfig.package} apply ${config.kconfig.manifest}";
          };
        };
  };
}
