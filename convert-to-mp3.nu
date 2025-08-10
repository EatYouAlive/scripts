#!/usr/bin/env nu
#
#  ░▒▓████████▓▒░▒▓███████▓▒░░▒▓███████▓▒░ ░▒▓██████▓▒░░▒▓███████▓▒░       ░▒▓████████▓▒░▒▓█▓▒░▒▓███████▓▒░  
#  ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
#  ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
#  ░▒▓██████▓▒░ ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░       ░▒▓██████▓▒░ ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
#  ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
#  ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
#  ░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░ ░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
#                                                                                                            
# Year: 2025.

### NuShell conversion of audio files to .mp3 with 'ffmpeg'

# --- COLORS ---
let info_color = (ansi green)
let warn_color = (ansi yellow)
let error_color = (ansi red)
let reset_color = (ansi reset)

# --- ENCODING METHOD SELECTION ---
print $"($info_color)### Choose an encoding method ###($reset_color)"
mut ffmpeg_quality_option = []

loop {
    print $"1) ($warn_color)[VBR]($reset_color) - 245 kbps avg, high quality"
    print $"2) ($warn_color)[CBR]($reset_color) - 320 kbps constant, max size"
    let choice = (input "Your choice (1, 2): ")

    if $choice == "1" {
        print $"($info_color)[✔] VBR encoding selected.($reset_color)"
        let ffmpeg_quality_option_tmp = ["-codec:a" "libmp3lame" "-qscale:a" "0"]
        mut ffmpeg_quality_option = $ffmpeg_quality_option_tmp
        break
    } else if $choice == "2" {
        print $"($info_color)[✔] CBR encoding selected.($reset_color)"
        let ffmpeg_quality_option_tmp = ["-codec:a" "libmp3lame" "-b:a" "320k"]
        mut ffmpeg_quality_option = $ffmpeg_quality_option_tmp
        break
    } else {
        print $"($error_color)[✘] Invalid choice, please try again.($reset_color)"
    }
}

# --- ENSURE OUTPUT DIRECTORY ---
print $"($info_color)### Ensuring 'mp3' directory exists...($reset_color)"
if not ("mp3" | path exists) {
    mkdir mp3
}

# --- SEARCH FOR COVER IMAGE ---
print $"($info_color)### Searching for cover image...($reset_color)"
let cover_files = (
    ls | where type == file | where { $in.name =~ '(?i)^(cover|folder)\.(jpg|jpeg|png|gif)$' }
)

mut cover_file = ""
if ($cover_files | is-empty) {
    print $"($warn_color)[!] No cover image found.($reset_color)"
} else {
    let cover_file_tmp = ($cover_files | first).name
    print $"($info_color)[✔] Found cover image: '($cover_file_tmp)'($reset_color)"
    mut cover_file = $cover_file_tmp
}

# --- FIND AUDIO FILES ---
print $"($info_color)### Searching for audio files...($reset_color)"
let audio_files = (
    ls | where type == file | where { $in.name =~ '(?i)\.(flac|wav|ogg|m4a|aac)$' }
)

if ($audio_files | is-empty) {
    print $"($error_color)[✘] No audio files found to convert.($reset_color)"
    exit 1
}

# --- CONVERSION FUNCTION ---
def convert-to-mp3 [source_file: string, quality_opts: list<string>, cover_path?: string] {
    let mp3_file = $"mp3/($source_file | path parse | get stem).mp3"
    print $"($warn_color)→ Converting: '($source_file)' → '($mp3_file)'($reset_color)"

    mut ff_args = ["ffmpeg" "-y" "-i" $source_file]
    if ($cover_path != null and $cover_path != "") {
        $ff_args = ($ff_args | append ["-i" $cover_path "-map" "0:a" "-map" "1:v" "-id3v2_version" "3" "-metadata:s:v" "title=Album cover" "-metadata:s:v" "comment=Cover (front)"])
    }
    $ff_args = ($ff_args | append $quality_opts)
    $ff_args = ($ff_args | append [$mp3_file])

    try {
        run-external $ff_args
        print $"($info_color)[✔] Successfully converted: '($mp3_file)'($reset_color)"
    } catch {
        print $"($error_color)[✘] Failed to convert: '($source_file)'($reset_color)"
    }
}

# --- PROCESS ALL FILES ---
for file_rec in $audio_files {
    let file_path = $file_rec.name
    convert-to-mp3 $file_path $ffmpeg_quality_option $cover_file
}

print $"($info_color)[✓] All conversions completed!($reset_color)"
