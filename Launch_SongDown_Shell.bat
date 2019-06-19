ubuntu1804.exe run "sh -ic 'if [ -z \"$(pidof dbus-launch)\" ]; then export DISPLAY=127.0.0.1:0.0; dbus-launch --exit-with-x11; fi;'"

REM ### Go to the selected folder path and open your terminal app

start /min ubuntu1804.exe run "cd \"$(wslpath '%1')\"; export DISPLAY=127.0.0.1:0.0; xfce4-terminal -H -e 'bash --rcfile set_songdown_alias.sh'"
