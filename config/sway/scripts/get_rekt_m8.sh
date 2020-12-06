swaymsg workspace getrekt

term=termite

$term -e "/home/william/.config/i3/scripts/get_rekt_m8_sub.sh" &

sleep 4

$term -e "cmatrix -C blue" &
sleep 0.2
swaymsg move up
sleep 0.2

$term -e "cmatrix -C white" &
sleep 0.2
swaymsg move right
sleep 0.2

$term -e "cmatrix" &
sleep 0.2
swaymsg move up
sleep 0.2

$term -e "cmatrix -C cyan" &
sleep 0.2
swaymsg move left
swaymsg move left
sleep 0.2

$term -e "cmatrix -C yellow" &
sleep 0.2
swaymsg layout toggle split
swaymsg layout toggle split
sleep 0.2

$term -e "cmatrix -C magenta" &
sleep 0.2

$term -e "cmatrix -C blue" &
sleep 0.2
swaymsg move down
sleep 0.2

/home/william/.config/i3/scripts/get_rekt_m8.sh &

sleep 16

shutdown now

#green, red, blue, white, yellow, cyan, magenta and black.

#for i in {0..6}
#do
#	$term -e cmatrix &
#	swaymsg move up
#	sleep 0.4
#done
