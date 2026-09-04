function music
    set DOWNLOAD_DIR "$HOME/Music/yt-downloads"
    mkdir -p "$DOWNLOAD_DIR"

    if test (count $argv) -eq 0
        echo "Usage: music <url> [url2] [url3] ..."
        return 1
    end

    for url in $argv
        echo "Processing: $url"

        if string match -q "*playlist*" "$url"; or string match -q "*list=*" "$url"
            echo "Playlist detected, creating folder..."

            # Use yt-dlp's --print feature to get the playlist title directly
            set PLAYLIST_TITLE (yt-dlp --print playlist_title --flat-playlist --playlist-end 1 "$url" 2>/dev/null)

            # If that fails, try alternative method
            if test -z "$PLAYLIST_TITLE"
                # Use the JSON output with jq
                set PLAYLIST_TITLE (yt-dlp -J --flat-playlist --playlist-end 1 "$url" 2>/dev/null | \
                    jq -r '.playlist_title' 2>/dev/null)
            end

            # If we still don't have it, use the download output
            if test -z "$PLAYLIST_TITLE"
                # Run yt-dlp in dry-run mode to get the playlist name from output
                set PLAYLIST_TITLE (yt-dlp --flat-playlist --playlist-end 1 --dry-run "$url" 2>&1 | \
                    grep "Downloading playlist:" | \
                    sed 's/.*Downloading playlist: //' | \
                    head -1)
            end

            # Clean up folder name
            set PLAYLIST_FOLDER (echo "$PLAYLIST_TITLE" | \
                sed 's/[^a-zA-Z0-9 _-]//g' | \
                sed 's/^ *//;s/ *$//' | \
                sed 's/  */ /g')

            if test -z "$PLAYLIST_FOLDER"
                set PLAYLIST_FOLDER "playlist_"(date +%Y%m%d_%H%M%S)
            end

            set PLAYLIST_DIR "$DOWNLOAD_DIR/$PLAYLIST_FOLDER"
            mkdir -p "$PLAYLIST_DIR"

            echo "Downloading playlist '$PLAYLIST_TITLE' to: $PLAYLIST_DIR"

            yt-dlp -x --audio-format opus --audio-quality 0 \
                --embed-thumbnail --add-metadata \
                -o "$PLAYLIST_DIR/%(playlist_index)s - %(title)s.%(ext)s" \
                "$url"
        else
            echo "Downloading single track to: $DOWNLOAD_DIR"
            yt-dlp -x --audio-format opus --audio-quality 0 \
                --embed-thumbnail --add-metadata \
                -o "$DOWNLOAD_DIR/%(title)s.%(ext)s" \
                "$url"
        end
    end

    echo "Download complete!"
end
