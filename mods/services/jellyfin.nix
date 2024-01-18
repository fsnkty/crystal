{
  config,
  pkgs,
  lib,
  inputs,
  modulesPath,
  ...
}: {
  #### awaiting PR
  disabledModules = [
    "${modulesPath}/services/misc/jellyfin.nix"
  ];
  imports = [
    "${inputs.jelly}/nixos/modules/services/misc/jellyfin.nix"
  ];
  ####
  options.service.web.jellyfin = lib.mkEnableOption "";
  config = let
    domain = "jelly.${config.service.web.domain}";
  in
    lib.mkIf config.service.web.jellyfin {
      services = {
        jellyfin = {
          enable = true;
          package = inputs.nixpkgs.legacyPackages.x86_64-linux.jellyfin;
          openFirewall = true;
          dataDir = "/storage/volumes/jellyfin";
        };
        nginx.virtualHosts."${domain}" = {
          forceSSL = true;
          enableACME = true;
          locations."/".proxyPass = "http://127.0.0.1:8096";
        };
      };
      # intel hardware transcoding setup
      nixpkgs.config.packageOverrides = pkgs: {
        vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
      };
      hardware.opengl = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver
          vaapiIntel
          vaapiVdpau
          libvdpau-va-gl
          intel-compute-runtime
        ];
      };
    };
}
