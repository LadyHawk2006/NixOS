for video in My_Little_Happiness_720P_S01_E*.mp4
      set base (basename $video .mp4)
      set num (string match -r 'E0*(\d+)' $video)[2]
      set srt_file "My_Little_Happiness_S1_E$num""_English.srt"

      if test -f "$srt_file"
          ffmpeg -i "$video" -i "$srt_file" \
                          -c:v copy -c:a copy \
                          -c:s ass \
                          -metadata:s:s:0 language=eng \
                          -metadata:s:s:0 title="English" \
                          "$base.mkv"
      else
          echo "Warning: $srt_file not found for $video"
      end
  end
