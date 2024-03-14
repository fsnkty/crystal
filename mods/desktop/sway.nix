{
  pkgs,
  lib,
  nuke,
  config,
  colours,
  ...
}:
{
  options.desktop.sway = nuke.mkEnable;
  config = lib.mkIf config.desktop.sway {
    desktop.setup.greeter = {
      enable = true;
      command = "sway";
    };
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = builtins.attrValues {
        inherit (pkgs)
          xdg-utils
          autotiling-rs
          wl-clipboard
          swaylock-effects
          swaynotificationcenter
          swayidle
          swaybg
          ;
      };
      # export WLR_RENDERER=vulkan # vulkan validation-layers
      extraSessionCommands = ''
        export LIBSEAT_BACKEND=logind
        export SDL_VIDEODRIVER=wayland
        export _JAVA_AWT_WM_NONREPARENTING=1
      '';
    };
    home.file.".config/sway/config".text =
      let
        inherit (lib)
          replicate
          range
          getExe
          concatMapStringsSep
          concatStrings
          ;
        inherit (pkgs) grim slurp rwpspread;
        inherit (colours) primary;
        d1 = "DP-1";
        d2 = "HDMI-A-1";
        m = "Mod4";
        directions = [
          "left"
          "down"
          "up"
          "right"
        ];
        lock = "swaylock -f -c 000000 --clock --timestr '%H:%M' --datestr '' --indicator --line-ver-color '#${primary.main}'";
      in
      ''
        xwayland enable
        exec {
          ${lock}
          autotiling-rs
          openrgb -p default
          ${getExe rwpspread} -b swaybg -i /home/${config.users.users.main.name}/.config/sway/wallpaper
          swaync
          waybar
          swayidle -w \
            timeout 300 '${lock}' \
            timeout 600 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' \
            before-sleep '${lock}'
        }
        input "5426:132:Razer_Razer_DeathAdder_V2" accel_profile flat
        input "1386:827:Wacom_Intuos_S_2_Pen" map_to_output ${d1}
        output ${d1} {
          mode 1920x1080@144Hz
          position 0,0
          adaptive_sync on
        }
        ${concatMapStringsSep "\n" (n: "workspace ${n} output ${d1}") (map toString (range 1 4))}
        ${concatMapStringsSep "\n" (n: "workspace ${n} output ${d2}") (map toString (range 5 8))}
        seat seat0 xcursor_theme phinger-cursors 24
        default_border pixel 3
        gaps inner 5
        client.focused ${concatStrings (replicate 4 "#${primary.main} ")}
        client.unfocused ${concatStrings (replicate 4 "#${primary.bg} ")}
        client.focused_inactive ${concatStrings (replicate 4 "#${primary.bg} ")}
        ${concatMapStringsSep "\n" (n: "bindsym ${m}+${n}") [
          "Return exec alacritty"
          "d exec fuzzel"
          ''Shift+s exec ${getExe grim} -g "$(${getExe slurp} -d)" - | wl-copy -t image/png''
          "l exec ${lock}"
          "Shift+q kill"
          "z floating toggle"
          "Shift+z fullscreen toggle"
        ]}
        floating_modifier ${m} normal
        ${concatMapStringsSep "\n" (n: "bindsym ${m}+${n} focus ${n}") directions}
        ${concatMapStringsSep "\n" (n: "bindsym ${m}+Shift+${n} move ${n}") directions}
        ${concatMapStringsSep "\n" (n: "bindsym ${m}+${n} workspace number ${n}") (
          map toString (range 1 8)
        )}
        ${concatMapStringsSep "\n" (n: "bindsym ${m}+Shift+${n} move container to workspace number ${n}") (
          map toString (range 1 8)
        )}
      '';
  };
}
