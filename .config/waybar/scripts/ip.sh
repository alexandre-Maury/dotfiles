#!/bin/bash

get_network_status() {
    # Vérifier si on est connecté en Wi-Fi ou Ethernet
    wifi_iface=$(iw dev | awk '$1=="Interface"{print $2}')  # Trouve l'interface Wi-Fi
    ethernet_iface=$(ip link show | awk -F': ' '/^[0-9]+: / && !/lo/ && !/wl/{print $2}')  # Trouve l'interface Ethernet

    if [ -n "$wifi_iface" ]; then
        # Si une interface Wi-Fi est trouvée, récupérer le SSID et la force du signal
        ssid=$(iw dev "$wifi_iface" link | awk -F': ' '/SSID/ {print $2}')
        signal_strength=$(iw dev "$wifi_iface" link | awk -F': ' '/signal/ {print $2}')

        # Afficher l'icône Wi-Fi, le SSID et la force du signal
        echo "    $ssid  ($signal_strength dBm)"
    elif [ -n "$ethernet_iface" ]; then
        # Si une interface Ethernet est trouvée, afficher l'icône Ethernet
        echo "    $ethernet_iface"
    else
        # Si aucune connexion n'est trouvée, afficher une icône d'erreur
        echo "   No Network"
    fi
}

# Fonction pour obtenir l'adresse IP locale
get_network_ip() {
        
    INTERFACE=$(ip link show | awk -F': ' '/^[0-9]+: / && !/lo/ {print $2; exit}')
    
    local_ip=$(ip -4 addr show dev "$INTERFACE" | grep inet | awk '{print $2}' | cut -d'/' -f1)
    public_ip=$(curl -s https://icanhazip.com)
    
    # Affichage des résultats dans un format adapté pour Waybar
    echo "󰩠 $local_ip | $public_ip"
}

# Fonction principale pour surveiller le trafic
get_network_traffic() {
        # Récupérer l'interface active
    iface=$(ip link show | awk -F': ' '/^[0-9]+: / && !/lo/ {print $2; exit}')

    # Si aucune interface active n'est trouvée, afficher un message d'erreur
    if [ -z "$iface" ]; then
        echo "{\"text\": \"No active interface\"}"
        exit 1
    fi

    # Récupérer les statistiques de trafic initiales
    declare -a traffic_prev traffic_curr traffic_delta
    traffic_prev=( 0 0 0 0 )

    # Récupérer les données actuelles de trafic
    traffic_curr=( $(awk "/^ *$iface:/{print \$2 \" \" \$10}" /proc/net/dev) )

    # Calculer la différence entre les valeurs actuelles et précédentes
    for i in {0..1}; do
        (( traffic_delta[i] = ( traffic_curr[i] - traffic_prev[i] ) ))
    done

    units=( B K M G T P )
    
    valuerx=${traffic_delta[0]} # Réception (RX)
    indexrx=0
    # Convertir les octets en bits
    valuerx=$((valuerx * 8)) # Multiplier par 8 pour obtenir des bits
    while (( valuerx > 1000 && indexrx < 5 )); do
       (( valuerx /= 1000, indexrx++ ))
    done
    rx_bps="$valuerx${units[$indexrx]}"

    valuetx=${traffic_delta[1]} # Envoi (TX)
    indextx=0
    # Convertir les octets en bits
    valuetx=$((valuetx * 8)) # Multiplier par 8 pour obtenir des bits
    while (( valuetx > 1000 && indextx < 5 )); do
       (( valuetx /= 1000, indextx++ ))
    done
    tx_bps="$valuetx${units[$indextx]}"
    
    # Afficher les résultats sous forme de JSON pour Waybar
    echo "󰛴 $rx_bps - 󰛶 $tx_bps"

}

# Selon l'argument passé, on exécute la fonction correspondante
case $1 in
    "network")
        get_network_ip
        ;;
    "traffic")
        get_network_traffic
        ;;
    "status")
        get_network_status
        ;;
        
        
    *)
        echo "Module non supporté"
        exit 1
        ;;
esac
