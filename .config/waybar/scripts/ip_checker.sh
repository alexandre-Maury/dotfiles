#!/bin/bash

local option="$1"
local wifi_iface=""
local wifi_info=""
local wifi_ip=""
local ethernet_iface=""
local ethernet_ip=""
local found_connection=false
local public_ip=""
local rx_bytes
local tx_bytes

# Récupérer les interfaces réseau
interfaces=$(ip -o link show | awk -F': ' '{print $2}')

for iface in $interfaces; do
	# Ignorer l'interface loopback
    if [[ "$iface" == "lo" ]]; then
        continue
    fi

    # Récupérer l'adresse IP de l'interface
    ip_address=$(ip -4 addr show "$iface" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

    if [[ -n "$ip_address" ]]; then
        found_connection=true
        if [[ "$iface" == wlan* ]]; then
            wifi_iface=$iface
            wifi_ip=$ip_address
            wifi_info=$(iw dev "$iface" link | grep -Eo "SSID: .+" | sed 's/SSID: //')
            wifi_signal=$(iw dev "$iface" link | grep -Eo "signal: .+" | sed 's/signal: //')
        else
            ethernet_iface=$iface
            ethernet_ip=$ip_address
        fi
    fi
done

# Traiter l'option
case "$1" in
    "status")
        if $found_connection; then
            # Prioriser Wi-Fi
            if [[ -n "$wifi_ip" ]]; then
                echo "   $wifi_info  ($wifi_signal)"
            elif [[ -n "$ethernet_ip" ]]; then
                echo "   $ethernet_iface"
            fi
        else
            echo "   Aucune connexion réseau détectée."
        fi
        ;;

    "network")
        if $found_connection; then
            public_ip=$(curl -s https://api.ipify.org)

            # Prioriser Wi-Fi
            if [[ -n "$wifi_ip" ]]; then
                local_ip=$wifi_ip
            elif [[ -n "$ethernet_ip" ]]; then
                local_ip=$ethernet_ip
            fi

            echo "󰩠  $local_ip | $public_ip"

        else
            echo "󰩠  x.x.x.x | x.x.x.x"
        fi
        ;;

    "traffic")
        if $found_connection; then
            # Prioriser Wi-Fi
            if [[ -n "$wifi_iface" ]]; then
                iface=$wifi_iface
            elif [[ -n "$ethernet_iface" ]]; then
                iface=$ethernet_iface
            fi

            # Récupérer les statistiques réseau à intervalles
            if [[ -d "/sys/class/net/$iface/statistics" ]]; then
                # Récupérer les octets initiaux
                prev_rx_bytes=$(cat /sys/class/net/$iface/statistics/rx_bytes)
                prev_tx_bytes=$(cat /sys/class/net/$iface/statistics/tx_bytes)
                prev_time=$(date +%s)

                sleep 1  # Attendre 1 seconde pour mesurer la vitesse

                # Récupérer les octets après 1 seconde
                rx_bytes=$(cat /sys/class/net/$iface/statistics/rx_bytes)
                tx_bytes=$(cat /sys/class/net/$iface/statistics/tx_bytes)
                curr_time=$(date +%s)

                # Calculer la différence des octets et le temps écoulé
                rx_diff=$((rx_bytes - prev_rx_bytes))
                tx_diff=$((tx_bytes - prev_tx_bytes))
                time_diff=$((curr_time - prev_time))

                # Calculer la vitesse en Ko/s
                speed_rx=$(echo "scale=2; $rx_diff / $time_diff / 1024" | bc)
                speed_tx=$(echo "scale=2; $tx_diff / $time_diff / 1024" | bc)

                # Convertir en Mo/s si la vitesse est supérieure à 1 Mo/s
                if (( $(echo "$speed_rx >= 1024" | bc -l) )); then
                    speed_rx=$(echo "scale=2; $speed_rx / 1024" | bc)
                    rx_unit="MB/s"
                else
                    rx_unit="KB/s"
                fi

                if (( $(echo "$speed_tx >= 1024" | bc -l) )); then
                    speed_tx=$(echo "scale=2; $speed_tx / 1024" | bc)
                    tx_unit="MB/s"
                else
                    tx_unit="KB/s"
                fi

                echo "󰛴  ${speed_rx} ${rx_unit} | 󰛶  ${speed_tx} ${tx_unit}"
                
            else
                echo "Statistiques indisponibles pour $iface."
            fi

        else
            echo "   Aucun trafic réseau détecté."
        fi
        ;;
        
    *)
        echo "Usage : $0 --status | --network | --traffic"
        exit 1
        ;;
esac




