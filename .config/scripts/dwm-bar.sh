#!/bin/sh

ram() {
	mem=$(free -h | awk '/Mem:/ { print $3 }' | cut -f1 -d 'i')
	echo   "$mem"
}

bat(){

    battery_info=$(acpi -b | sed -n '2p') 
    battery_status=$(echo "$battery_info" | awk '{print $3}' | sed 's/,$//') 
	battery_time=$(acpi -b | sed -n '2p' | awk '{print $5}' | sed 's/:..$//')

	if [ "$battery_status" = "Charging" ]; then
        BAT=""
    elif [ "$battery_status" = "Discharging" ]; then
    	BAT=""
    fi

	bat=$(cat /sys/class/power_supply/BAT1/capacity)
	echo "$BAT"" $bat"% "$battery_time |"
}

battery() {
    # Get battery device path.
    battery=$(upower -e | grep 'battery_BAT1')

    if [ -z "$battery" ]; then
        echo "No battery found."
        exit 1
    fi

    # Get battery percentage
    percentage=$(upower -i "$battery" | grep -E "percentage" | awk '{print $2}')

    # Get state: charging, discharging, fully-charged
    state=$(upower -i "$battery" | grep -E "state" | awk '{print $2}')

    # Get time to full or empty
    if [ "$state" = "discharging" ]; then
        time=$(upower -i "$battery" | grep -E "time to empty" | awk '{$1=$2=""; print $0}' | sed 's/^ *//')
        echo " $percentage ($time)"
    elif [ "$state" = "charging" ]; then
        time=$(upower -i "$battery" | grep -E "time to full" | awk '{$1=$2=""; print $0}' | sed 's/^ *//')
        echo " $percentage ($time)"
    else
        echo "$percentage $state"
    fi
}

cpu() {
	read -r cpu a b c previdle rest < /proc/stat
	prevtotal=$((a+b+c+previdle))
	sleep 0.5
	read -r cpu a b c idle rest < /proc/stat
	total=$((a+b+c+idle))
	cpu=$((100*( (total-prevtotal) - (idle-previdle) ) / (total-prevtotal) ))
	echo  "$cpu"%
}

temperature(){
	# Get temperature information
	temperature=$(sensors | grep -i 'edge:' | awk '{print $2}')
	
	if [ -z "$temperature" ]; then
		echo "Could not retrieve temperature data."
	else
		echo " $temperature"
fi
}

network_status() {
	conntype=$(ip route | awk '/default/ { print substr($5,1,1) }')

	if [ -z "$conntype" ]; then
		echo " down"
	elif [ "$conntype" = "e" ]; then
		echo " up"
	elif [ "$conntype" = "w" ]; then
		echo " up"
	fi
}

network_name() {

	# Get the active connection name using nmcli
	# Can me NAME,DEVICE,TYPE,STATE
	active_connection=$(nmcli -t -f NAME connection show --active | head -n 1)
	echo " $active_connection"
}

volume_pa() {

	
	muted=$(pamixer --get-mute)
	vol=$(pamixer --get-volume)

	if [ "$muted" = "true" ]; then
		echo ""
	else
		if [ "$vol" -ge 65 ]; then
			echo " $vol%"
		elif [ "$vol" -ge 40 ]; then
			echo " $vol%"
		elif [ "$vol" -ge 0 ]; then
			echo " $vol%"	
		fi
	fi

}

clock() {
	dte=$(date +"%A %d-%b-%Y")
	time=$(date +"%H:%M")

	echo " $dte | $time"
}

while true; do
	xsetroot -name "$(battery)  $(ram)  $(cpu)  $(temperature)  $(volume_pa)  $(network_name)  $(clock) ";
    sleep 0,01s
done &
