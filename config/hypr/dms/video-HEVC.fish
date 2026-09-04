
for file in *.mp4 *.mkv
      if not test -f "$file"; continue; end

      # 1. Generate the expected output path
      set out_name "HEVC/"(string replace -r '\.[^.]+$' '' $file)".mkv"

      # 2. Skip if the file has already been converted and exists in the HEVC folder
      if test -f "$out_name"
          echo "Skipping '$file' (Output already exists in HEVC/)"
          continue
      end

      # 3. Get the video codec name of the source file
      set codec (ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nocorrectors=1 "$file" | string replace "codec_name=" "")

      # 4. Skip if the source file itself is already HEVC
      if test "$codec" = "hevc"
          echo "Skipping '$file' (Source is already HEVC)"
          continue
      end

      echo "Converting '$file' ($codec -> hevc)..."
      ffmpeg -i "$file" -c:v libx265 -crf 28 -c:a copy "$out_name"
  end