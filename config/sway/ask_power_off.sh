zenity --question --text "Are you sure you want to shutdown?"

ans=$?

if (($ans == 0)); then

shutdown now

fi
