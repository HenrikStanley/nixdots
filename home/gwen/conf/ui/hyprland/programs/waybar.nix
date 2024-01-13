{ lib, pkgs, config, default, ... }:
let
  _ = lib.getExe;
  inherit (pkgs) brightnessctl pamixer;

  formatIcons = color: text: "<span color='#${color}' font_size='13pt'>${text}</span>";

  snowflake = builtins.fetchurl rec {
    name = "Logo-${sha256}.svg";
    url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/master/logo/nix-snowflake.svg";
    sha256 = "14mbpw8jv1w2c5wvfvj8clmjw0fi956bq5xf9s2q3my14far0as8";
  };

  xcolors = config.colorscheme.colors;
in
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        mode = "dock";
        exclusive = true;
        passthrough = false;
        fixed-center = true;
        gtk-layer-shell = true;
        spacing = 0;
        margin-top = 0;
        margin-right = 0;
        margin-bottom = 0;
        margin-left = 0;
        modules-left = [
          "custom/search"
          "user"
          "hyprland/workspaces"
          "tray"
        ];
        modules-center = [  ];
        modules-right = [
          "network"
          "pulseaudio#microphone"
          "group/group-pulseaudio"
          "group/group-backlight"
          "battery"
          "clock#date"
          "clock"
          "group/group-power"
        ];
        "custom/search" = {
          format = " ";
          tooltip = false;
          on-click = "sh -c '$(wofi -S drun)'";
        };
        user = {
          format = "{user}";
          icon = false;
        };
        "hyprland/workspaces" = {
          active-only = false;
          all-outputs = false;
          disable-scroll = true;
          on-click = "activate";
          format = "{name}";
          persistent-workspaces = {
            "*" = 5;
          };
        };
        tray = {
          icon-size = 16;
          spacing = 8;
          show-passive-items = true;
        };
        network = {
          format-wifi = formatIcons "${xcolors.color5}CC" "󰖩" + " {essid}";
          format-ethernet = formatIcons "${xcolors.color5}CC" "󰈀" + " {ipaddr}/{cidr}";
          format-disconnected = formatIcons "${xcolors.color4}CC" "󰖪";
          tooltip-format = ''
            󰅃 {bandwidthUpBytes} 󰅀 {bandwidthDownBytes}
            {ipaddr}/{ifname} via {gwaddr} ({signalStrength}%)'';
        };
        "pulseaudio#microphone" = {
          tooltip = false;
          format = "{format_source}";
          format-source = formatIcons "${xcolors.color4}CC" "󰍬" + " {volume}%";
          format-source-muted = formatIcons "${xcolors.color4}CC" "󰍭";
          on-click = "${_ pamixer} --default-source -t";
          on-scroll-up = "${_ pamixer} --default-source -d 1";
          on-scroll-down = "${_ pamixer} --default-source -i 1";
        };
        "group/group-pulseaudio" = {
          orientation = "inherit";
          drawer = {
            transition-duration = 300;
            children-class = "pulseaudio-child";
            transition-left-to-right = false;
          };
          modules = [
            "pulseaudio"
            "pulseaudio/slider"
          ];
        };
        "pulseaudio/slider" = {
          min = 0;
          max = 100;
          orientation = "horizontal";
        };
        pulseaudio = {
          tooltip = false;
          format = formatIcons "${xcolors.color12}CC" "{icon}" + " {volume}%";
          format-muted = formatIcons "${xcolors.color4}CC" "󰖁";
          format-icons = { default = [ "󰕿" "󰖀" "󰕾" ]; };
          on-click = "${_ pamixer} -t";
          on-scroll-up = "${_ pamixer} -d 1";
          on-scroll-down = "${_ pamixer} -i 1";
        };
        "group/group-backlight" = {
          orientation = "inherit";
          drawer = {
            transition-duration = 300;
            children-class = "backlight-child";
            transition-left-to-right = false;
          };
          modules = [
            "backlight"
            "backlight/slider"
          ];
        };
        "backlight/slider" = {
          min = 0;
          max = 100;
          orientation = "horizontal";
        };
        backlight = {
          tooltip = false;
          format = formatIcons "${xcolors.color14}CC" "{icon}" + " {percent}%";
          format-icons = [ "󰋙" "󰫃" "󰫄" "󰫅" "󰫆" "󰫇" "󰫈" ];
          on-scroll-up = "${_ brightnessctl} -q s 1%-";
          on-scroll-down = "${_ brightnessctl} -q s +1%";
        };
        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          tooltip-format = "{timeTo}, {capacity}%";
          format = formatIcons "${xcolors.color2}CC" "{icon}" + " {capacity}%";
          format-charging = formatIcons "${xcolors.color2}CC" "󰂄" + " {capacity}%";
          format-plugged = formatIcons "${xcolors.color2}CC" "󰚥" + " {capacity}%";
          format-icons = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        };
        "clock#date" = {
          format = formatIcons "${xcolors.color3}CC" "󰃶" + " {:%a %d %b}";
          tooltip-format = ''
            <big>{:%Y %B}</big>
            <tt><small>{calendar}</small></tt>'';
        };
        clock = {
          format = formatIcons "${xcolors.color9}CC" "󱑎" + " {:%I:%M %p}";
          format-alt = formatIcons "${xcolors.color9}CC" "󱑎" + " {:%H:%M}";
        };
        "group/group-power" = {
          orientation = "inherit";
          drawer = {
            transition-duration = 300;
            transition-left-to-right = false;
            children-class = "power-child";
          };
          modules = [
            "custom/power"
            "custom/quit"
            "custom/lock"
            "custom/suspend"
            "custom/reboot"
          ];
        };
        "custom/quit" = {
          format = formatIcons "${xcolors.color14}CC" "󰍃";
          onclick = "loginctl terminate-user $USER";
          tooltip = false;
        };
        "custom/lock" = {
          format = formatIcons "${xcolors.color2}CC" "󰌾";
          onclick = "loginctl lock-session";
          tooltip = false;
        };
        "custom/suspend" = {
          format = formatIcons "${xcolors.color3}CC" "󰒲";
          onclick = "systemctl suspend";
          tooltip = false;
        };
        "custom/reboot" = {
          format = formatIcons "${xcolors.color9}CC" "󰜉";
          on-click = "systemctl reboot";
          tooltip = false;
        };
        "custom/power" = {
          format = formatIcons "${xcolors.color4}CC" "󰐥";
          on-click = "systemctl poweroff";
          tooltip = false;
        };
      };
    };

    style = ''
      * {
        all: initial;
        border: none;
        border-radius: 0;
        min-height: 0;
        min-width: 0;
        font-family: "Material Design Icons", monospace;
        font-size: 11pt;
      }

      window#waybar {
        background-color: #${xcolors.background};
      }

      .modules-left {
        margin-left: 0.21em;
      }
      .modules-right {
        margin-right: 0.21em;
      }

      #backlight,
      #backlight-slider,
      #battery,
      #clock,
      #clock.date,
      #custom-lock,
      #custom-power,
      #custom-reboot,
      #custom-suspend,
      #custom-quit,
      #network,
      #pulseaudio,
      #pulseaudio-slider,
      #pulseaudio.microphone,
      #tray,
      #user {
        color: #${xcolors.color7};
        background-color: #${xcolors.mbg};
        border-radius: 4px;
        margin: 0.41em 0.21em;
        padding: 0.41em 0.82em;
      }

      #custom-search {
        margin: 0.41em 0.21em;
        padding: 0.41em 0.82em;
        background-image: url("${snowflake}");
        background-size: 80%;
        background-position: center;
        background-repeat: no-repeat;
      }

      #user {
        color: #${xcolors.color7};
      }

      #workspaces {
        background-color: #${xcolors.mbg};
        border-radius: 4px;
        margin: 0.41em 0.21em;
      }

      #workspaces button {
        padding: 0 0.82em;
        border-radius: 4px;
        transition: all 0.1s ease-in-out;
      }

      #workspaces button:hover {
        box-shadow: inherit;
        text-shadow: inherit;
      }

      #workspaces button label {
        color: #${xcolors.color7};

      }

      #workspaces button.empty label {
        color: #808080;
      }

      #workspaces button.urgent label {
        color: #${xcolors.color4};
      }

      #workspaces button.special label {
        color: #${xcolors.color3};
      }

      #workspaces button.active {
        background-color: #${xcolors.color4};
      }

      #workspaces button.active label {
        color: #${xcolors.mbg};
        font-weight: bold;
      }

      #tray menuitem,
      #tray window {
        border-radius: 4px;
        padding: 0.41em;
      }

      #tray menuitem:hover {
        background-color: #${xcolors.color4};
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
      }

      #backlight-slider slider,
      #pulseaudio-slider slider {
        min-height: 0px;
        min-width: 0px;
        opacity: 0;
        background-image: none;
        border: none;
        box-shadow: none;
        margin: 0 0.68em;
      }

      #backlight-slider trough,
      #pulseaudio-slider trough {
        min-height: 0.68em;
        min-width: 5.47em;
        border-radius: 8px;
        background-color: #${xcolors.background};
      }

      #backlight-slider highlight,
      #pulseaudio-slider highlight {
        min-width: 0.68em;
        border-radius: 8px;
      }

      #backlight-slider highlight {
        background-color: #${xcolors.color14};
      }

      #pulseaudio-slider highlight {
        background-color: #${xcolors.color12};
      }

      tooltip {
        color: #${xcolors.color7};
        background-color: #${xcolors.background};
        font-family: "Dosis", sans-serif;
        border-radius: 8px;
        padding: 1.37em;
        margin: 2.05em;
      }

      tooltip label {
        font-family: "Dosis", sans-serif;
        padding: 1.37em;
      }
    '';

    systemd.enable = true;
    systemd.target = "graphical-session.target";
  };
}

