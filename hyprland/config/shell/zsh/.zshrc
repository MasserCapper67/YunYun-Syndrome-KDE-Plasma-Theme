# Loaded by yunyun-shell for zsh: your own .zshrc first, then the YunYun extras

ZDOTDIR="$YUNYUN_ZDOTDIR"
[[ -f "$ZDOTDIR/.zshrc" ]] && source "$ZDOTDIR/.zshrc"

(( $+commands[starship] )) && eval "$(starship init zsh)"
fastfetch() { command fastfetch --config "$YUNYUN_CONFIG_DIR/fastfetch/config.jsonc" "$@"; }
