{
  _colours,
  config,
  pkgs,
  _lib,
  lib,
  ...
}:
let
  m1 = "DP-1";
  m2 = "HDMI-A-1";
  nls = a: b: lib.concatMapStringsSep "\n" a b;
  inherit (_colours) primary;
  inherit (lib) getExe;
in
{
  options._programs.hyprland = _lib.mkEnable;
  config = lib.mkIf config._programs.hyprland {
    programs.hyprland.enable = true;
    users.users.main.packages = [ pkgs.wl-clipboard ];
    _homeFile = {
      ".config/hypr/hyprland.conf".text = ''
        ${nls (n: "exec-once = ${n}") [
          "${getExe pkgs.hyprlock}"
          "${getExe pkgs.hypridle}"
          "${getExe pkgs.wpaperd}"
          "openrgb -p default"
        ]}
        ${nls (n: "env = ${n}") [ "XCURSOR_SIZE,24" ]}
        input {
          accel_profile = flat
        }
        device {
          name = wacom-intuos-s-2-pen
          output = ${m1}
        }
        general {
          border_size = 2
          gaps_out = 6
          gaps_in = 3
          col.inactive_border = 0xFF${primary.bg}
          col.active_border = 0xFF${primary.main}
        }
        decoration {
          rounding = 2
          drop_shadow = true
          shadow_range = 6
          blur {
            enabled = false
          }
        }
        animations {
          enabled = false
          first_launch_animation = false
        }
        misc {
          disable_hyprland_logo = true
          disable_splash_rendering = true
          force_default_wallpaper = 0
          animate_manual_resizes = true
          animate_mouse_windowdragging = true
          vrr = 1
        }
        dwindle {
          preserve_split = true
          force_split = 2
        }
        monitor=${m1},highrr,auto,auto
        monitor=${m2},preferred,auto,auto
        ${nls (n: "workspace=${n},monitor:${m1}") (map toString (lib.range 1 4))}
        ${nls (n: "workspace=${n},monitor:${m2}") (map toString (lib.range 5 8))}
        ${nls (n: "bind=SUPER,${n},workspace,${n}") (map toString (lib.range 1 8))}
        ${nls (n: "bind=SUPER_SHIFT,${n},movetoworkspacesilent,${n}") (map toString (lib.range 1 8))}
        bindm = SUPER, mouse:272, movewindow
        bindm = SUPER, mouse:273, resizewindow
        ${nls (n: "bind=${n}") [
          ''SUPER_SHIFT, S, exec, ${getExe pkgs.grim} -g "$(${getExe pkgs.slurp} -d)" - | wl-copy -t image/png''
          "SUPER_SHIFT, Q, killactive,"
          "SUPER_SHIFT, Z, fullscreen,"
          "SUPER, Z, togglefloating,"
          "SUPER, Return, exec, ${getExe pkgs.alacritty}"
          "SUPER, D, exec, ${getExe pkgs.fuzzel}"
          "SUPER, L, exec, ${getExe pkgs.hyprlock}"
          "SUPER, left, movefocus, l"
          "SUPER, right, movefocus, r"
          "SUPER, up, movefocus, u"
          "SUPER, down, movefocus, d"
        ]}
      '';
      ".config/hypr/hyprlock.conf".text = ''
        general {
          disable_loading_bar = true
          hide_cursor = false
          no_fade_in = true
        }
        ${nls
          (n: ''
            background {
              monitor = ${n}
              path = /home/${config.users.users.main.name}/.cache/rwpspread/rwps_${n}.png
              brightness = 0.8
              blur_size = 7
              blur_passes = 1
            }
          '')
          [
            m1
            m2
          ]
        }
        input-field {
          monitor = ${m1}
          size = 200, 50
          outline_thickness = 3
          position = 0, -20
          halign = center
          valign = center
          fade_on_empty = false
        }
      '';
      ".config/hypridle.conf".text = ''
        general {
          lock_cmd = ${getExe pkgs.hyprlock}
          before_sleep_cmd = ${getExe pkgs.hyprlock}
        }
        listener {
          timeout = 300
          on-timeout = ${getExe pkgs.hyprlock}
        }
        listener {
          timeout = 600
          on-timeout = systemctl suspend
        }
      '';
    };
  };
}
