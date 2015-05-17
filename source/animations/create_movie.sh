#!/bin/bash -e

frame_count=$(ls patch_*.png | wc -l)
echo "converting $frame_count frames ..."

for (( i=1; i<="$frame_count"; i++ )); do
    number=$(printf "%08d" $i)
    echo "converting frame $i of $frame_count"

    mogrify -resize 256x256 "patch_$number.png"  "patch_$number.png"
    mogrify -resize 256x256 "events_$number.png" "events_$number.png"
    convert -colorspace RGB "world_$number.png" '(' "patch_$number.png" "events_$number.png" -append ')' -gravity center +append "animation_$number.png"
done

echo "OK"

echo "creating movie ..."
ffmpeg -framerate 30 -i "animation_%08d.png" -c:v libx264 animation.mp4

