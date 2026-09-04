function nixedit --description 'Open NixOS configuration in VS Code and close terminal'
    code /etc/nixos/configuration.nix $argv &; disown; kill -9 $fish_pid
end
