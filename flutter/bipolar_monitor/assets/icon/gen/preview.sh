set -e
A=$1
magick $A/icon_background.png $A/icon_foreground.png -composite -gravity center -crop 683x683+0+0 +repage -resize 192x192 -alpha set adaptive192.png
magick adaptive192.png mask_circle.png -compose DstIn -composite preview_circle.png
magick adaptive192.png mask_squircle.png -compose DstIn -composite preview_squircle.png
magick $A/icon_monochrome.png -gravity center -crop 683x683+0+0 +repage -resize 192x192 -fill '#2F4F44' -colorize 100 mono.png
magick -size 192x192 xc:'#CFE8DE' mono.png -composite -alpha set mask_circle.png -compose DstIn -composite preview_themed.png
for c in F2F2F2:light 202124:dark; do magick -size 640x232 "xc:#${c%%:*}" preview_circle.png -geometry +16+20 -composite preview_squircle.png -geometry +224+20 -composite preview_themed.png -geometry +432+20 -composite previews_${c##*:}.png; done
magick previews_light.png previews_dark.png -append previews_all.png
magick $A/icon.png -resize 48x48 icon48.png; magick icon48.png -filter point -resize 400% icon48x4.png
