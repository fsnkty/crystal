{
  lib,
  config,
  ...
}: {
  options.local.desktop = {
    waybar = lib.mkEnableOption "";
    wofi = lib.mkEnableOption "";
  };
  config = {
    home.file = let
      d1 = "DP-1";
      d2 = "HDMI-A-1";
      lcp = config.local.colours.primary;
      lca = config.local.colours.alpha;
    in {
      ".config/wofi/style.css".text = lib.mkIf config.local.desktop.wofi ''
        #window {
            border: 3px solid #${lcp.main};
        }
        #input {
            marfin: 15px;
        }
        #inner-box {
            margin: 0px 15px 15px 15px;
        }
        #entry {
            margin: 5px;
        }
        #entry:selected {
            color: #${lcp.main};
        }
      '';
      ".config/waybar/config".text = let
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
        lib.mkIf config.local.desktop.waybar ''
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
      ".config/waybar/style.css".text = lib.mkIf config.local.desktop.waybar ''
        * {
            font-family: 'Liga SFMono Nerd Font';
            font-size: 14px;
        }
        window#waybar {
            background-color: transparent;
            transition-property: background-color;
            transition-duration: .5s;
        }
        window#waybar.empty #window {
            background-color: transparent;
        }
        #workspaces {
            padding: 0px;
            border-radius: 0px;
            border:2px solid #${lca.black};
            background-color: #${lcp.bg};
            color: #${lcp.fg};
        }
        #worksapces button {
            padding: 2px;
        }
        #workspaces button:hover {
            border-radius: 0px;
        }
        #workspaces button.focused {
            color: #${lcp.main};
        }
        #workspaces button.urgent {
            color: #${lcp.main};
        }
        #network,
        #pulseaudio,
        #tray,
        #clock {
            border-radius: 0px;
            border:2px solid #${lca.black};
            background-color: #${lcp.bg};
            color: #${lcp.fg};
            padding: 2px;
        }
        tooltip label {
            background-color: #${lcp.bg};
            color: #${lcp.fg};
            border-radius: 0px;
            border:2px solid #${lca.black};
        }
      '';
    };
  };
}
