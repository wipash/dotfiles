if set -q HERDR_ENV
    set -gx SSH_AUTH_SOCK $HOME/.ssh/agent/forwarded
end
