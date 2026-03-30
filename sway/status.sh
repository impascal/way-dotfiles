#!/bin/sh

# Material Design Icons (Nerd Font)
ICON_CPU="󰻠"
ICON_RAM="󰍛"
ICON_BAT="󰁹 "
ICON_CHG="󰂄 "
ICON_WIFI="󰖩 "
ICON_ETH="󰈀 "
ICON_OFF="󰖪 "
ICON_TIME="󰥔 "

# CPU usage
cpu() {
    read cpu a b c idle rest < /proc/stat
    prev_idle=$idle
    prev_total=$((a+b+c+idle))
    sleep 0.5
    read cpu a b c idle rest < /proc/stat
    diff_idle=$((idle - prev_idle))
    diff_total=$(( (a+b+c+idle) - prev_total ))
    echo $((100 * (diff_total - diff_idle) / diff_total))
}

# RAM usage
ram() {
    free | awk '/Mem:/ {printf("%.0f%%\n", $3/$2 * 100)}'
}

# Battery
battery() {
    BAT_PATH="/sys/class/power_supply/BAT0"
    if [ -d "$BAT_PATH" ]; then
        cap=$(cat $BAT_PATH/capacity)
        status=$(cat $BAT_PATH/status)

        # Battery icon levels (Material)
        if [ "$cap" -ge 90 ]; then icon="󰁹"
        elif [ "$cap" -ge 70 ]; then icon="󰂂"
        elif [ "$cap" -ge 50 ]; then icon="󰂀"
        elif [ "$cap" -ge 30 ]; then icon="󰁿"
        elif [ "$cap" -ge 15 ]; then icon="󰁾"
        else icon="󰁺"
        fi

        if [ "$status" = "Charging" ]; then
            icon="$ICON_CHG"
            time="charging"
        else
            power_now=$(cat $BAT_PATH/power_now 2>/dev/null)
            energy_now=$(cat $BAT_PATH/energy_now 2>/dev/null)

            if [ -n "$power_now" ] && [ "$power_now" -gt 0 ]; then
                hours=$(awk "BEGIN {print $energy_now / $power_now}")
                h=${hours%.*}
                m=$(awk "BEGIN {print int(($hours - $h)*60)}")
                time="${h}h${m}m"
            else
                time="?"
            fi
        fi

        echo "$icon ${cap}% ($time)"
    else
        echo "󰁺 N/A"
    fi
}

# Network
network() {
    iface=$(ip route | awk '/default/ {print $5; exit}')

    if [ -z "$iface" ]; then
        echo "$ICON_OFF offline"
        return
    fi

    case "$iface" in
        wl*)
            ssid=$(iw dev "$iface" link | awk -F': ' '/SSID/ {print $2}')
	    signal=$(nmcli -c no -t -f IN-USE,SIGNAL dev wifi | awk -F: '$1=="*"{print $2 "%"; exit}')
            if [ -n "$ssid" ]; then
	        echo "$ICON_WIFI $ssid ($signal)"
            else
                echo "$ICON_WIFI disconnected"
            fi
            ;;
        en*|eth*)
            echo "$ICON_ETH wired"
            ;;
        *)
            echo "$ICON_WIFI $iface"
            ;;
    esac
}

volume() {
    vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
    muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo yes)

    if [ "$muted" = "yes" ]; then
        echo "󰖁 mute"
        return
    fi

    # Icon levels
    if [ "$vol" -ge 70 ]; then icon="󰕾 "
    elif [ "$vol" -ge 30 ]; then icon="󰖀 "
    else icon="󰕿 "
    fi

    echo "$icon ${vol}%"
}

brightness() {
    cur=$(brightnessctl g)
    max=$(brightnessctl m)

    percent=$((cur * 100 / max))

    # Icon levels
    if [ "$percent" -ge 70 ]; then icon="󰃠 "
    elif [ "$percent" -ge 30 ]; then icon="󰃟 "
    else icon="󰃞 "
    fi

    echo "$icon ${percent}%"
}

# Date & time
datetime() {
    date "+$ICON_TIME %H:%M %d/%m/%Y"
}

# Output
while true; do
    echo "$ICON_CPU $(cpu)% | $ICON_RAM $(ram) | $(battery) | $(network) | $(volume) | $(brightness) | $(datetime) "
    sleep 0.1
done
