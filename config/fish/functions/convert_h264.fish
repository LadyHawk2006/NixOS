function convert_h264 --description 'Convert MKV videos to H264 in ~/Videos/H264 and remove source on success'
    mkdir -p ~/Videos/H264
    for file in *.mkv
        test -f "$file"; or continue
        echo "Converting: $file"
        ffmpeg -hide_banner -loglevel warning -stats \
                        -i "$file" \
                        -c:v libx264 \
                        -preset slow \
                        -crf 18 \
                        -pix_fmt yuv420p \
                        -movflags +faststart \
                        -c:a copy \
                        -c:s copy \
                        ~/Videos/H264/"$file" && rm -v "$file"
    end
end
