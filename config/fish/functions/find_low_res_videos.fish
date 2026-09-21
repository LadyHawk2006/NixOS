function find_low_res_videos --description 'Find video files below 1080p using ffprobe'
    # Default to current directory if no args given
    set -l paths $argv
    if test (count $paths) -eq 0
        set paths .
    end
    
    # Collect video files
    set -l files
    for p in $paths
        if test -d $p
            set -a files (find $p -type f \( -iname '*.mkv' -o -iname '*.mp4' \))
        else
            set -a files $p
        end
    end
    
    set -l total (count $files)
    echo "Scanning $total file(s)..." >&2
    
    set -l low_res
    set -l i 0
    
    for f in $files
        set i (math $i + 1)
        printf "\r[%d/%d] %s" $i $total (basename $f) >&2
        
        # Get width and height of first video stream
        set -l dims (ffprobe -v error -select_streams v:0 \
                            -show_entries stream=width,height \
                            -of csv=s=x:p=0 "$f" 2>/dev/null)
        
        if test -z "$dims"
            echo "" >&2
            echo "⚠  Could not read video stream: $f" >&2
            continue
        end
        
        set -l wh (string split 'x' $dims)
        set -l w $wh[1]
        set -l h $wh[2]
        
        # Treat anything with height < 1080 as "below 1080p"
        # (also flags non-standard sizes like 1920x800)
        if test $h -lt 1080
            set -a low_res "$w\x$h  $f"
        end
    end
    
    echo "" >&2
    echo "" >&2
    
    if test (count $low_res) -eq 0
        echo "✓ All $total videos are 1080p or higher."
    else
        echo "Found "(count $low_res)" video(s) below 1080p:"
        echo ""
        for line in $low_res
            echo $line
        end
    end
end
