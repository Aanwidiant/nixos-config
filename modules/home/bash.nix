{ ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableBashIntegration = true;
  };

  programs.bat = {
    enable = true;
    config.theme = "ansi";
  };

  programs.eza = {
    enable = true;
    enableBashIntegration = false;
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;

    historyControl = [ "ignoreboth" ];
    historySize = 32768;
    historyFileSize = 32768;
    shellOptions = [ "histappend" ];

    sessionVariables = {
      PATH = "$HOME/.local/bin:$PATH";
    };

    shellAliases = {
      # Eza Aliases
      ls = "eza -lh --group-directories-first --icons=auto";
      lsa = "eza -lh -a --group-directories-first --icons=auto";
      lt = "eza --tree --level=2 --long --icons --git";
      lta = "eza --tree --level=2 --long --icons --git -a";

      # File system & search
      ff = "fzf --preview 'bat --style=numbers --color=always {}'";

      # Directories
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../../";

      # Git
      g = "git";
      gs = "git status -sb";
      gl = "git log --oneline --graph --decorate --all";
      ga = "git add";
      gaa = "git add .";
      gc = "git commit -m";
      gca = "git commit -a -m";
      gcm = "git commit --amend -m";
      gb = "git branch";
      gbd = "git branch -d";
      gbr = "git branch -r";
      gco = "git checkout";
      gsw = "git switch";
      gswc = "git switch -c";
      gp = "git push";
      gpl = "git pull";
      gpo = "git push origin";
      gpom = "git push origin main";
      gpob = "git push origin $(git branch --show-current)";
      gst = "git stash";
      gsta = "git stash apply";
      gstd = "git stash drop";
      gstp = "git stash pop";
      grb = "git rebase";
      grbi = "git rebase -i";
      grbc = "git rebase --continue";
      grba = "git rebase --abort";
      grh = "git reset --hard";
      grs = "git reset --soft HEAD~1";

      # TUI tools
      lg = "lazygit";
      ld = "lazydocker";

      # Ollama
      ollama-start = "sudo systemctl start ollama";
      ollama-stop = "sudo systemctl stop ollama";
      ollama-status = "systemctl status ollama";
      qwen = "ollama run qwen3:8b";

      # NixOS
      nix-switch = "sudo nixos-rebuild switch --flake path:$HOME/nixos-config#";
      nix-sync = "sudo nixos-rebuild boot --flake path:$HOME/nixos-config#";
      nix-update = "nix flake update --flake ~/nixos-config";
      nix-upgrade = "nix-update && nix-switch";
      nix-list = "sudo nixos-rebuild list-generations";
      nix-clean = "sudo nix-collect-garbage --delete-old";
      nix-optimize = "sudo nix-store --optimize";

      # Misc
      gpu-stats = "sudo intel_gpu_top";
      cwipe = "cliphist wipe";

      # LAN
      connect-office = "sudo nmcli con modify \"enp0s31f6\" ipv4.method manual ipv4.addresses 10.200.100.159/24 ipv4.gateway 10.200.100.1 ipv4.dns \"8.8.8.8 1.1.1.1\" && sudo nmcli con up \"enp0s31f6\"";
      connect-home = "sudo nmcli con modify \"enp0s31f6\" ipv4.method auto && sudo nmcli con up \"enp0s31f6\"";
    };

    initExtra = ''
      export NIXOS_ICON="$HOME/nixos-config/dotfiles/quickshell/assets/nixos.png"

      zd() {
        if [ $# -eq 0 ]; then
          builtin cd ~ && return
        elif [ -d "$1" ]; then
          builtin cd "$1"
        else
          z "$@" && printf "\U000F17A9 " && pwd || echo "Error: Directory not found"
        fi
      }
      alias cd="zd"

      work() {
        tmux has-session -t work 2>/dev/null && \
          tmux attach -t work || \
          tmux new -s work
      }

      if command -v try &>/dev/null; then
        eval "$(try init ~/Work/tries)"
      fi
    '';
  };

  programs.readline = {
    enable = true;
    extraConfig = ''
      set meta-flag on
      set input-meta on
      set output-meta on
      set convert-meta off

      set completion-ignore-case on
      set show-all-if-ambiguous on
      set show-all-if-unmodified on
      set mark-symlinked-directories on
      set match-hidden-files off
      set page-completions off
      set completion-query-items 200
      set visible-stats on
      set colored-stats on
      set skip-completed-text on

      TAB: complete
    '';
    bindings = {
      "\\e[A" = "history-search-backward";
      "\\e[B" = "history-search-forward";
      "\\e[C" = "forward-char";
      "\\e[D" = "backward-char";
    };
  };
}
