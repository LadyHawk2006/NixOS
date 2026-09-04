function ytplay
    # Stream YouTube playlists using yt-dlp and mpv
    # Usage: ytplay <youtube-playlist-url> [options]
    # Example: ytplay https://www.youtube.com/playlist?list=PLxxxxx
    #          ytplay https://www.youtube.com/playlist?list=PLxxxxx --no-video
    
    if test (count $argv) -lt 1
        echo "Usage: ytplay <youtube-playlist-url> [yt-dlp options]"
        return 1
    end
    
    set -l url $argv[1]
    set -l ytdlp_options $argv[2..-1]
    
    # Extract cookies from Chrome
    set -l cookie_file (mktemp /tmp/youtube_cookies.XXXXXX)
    
    echo "Extracting cookies from Chrome..."
    yt-dlp --cookies-from-browser chrome --cookies $cookie_file > /dev/null 2>&1
    
    if test $status -ne 0
        echo "Failed to extract cookies from Chrome. Trying without cookies..."
        set -e cookie_file
    end
    
    # Play the playlist with mpv
    echo "Streaming playlist..."
    
    if set -q cookie_file
        mpv --ytdl-format="bestvideo[height<=?1080][fps<=?60]+bestaudio/best" \
                        --cache=yes \
                        --cache-secs=300 \
                        --demuxer-max-bytes=10M \
                        --demuxer-readahead-secs=20 \
                        --ytdl-raw-options="cookies=$cookie_file,extract-audio=" \
                        $ytdlp_options \
                        $url
    else
        mpv --ytdl-format="bestvideo[height<=?1080][fps<=?60]+bestaudio/best" \
                        --cache=yes \
                        --cache-secs=300 \
                        --demuxer-max-bytes=10M \
                        --demuxer-readahead-secs=20 \
                        $ytdlp_options \
                        $url
    end
    
    # Clean up temp cookie file
    if set -q cookie_file
        rm -f $cookie_file
    end
end
