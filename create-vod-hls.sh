#!/usr/bin/env bash

set -e

[[ ! "${1}" ]] && echo "Usage : create-vod-hls.sh SOURCE_FILE [OUTPUT_NAME]" && exit 1

# control which renditions would be created
renditions=(
# resolution bitrate audio-rate bitrate : maxrate , bufsize
 #   "640x360   800k    96k"
 #   "842x480   1400k   128k"
    "1280x720  2800k   128k"
 #   "1920x1080 5000k   192k"
)

segment_target_duration=0.5 #secs
max_bitrate_ratio=1.07 
rate_monitor_buffer_ratio=1.5

source="${1}"
target="${2}"
if [[ ! "${target}" ]]; then
    target="${source##*/}"
    target="${target%.*}"
fi
mkdir -p ${target}

#key_frames_interval="$(echo `ffprobe ${source} 2>&1 | grep -oE '[[:digit:]]+(.[[:digit:]]+)? fps' | grep -oE '[[:digit:]]+(.[[:digit:]]+)?'`*2 | bc || echo '')"
#key_frames_interval=${key_frames_interval:-50}
#key_frames_interval=$(echo `printf "%.1f\n" $(bc -l <<<"$key_frames_interval/10")`*10 | bc) # round
#key_frames_interval=${key_frames_interval%.*}
key_frames_interval=12

static_params="-c:a aac -ar 48000 -c:v h264 -profile:v main -crf 20 -sc_threshold 0"
static_params+=" -g ${key_frames_interval} -keyint_min ${key_frames_interval} -hls_time ${segment_target_duration}"
static_params+=" -hls_playlist_type vod"

misc_params="-hide_banner -y"
master_playlist="#EXTM3U
#EXT-X-VERSION:3
"
cmd=""
for rendition in "${renditions[@]}"; do
    # read rendition fields
    rendition="${rendition/[[:space:]]+/ }"
    resolution="$(echo ${rendition} | cut -d ' ' -f 1)"
    bitrate="$(echo ${rendition} | cut -d ' ' -f 2)"
    audiorate="$(echo ${rendition} | cut -d ' ' -f 3)"

    width="$(echo ${resolution} | grep -oE '^[[:digit:]]+')"
    height="$(echo ${resolution} | grep -oE '[[:digit:]]+$')"
    maxrate="$(echo "`echo ${bitrate} | grep -oE '[[:digit:]]+'`*${max_bitrate_ratio}" | bc)"
    bufsize="$(echo "`echo ${bitrate} | grep -oE '[[:digit:]]+'`*${rate_monitor_buffer_ratio}" | bc)"
    bandwidth="$(echo ${bitrate} | grep -oE '[[:digit:]]+')000"
    name="${height}p"

    cmd+=" ${static_params} -vf scale=w=${width}:h=${height}:force_original_aspect_ratio=decrease"
    cmd+=" -b:v ${bitrate} -maxrate ${maxrate%.*}k -bufsize ${bufsize%.*}k -b:a ${audiorate}"
    cmd+=" -hls_segment_filename ${target}/${name}_%03d.ts ${target}/${name}.m3u8"
    master_playlist+="#EXT-X-STREAM-INF:BANDWIDTH=${bandwidth},RESOLUTION=${resolution}\n${name}.m3u8\n"
done

echo -e "Executing command:\nffmpeg ${misc_params} -i ${source} ${cmd}"
ffmpeg ${misc_params} -i ${source} ${cmd}

echo -e "${master_playlist}" > ${target}/playlist.m3u8
echo "Done - encoded HLS is at ${target}/"
   
