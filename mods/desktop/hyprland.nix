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
    desktop.setup.greeter = {
      enable = true;
      command = "Hyprland";
    };
    users.users.main.packages = builtins.attrValues {
      inherit (pkgs)
        wpaperd
        hyprlock
        hypridle
        xdg-utils
        wl-clipboard
        ;
    };
    home.file =
      let
        m1 = "DP-1";
        m2 = "HDMI-A-1";
      in
      {
        ".config/hypr/hypridle.conf".text = ''
          general {
            lock_cmd = hyprlock
            before_sleep_cmd = hyprlock
          }
          listener {
            timeout = 300
            on-timeout = hyprlock
          }
          listener {
            timeout = 600
            on-timeout = systemctl suspend
          }
        '';
        ".config/hypr/hyprlock.conf".text = ''
          background {
              monitor = ${m1}
              path = /home/${config.users.users.main.name}/.cache/rwpspread/rwps_${m1}.png
          }
          background {
              monitor = ${m2}
              path = /home/${config.users.users.main.name}/.cache/rwpspread/rwps_${m2}.png
          }
          input-field {
            monitor = ${m1}
            size = 200, 50
            outline_thickness = 3
            position = 0, -20
            halign = center
            valign = center
          }
        '';
        ".config/hypr/hyprland.conf".text =
          let
            inherit (lib) range getExe;
            inherit (pkgs) grim slurp;
            inherit (colours) primary;
            nls = a: b: lib.concatMapStringsSep "\n" a b;
          in
          ''
            exec-once=hyprlock
            exec-once=hypridle
            exec-once=wpaperd
            monitor=${m1},highrr,auto,auto
            monitor=${m2},preferred,auto,auto
            ${nls (n: "env = ${n}") [
              "XCURSOR_SIZE,24"
              "XCURSOR_THEME,phinger-cursors"
              "QT_QPA_PLATFORMTHEME,qt5ct"
              "_JAVA_AWT_WM_NONREPARENTING,1"
            ]}
            input {
              kb_layout = us
              follow_mouse = 2
              accel_profile = flat
            }
            device {
              name = wacom-intuos-s-2-pen
              output=${m1}
            }

            general {
              border_size = 2
              gaps_in = 5
              gaps_out = 5
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
              animation=global,1,1,default
              first_launch_animation = true
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
              force_split = 2
            }
            ${nls (n: "workspace=${n},monitor:${m1}") (map toString (range 1 4))}
            ${nls (n: "workspace=${n},monitor:${m2}") (map toString (range 5 8))}

            ${nls (n: "bind=${n}") [
              "SUPER, Return, exec, alacritty"
              "SUPER, D, exec, wofi --show drun -a -W 15% -H 35%"
              "SUPER, L, exec, hyprlock"
              ''SUPER_SHIFT, S, exec, ${getExe grim} -g "$(${getExe slurp} -d)" - | wl-copy -t image/png''

              "SUPER_SHIFT, Q, killactive,"
              "SUPER_SHIFT, Z, fullscreen,"
              "SUPER, Z, togglefloating,"
              "SUPER, left, movefocus, l"
              "SUPER, right, movefocus, r"
              "SUPER, up, movefocus, u"
              "SUPER, down, movefocus, d"
            ]}
            ${nls (n: "bind=SUPER,${n},workspace,${n}") (map toString (range 1 8))} 
            ${nls (n: "bind=SUPER_SHIFT,${n},movetoworkspace,${n}") (map toString (range 1 8))}
            bindm = SUPER, mouse:272, movewindow
            bindm = SUPER, mouse:273, resizewindow
          '';
      };
  };
}
