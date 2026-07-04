{
  config,
  lib,
  ...
}:
{
  options.crystal.server.media.arrs.enable = lib.mkEnableOption "";
  config = lib.mkIf config.crystal.server.media.arrs.enable {
    services = {
      nginx.virtualHosts."see.shimeji.cafe" = {
        useACMEHost = "shimeji.cafe";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:5055";
          proxyWebsockets = true;
        };
      };
      seerr.enable = true;
      prowlarr.enable = true;
      radarr = {
        enable = true;
        group = "media";
      };
      sonarr = {
        enable = true;
        group = "media";
      };
      flaresolverr = {
        enable = true;
      };
      recyclarr = {
        enable = true;
        group = "media";
        configuration =
          let
            mkProfiles =
              ids:
              map (id: {
                trash_id = id;
                reset_unmatched_scores.enabled = true;
              }) ids;
          in
          {
            radarr.radarr-main = {
              api_key._secret = "/keys/radarr";
              base_url = "http://localhost:7878";
              delete_old_custom_formats = true;
              replace_existing_custom_formats = true;
              quality_definition.type = "movie";
              quality_profiles = mkProfiles [
                "92e9a65a52ae48478fb8e9f34238d823" # base
                "722b624f9af1e492284c4bc842153a38" # anime
              ];
            };
            sonarr.sonarr-main = {
              api_key._secret = "/keys/sonarr";
              base_url = "http://localhost:8989";
              delete_old_custom_formats = true;
              replace_existing_custom_formats = true;
              quality_definition.type = "series";
              quality_profiles = mkProfiles [
                "e58cf4e090184db3b3d7c79c1a9e9b4a" # base
                "9d142234e45d6143785ac55f5a9e8dc9" # WEB-1080p
                "20e0fc959f1f1704bed501f23bdae76f" # Anime
              ];
            };
          };
      };
    };
  };
}
