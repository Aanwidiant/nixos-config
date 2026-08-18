{ ... }:
{
  programs.fastfetch = {
    enable = true;

    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";

      logo = {
        type = "auto";
        padding = {
          top = 2;
          right = 6;
          left = 2;
        };
      };

      modules = [
        {
          type = "custom";
          format = "{#cyan}┌─────────────────────────Hardware─────────────────────────┐{#}";
        }

        {
          type = "host";
          key = " PC";
          keyColor = "cyan";
        }

        {
          type = "cpu";
          key = "│ ├ ";
          showPeCoreCount = true;
          keyColor = "cyan";
        }

        {
          type = "gpu";
          key = "│ ├ ";
          detectionMethod = "pci";
          keyColor = "cyan";
        }

        {
          type = "display";
          key = "│ ├󱄄 ";
          keyColor = "cyan";
        }

        {
          type = "disk";
          key = "│ ├󰋊 ";
          keyColor = "cyan";
        }

        {
          type = "memory";
          key = "│ ├ ";
          keyColor = "cyan";
        }

        {
          type = "swap";
          key = "│ └󰓡 ";
          keyColor = "cyan";
        }

        {
          type = "custom";
          format = "{#cyan}└──────────────────────────────────────────────────────────┘{#}";
        }

        {
          type = "custom";
          format = "{#blue}┌─────────────────────────Software─────────────────────────┐{#}";
        }

        {
          type = "os";
          key = "󱄅 OS";
          keyColor = "blue";
        }

        {
          type = "kernel";
          key = "│ ├ ";
          keyColor = "blue";
        }

        {
          type = "wm";
          key = "│ ├ ";
          keyColor = "blue";
        }

        {
          type = "de";
          key = " DE ";
          keyColor = "blue";
        }

        {
          type = "terminal";
          key = "│ ├ ";
          keyColor = "blue";
        }

        {
          type = "shell";
          key = "│ ├ ";
          keyColor = "blue";
        }

        {
          type = "packages";
          key = "│ ├󰏖 ";
          keyColor = "blue";
        }

        {
          type = "wmtheme";
          key = "│ ├󰉼 ";
          keyColor = "blue";
        }

        {
          type = "terminalfont";
          key = "│ └ ";
          keyColor = "blue";
        }

        {
          type = "custom";
          format = "{#blue}└──────────────────────────────────────────────────────────┘{#}";
        }

        {
          type = "custom";
          format = "{#magenta}┌─────────────────────────System───────────────────────────┐{#}";
        }

        {
          type = "command";
          key = "󱦟 OS Age";
          keyColor = "magenta";
          text = "birth=$(stat -c %Y /boot --alternate-form 2>/dev/null || stat -c %W /); echo $(( ($(date +%s) - birth) / 86400 )) days";
        }

        {
          type = "uptime";
          key = "󱫐 Uptime";
          keyColor = "magenta";
        }

        {
          type = "battery";
          key = "󰁹 Battery";
          keyColor = "magenta";
        }

        {
          type = "custom";
          format = "{#magenta}└──────────────────────────────────────────────────────────┘{#}";
        }
      ];
    };
  };
}
