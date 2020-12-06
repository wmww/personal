 
nautilus /home/william/code/python_plus_plus/ &
sleep 0.8
#gedit /home/william/code/python_plus_plus/ppp.h &
#sleep 0.8
gedit --new-window /home/william/code/python_plus_plus/examples/fizz_buzz.ppp &
sleep 0.8
gnome-terminal --working-directory=/home/william/code/python_plus_plus/ &
sleep 0.8
i3-msg move up
sleep 0.8
i3-msg move right
sleep 0.4
gnome-terminal --working-directory=/home/william/code/python_plus_plus/ &
sleep 0.4
i3-msg layout toggle split
sleep 0.4
i3-msg layout toggle split

