function tv --description 'Launch IPTV categories in mpv with interactive fuzzy search'
    set -l playlist_dir "$HOME/.config/mpv/categories"
    
    # Verify the directory exists
    if not test -d $playlist_dir
        echo "Directory $playlist_dir does not exist."
        return 1
    end
    
    # Handle 'tv list' (Static clean list)
    if test "$argv[1]" = "list"
        set -l files (string replace -r '\.m3u$' '' (ls $playlist_dir/*.m3u 2>/dev/null))
        if test -n "$files"
            echo -e "\e[1;34m╭─ Available IPTV Categories ───────────────────╮\e[0m"
            for file in (basename -a $files)
                echo -e "  \e[33m▶\e[0m $file"
            end
            echo -e "\e[1;34m╰───────────────────────────────────────────────╯\e[0m"
        else
            echo "No .m3u playlists found in $playlist_dir"
        end
        return 0
    end
    
    # Interactive Fuzzy Search (When just typing 'tv' with no arguments)
    if test -z "$argv[1]"
        # Get list of clean category names
        set -l categories (string replace -r '\.m3u$' '' (basename -a $playlist_dir/*.m3u 2>/dev/null))
        
        if test -z "$categories"
            echo "No categories found in $playlist_dir"
            return 1
        end
        
        # Pipe names into fzf with a clean custom prompt
        set -l selection (string join \n $categories | fzf --height=40% --layout=reverse --prompt=" Select IPTV Category: ")
        
        # If user escapes or presses Ctrl+C, exit gracefully
        if test -z "$selection"
            return 0
        end
        
        # Play the selection
        mpv --script-opts=iptv=1 "$playlist_dir/$selection.m3u"
        return 0
    end
    
    # Direct Launch (When typing 'tv comedy', 'tv kids', etc.)
    set -l target_file "$playlist_dir/$argv[1].m3u"
    if test -f $target_file
        mpv --script-opts=iptv=1 $target_file
    else
        echo -e "\e[1;31mError:\e[0m Category '$argv[1]' not found in $playlist_dir"
        echo "Type 'tv' for interactive mode or 'tv list' to see static list."
        return 1
    end
end
