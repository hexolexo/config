if status is-interactive
    set -gx EDITOR nvim
    set -gx GOPATH $HOME/.go
    set -gx OBSIDIAN_USE_WAYLAND 1
    set -gx PATH $PATH $HOME/.go/bin $HOME/.cargo/bin

    # Basic aliases
    alias vim='nvim'
    alias neovim='nvim'

    # Optional tools (only load if available)
    if command -v starship >/dev/null
        starship init fish | source
    end
    if command -v thefuck >/dev/null
        thefuck --alias | source
    end
    if command -v nvim >/dev/null
        function man
            nvim -c "Man $argv" -c "wincmd k" -c "q";
        end
    end
    if command -v zoxide >/dev/null
        zoxide init fish | source
        alias cd='z'
    end
    if command -v fzf >/dev/null; and command -v highlight >/dev/null
        function replay
            set -l cmd (history | highlight --syntax=bash --out-format=ansi | fzf --ansi --header='Select command to replay')
            if test -n "$cmd"
                # Clean ANSI codes and execute
                set cmd (string replace -ra '\e\[[0-9;]*m' '' $cmd)
                commandline $cmd
            end
        end
    end
end
