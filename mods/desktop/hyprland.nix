{
  pkgs,
  lib,
  nuke,
  config,
  colours,
  ...
}:
{
  options.desktop.hyprland = nuke.mkEnable;
  config = lib.mkIf config.desktop.hyprland {
    programs.hyprland.enable = true;
    home.file.".config/hypr/hyprland.conf".text =
      let
        inherit (lib)
          concatStrings
          concatMapStringsSep
          range
          getExe
          ;
        inherit (pkgs) grim slurp rwpspread;
        inherit (colours) primary;
        d1 = "DP-1";
        d2 = "HDMI-A-1";
        mod = "SUPER";
        lock = "swaylock -f -c 000000 --clock --timestr '%H:%M' --datestr '' --indicator --line-ver-color '#${primary.main}'";
      in
      ''
        monitor=${d1},1920x1080@144,0x0,1,vrr,1
        monitor=${d2},1920x1080@60,1920x0,1
        ${concatMapStringsSep "\n" (n: "env = ${n}") [
          "XCURSOR_SIZE,24"
          "QT_QPA_PLATFORMTHEME,qt5ct"
          "_JAVA_AWT_WM_NONREPARENTING,1"
        ]}
        input {
          kb_layout = us
          follow_mouse = 2
          accel_profile = flat
        }
        general {
          border_size = 1
          gaps_in = 5
          gaps_out = 20
          col.inactive_border = 0xFF${primary.bg}
          col.active_border = 0xFF${primary.main}
          resize_on_border = true
        }
        decoration {
          rounding = 3
          drop_shadow = true
          blur {
            enabled = false
          }
        }
        animations {
          enabled = true
          first_launch_animation = true
        }
        misc {
          disable_hyprland_logo = true
          disable_splash_rendering = true
          force_default_wallpaper = 0
          animate_manual_resizes = true
          animate_mouse_windowdragging = true
        }
        dwindle {
          force_split = 2
        }
        bind = ${mod}, Return, exec, alacritty
        bind = SUPER_SHIFT, Q, killactive,
        bind = ${mod}, D, exec, wofi --show drun -a -W 15% -H 35%
        bind = SUPER_SHIFT, S, exec, ${getExe grim} -g "$(${getExe slurp} -d)" - | wl-copy -t image/png
        bind = ${mod}, L, exec, ${lock}
        bind = ${mod}, Z, togglefloating,
        bind = SUPER_SHIFT, Z, fullscreen,


        ${concatMapStringsSep "\n" (n: "bind = ${mod}, ${n}, workspace, ${n}") (map toString (range 1 8))} 
        ${concatMapStringsSep "\n" (n: "bind = ${mod} SHIFT, ${n}, movetoworkspace, ${n}") (
          map toString (range 1 8)
        )}

        bind = ${mod}, mouse_up, workspace, e+1
        bind = ${mod}, mouse_down, workspace, e-1
        bindm = ${mod}, mouse:272, movewindow
        bindm = ${mod}, mouse:273, resizewindow

        bind = ${mod}, left, movefocus, l
        bind = ${mod}, right, movefocus, r
        bind = ${mod}, up, movefocus, u
        bind = ${mod}, down, movefocus, d

      '';
  };
}
