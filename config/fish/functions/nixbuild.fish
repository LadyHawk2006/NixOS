function nixbuild --description 'Rebuild NixOS, rsync configs to ~/.sysbackup, and push to Git'
    ~/.local/bin/rebuild-sync $argv
end
