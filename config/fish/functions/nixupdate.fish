function nixupdate -d "Update NixOS flake inputs and trigger a sync rebuild"
    set -l flake_dir ~/.config/nixos

    set_color cyan
    echo "=> Updating NixOS flake inputs in $flake_dir..."
    set_color normal

    # Update the flake.lock file
    sudo nix flake update --flake $flake_dir

    if test $status -ne 0
        set_color red
        echo "=> Error: Flake update failed. Aborting rebuild."
        set_color normal
        return 1
    end

    set_color green
    echo "=> Flake inputs updated successfully. Triggering nixbuild..."
    set_color normal

    # Call your custom rebuild script so the new flake.lock gets committed and synced
    nixbuild
end
