{
  lib,
  nuke,
  pkgs,
  config,
  colours,
  ...
}:
{
  options.desktop.program = {
    waybar = nuke.mkEnable;
    fuzzel = nuke.mkEnable;
  };
  config =
    let
      inherit (lib) mkIf optionals;
      inherit (config.desktop.program) fuzzel waybar;
    in
    {
      users.users.main.packages = optionals fuzzel [ pkgs.fuzzel ] ++ optionals waybar [ pkgs.waybar ];
      home.file =
        let
          d1 = "DP-1";
          d2 = "HDMI-A-1";
          inherit (colours) primary alpha;
        in
        {
          ".config/fuzzel/fuzzel.ini" = mkIf fuzzel {
            source = (pkgs.formats.ini { }).generate "fuzzel.ini" {
              colors = {
                background = primary.bg + "FF";
                text = primary.fg + "FF";
                match = primary.main + "FF";
                border = primary.main + "FF";
              };
            };
          };
          ".config/waybar/config" = mkIf waybar {
            text =
              let
                workspaces = ''
                  "sway/workspaces": {
                    "disable-scroll": true,
                    "all-outputs": false,
                    "format": "{name}",
                  }
                '';
                audio = ''
                  "pulseaudio": {
                    "scroll-step": 5,
                    "format": "{icon}\n{format_source}",
                    "format-muted": "󰝟\n{format_source}",
                    "format-source": "",
                    "format-source-muted": "",
                    "format-icons": {
                      "default": ["", ""]
                    },
                    "tooltip": true,
                    "tooltip-format": "{volume}%"
                  }
                '';
                clock = ''
                  "clock": {
                    "format": "{:%H\n%M}",
                    "tooltip-format": "{:%Y-%m-%d}"
                  }
                '';
                network = ''
                  "network": {
                    "format-ethernet": "󰈀",
                    "format-disconnected": "",
                    "tooltip-format": "{ipaddr}/{ifname}"
                  }
                '';
                tray = ''
                  "tray": {
                    "icon-size": 16,
                    "spacing": 10
                  }
                '';
              in
              ''
                [
                  {
                    "layer": "bottom",
                    "position": "left",
                    "output": "${d1}",
                    "spacing": 5,
                    "margin-top": 5,
                    "margin-bottom": 5,
                    "modules-left": [ "sway/workspaces" ],
                    "modules-right": [ "pulseaudio", "clock"],
                    ${workspaces},
                    ${audio},
                    ${clock}
                  },
                  {
                    "layer": "bottom",
                    "position": "right",
                    "output": "${d2}",
                    "spacing": 5,
                    "margin-top": 5,
                    "margin-bottom": 5,
                    "modules-left": [ "sway/workspaces" ],
                    "modules-right": [ "tray", "network", "pulseaudio", "clock"],
                    ${workspaces},
                    ${tray},
                    ${network},
                    ${audio},
                    ${clock}
                  }
                ]
              '';
          };
          ".config/waybar/style.css" = mkIf waybar {
            text = ''
              * {
                  font-family: 'Liga SFMono Nerd Font';
                  font-size: 14px;
              }
              window#waybar {
                  background-color: transparent;
                  transition-property: background-color;
                  transition-duration: .5s;
              }
              window#waybar.empty #window { background-color: transparent; }
              #workspaces {
                  padding: 0px;
                  border-radius: 0px;
                  border:2px solid #${alpha.black};
                  background-color: #${primary.bg};
                  color: #${primary.fg};
              }
              #workspaces button { padding: 2px; }
              #workspaces button:hover { border-radius: 0px; }
              #workspaces button.focused { color: #${primary.main}; }
              #workspaces button.urgent { color: #${primary.main}; }
              #network,
              #pulseaudio,
              #tray,
              #clock {
                  border-radius: 0px;
                  border:2px solid #${alpha.black};
                  background-color: #${primary.bg};
                  color: #${primary.fg};
                  padding: 2px;
              }
              tooltip label {
                  background-color: #${primary.bg};
                  color: #${primary.fg};
                  border-radius: 0px;
                  border:2px solid #${alpha.black};
              }
            '';
          };
        };
    };
}
