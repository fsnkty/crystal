{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  options.desktop.sway = lib.mkEnableOption "";
  config = lib.mkIf config.desktop.sway {
    programs = {
      zsh.loginShellInit = ''
        if [ -z "''${WAYLAND_DISPLAY}" ] && [ "''${XDG_VTNR}" -eq 1 ]; then
          exec sway
        fi
      '';
      sway = {
        enable = true;
        wrapperFeatures.gtk = true;
        extraPackages = with pkgs; [
          vulkan-validation-layers # upstream might remove this dep soon.
          autotiling-rs
          wl-clipboard
          swaylock
          swayidle
          inputs.rwp.legacyPackages.${pkgs.system}.rwpspread
          wpaperd
        ];
        extraSessionCommands = ''
          export LIBSEAT_BACKEND=logind
          export WLR_RENDERER=vulkan
          export SDL_VIDEODRIVER=wayland
          export _JAVA_AWT_WM_NONREPARENTING=1
        '';
      };
    };
    home.file. ".config/sway/config".text = let
      d1 = "DP-1";
      d2 = "HDMI-A-1";
      m = "Mod4";
      directions = ["left" "down" "up" "right"];
      lock = "swaylock -f -c 000000";
      inherit (lib) replicate range getExe concatMapStringsSep concatStrings;
      inherit (pkgs) grim slurp;
      inherit (config.colours) primary;
    in ''
      xwayland enable
      exec {
        autotiling-rs
        wpaperd
        waybar
        swayidle -w before-sleep '${lock}'
        openrgb -p default
      }
      input "5426:132:Razer_Razer_DeathAdder_V2" accel_profile flat
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
        "Shift+q kill"
        "d exec wofi --show drun -a -W 15% -H 35%"
        "Shift+s exec ${getExe grim} -g \"$(${getExe slurp} -d)\" - | wl-copy -t image/png"
        "Shift+e exec swaynag -t warning -m 'confirm quit sway' -B 'confirm' 'swaymsg exit'"
        "Shift+a floating toggle"
        "Shift+z fullscreen toggle"
        "l exec ${lock}"
      ]}
      floating_modifier ${m} normal
      ${concatMapStringsSep "\n" (n: "bindsym ${m}+${n} focus ${n}") directions}
      ${concatMapStringsSep "\n" (n: "bindsym ${m}+Shift+${n} move ${n}") directions}
      ${concatMapStringsSep "\n" (n: "bindsym ${m}+${n} workspace number ${n}") (map toString (range 1 8))}
      ${concatMapStringsSep "\n" (n: "bindsym ${m}+Shift+${n} move container to workspace number ${n}") (map toString (range 1 8))}
    '';
  };
}
