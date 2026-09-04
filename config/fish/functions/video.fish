function video --description 'Download video in max 1440p (MKV) preferring H.265 > H.264'
    if test (count $argv) -eq 0
        echo "Error: Please provide a video URL."
        echo "Usage: video <URL>"
        return 1
    end

    yt-dlp \
        -f "bestvideo[height<=1440][vcodec^=hev1]+bestaudio/bestvideo[height<=1440][vcodec^=hvc1]+bestaudio/bestvideo[height<=1440][vcodec^=avc1]+bestaudio/best[height<=1440]" \
        -S "res:1440,vcodec:hevc,vcodec:h264" \
        --merge-output-format mkv \
        --write-subs \
        --sub-langs "en.*" \
        --embed-subs \
        --embed-metadata \
        --embed-thumbnail \
        --no-warnings \
        -o "%(title)s.%(ext)s" \
        $argv
end
