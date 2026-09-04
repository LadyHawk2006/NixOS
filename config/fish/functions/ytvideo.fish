function ytvideo --description 'Search YouTube and queue results into an mpv playlist'
    # Help/usage
    if set -q argv[1]; and string match -rq -- '^(-h|--help)$' $argv[1]
        echo "Usage: ytvideo [OPTIONS] <search query>"
        echo ""
        echo "Options:"
        echo "  -n, --count N    Number of results to fetch (default: 10, max: 50)"
        echo "  -s, --shuffle    Enable shuffling (default: disabled)"
        echo "  -q, --quality    Max quality (default: 1080, options: 720, 1080, 2160)"
        echo "  -h, --help       Show this help"
        return 0
    end

    # Parse arguments
    set -l count 10
    set -l shuffle ""
    set -l quality "1080"
    set -l query ""

    while test (count $argv) -gt 0
        switch $argv[1]
            case -n --count
                set count $argv[2]
                set -e argv[1..2]
            case -s --shuffle
                set shuffle "--shuffle"
                set -e argv[1]
            case -q --quality
                set quality $argv[2]
                set -e argv[1..2]
            case '-*'
                echo "Error: Unknown option $argv[1]"
                return 1
            case '*'
                set query $query $argv[1]
                set -e argv[1]
        end
    end

    # Validate query
    if test -z "$query"
        echo "Error: Please provide a search query."
        echo "Use -h for usage information."
        return 1
    end

    # Validate count
    if not string match -rq -- '^\d+$' $count; or test $count -lt 1; or test $count -gt 50
        echo "Error: Count must be a number between 1 and 50"
        return 1
    end

    # Validate quality
    if not contains $quality 720 1080 2160
        echo "Warning: Unsupported quality '$quality'. Using 1080p."
        set quality 1080
    end

    # User feedback
    set -l shuffle_status (test -n "$shuffle"; and echo "shuffled" || echo "ordered")
    echo "🎵 Fetching $count results for: $query ($shuffle_status, max $quality""p)"

    # Build and run mpv command
    set -l format "bestvideo[height<=?$quality]+bestaudio/best"
    set -l raw_options "no-check-certificates=,ignore-errors=,extractor-args=youtube:skip=comment;shorts;tabs,yes-playlist="

    mpv --ytdl-format="$format" \
        --ytdl-raw-options="$raw_options" \
        --slang=en,eng \
        --demuxer-max-bytes=150MiB \
        $shuffle \
        "ytdl://ytsearch$count:$query"

    # Check exit status
    if test $status -eq 0
        echo "✅ Playback finished or stopped"
    else
        echo "❌ Error: mpv encountered an issue (exit code: $status)"
        return $status
    end
end
