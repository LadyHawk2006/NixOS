#!/usr/bin/env python3
import re
import subprocess
from pathlib import Path


def extract_ep_num(filename: str) -> str | None:
    """Extract episode number normalized without leading zeros."""
    match = re.search(r"(?:E|EP|Episode[._\s]*)0*(\d+)", filename, re.IGNORECASE)
    return match.group(1) if match else None


def main():
    cwd = Path.cwd()
    mp4_files = sorted(cwd.glob("*.mp4"))

    if not mp4_files:
        print("Error: No MP4 files found in the current directory.")
        return

    # Index all SRT files by their extracted episode number
    srt_map = {}
    for srt in cwd.glob("*.srt"):
        ep = extract_ep_num(srt.name)
        if ep:
            srt_map[ep] = srt

    for video in mp4_files:
        ep_num = extract_ep_num(video.name)
        if not ep_num:
            print(f"Skipping '{video.name}': Could not parse episode number.")
            continue

        srt_file = srt_map.get(ep_num)
        output_mkv = video.with_suffix(".mkv")

        if srt_file:
            print(f"Processing: {video.name} + {srt_file.name} -> {output_mkv.name}")
            cmd = [
                "ffmpeg",
                "-hide_banner",
                "-loglevel",
                "warning",
                "-i",
                str(video),
                "-i",
                str(srt_file),
                "-c:v",
                "copy",
                "-c:a",
                "copy",
                "-c:s",
                "ass",
                "-metadata:s:s:0",
                "language=eng",
                "-metadata:s:s:0",
                "title=English",
                str(output_mkv),
            ]

            result = subprocess.run(cmd)
            if result.returncode != 0:
                print(f"Error processing {video.name}")
        else:
            print(f"Warning: No matching SRT file found for episode {ep_num} ({video.name})")


if __name__ == "__main__":
    main()