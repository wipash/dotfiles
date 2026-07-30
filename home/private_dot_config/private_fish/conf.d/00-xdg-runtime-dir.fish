# WSLg sets XDG_RUNTIME_DIR for local WSL sessions, but sshd-spawned sessions
# don't get it: there's no pam_systemd here (systemd=false in /etc/wsl.conf) and
# no WSLg environment. Tools that derive paths from it then look in the wrong
# place over SSH — this is what made atuin wait ~5s on every command.
#
# Numbered 00- so it runs before the other conf.d files that may read it.
if not set -q XDG_RUNTIME_DIR; and test -d /mnt/wslg/runtime-dir
    set -gx XDG_RUNTIME_DIR /mnt/wslg/runtime-dir
end
