{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;

    plugins = with pkgs.tmuxPlugins; [
      resurrect
    ];

    extraConfig = ''
      # Basic Settings
      set -g default-terminal "tmux-256color"
      set -ga terminal-overrides ",*:RGB"
      set -g mouse on
      set -g set-clipboard on

      unbind C-b
      set -g prefix C-a
      bind-key C-a send-prefix

      # Split windows (open in same directory as current pane)
      unbind %
      unbind '"'
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind v split-window -h -c "#{pane_current_path}"
      bind s split-window -v -c "#{pane_current_path}"

      # Vim-style pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Alt+hjkl to switch panes without prefix
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      # Start numbering at 1
      set -g base-index 1
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      # Shift+arrow to switch windows
      bind -n S-Left previous-window
      bind -n S-Right next-window

      # Alt+number to select window
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5
      bind -n M-6 select-window -t 6
      bind -n M-7 select-window -t 7
      bind -n M-8 select-window -t 8
      bind -n M-9 select-window -t 9

      # Vim style copying
      set-window-option -g mode-keys vi
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      unbind -T copy-mode-vi MouseDragEnd1Pane

      # tmux-resurrect
      set -g @resurrect-processes 'nvim lazygit'

      # Catppuccin Mocha theme colors
      thm_bg="#1e1e2e"
      thm_fg="#cdd6f4"
      thm_cyan="#89dceb"
      thm_gray="#313244"
      thm_magenta="#cba6f7"
      thm_blue="#89b4fa"
      thm_black4="#45475a"

      # Status bar
      set -g status on
      set -g status-bg "$thm_bg"
      set -g status-justify left
      set -g status-left-length 100
      set -g status-right-length 100

      # Messages
      set -g message-style "fg=$thm_cyan,bg=$thm_gray,align=centre"
      set -g message-command-style "fg=$thm_cyan,bg=$thm_gray,align=centre"

      # Panes
      set -g pane-border-style "fg=$thm_gray"
      set -g pane-active-border-style "fg=$thm_blue"

      # Windows
      set -g window-status-activity-style "fg=$thm_fg,bg=$thm_bg,none"
      set -g window-status-separator ""
      set -g window-status-style "fg=$thm_fg,bg=$thm_bg,none"

      # Current window
      set -g window-status-current-format "#[fg=$thm_blue,bg=$thm_bg] #I: #[fg=$thm_magenta,bg=$thm_bg](✓) #[fg=$thm_cyan,bg=$thm_bg]#(echo '#{pane_current_path}' | rev | cut -d'/' -f-2 | rev)"

      # Other windows
      set -g window-status-format "#[fg=$thm_blue,bg=$thm_bg] #I: #[fg=$thm_fg,bg=$thm_bg]#W"

      # Right status
      set -g status-right "#[fg=$thm_blue,bg=$thm_bg]█#[fg=$thm_bg,bg=$thm_blue] #[fg=$thm_fg,bg=$thm_gray] #W #{?client_prefix,#[fg=$thm_magenta],#[fg=$thm_cyan]}#[bg=$thm_gray]█#{?client_prefix,#[bg=$thm_magenta],#[bg=$thm_cyan]}#[fg=$thm_bg] #[fg=$thm_fg,bg=$thm_gray] #S "

      set -g status-left ""

      # Modes
      set -g clock-mode-colour "$thm_blue"
      set -g mode-style "fg=$thm_blue bg=$thm_black4 bold"
    '';

  };
}
