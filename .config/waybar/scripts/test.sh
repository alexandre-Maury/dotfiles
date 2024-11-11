#!/bin/bash


# Fonction pour détecter l'interface réseau active (non loopback)
get_active_iface() {
    # On récupère la première interface non loopback (ex: eth0, wlan0)
    ip link show | awk -F': ' '/^[0-9]+: / && !/lo/ {print $2; exit}'
}

# Fonction pour convertir les valeurs en format lisible (B, K, M, G)
human_readable() {
    local value=$1
    local units=( B K M G T P )
    local index=0
    while (( value > 1000 && index < 5 )); do
        (( value /= 1000, index++ ))
    done
    echo "$value${units[$index]}"
}

# Fonction pour obtenir les statistiques de trafic de l'interface
get_traffic() {
    local iface=$1
    # Récupère les statistiques d'octets reçus (RX) et envoyés (TX) de l'interface
    awk "/^ *$iface:/{print \$2 \" \" \$10}" /proc/net/dev
}

# Fonction principale pour surveiller le trafic
parse_traffic() {
    # Récupérer l'interface active
    iface=$(get_active_iface)

    # Si aucune interface active n'est trouvée, afficher un message d'erreur
    if [ -z "$iface" ]; then
        echo '{"text": "No active interface"}'
        exit 1
    fi

    # Récupérer les statistiques de trafic initiales
    declare -a traffic_prev traffic_curr traffic_delta
    traffic_prev=( 0 0 0 0 )

    # Intervalle de mise à jour du trafic, par défaut 5 secondes
    local isecs=5

    # Boucle infinie pour collecter les données de trafic
    while true; do
        # Récupérer les données actuelles de trafic
        traffic_curr=( $(get_traffic "$iface") )

        # Calculer la différence entre les valeurs actuelles et précédentes
        for i in {0..1}; do
            (( traffic_delta[i] = ( traffic_curr[i] - traffic_prev[i] ) / isecs ))
        done

        # Mettre à jour les valeurs précédentes pour la prochaine itération
        traffic_prev=(${traffic_curr[@]})

        # Convertir les valeurs en format lisible
        rx_bps=$(human_readable ${traffic_delta[0]})  # Réception (RX)
        tx_bps=$(human_readable ${traffic_delta[1]})  # Envoi (TX)

        # Afficher les résultats sous forme de JSON pour Waybar
        echo "{\"text\": \"$rx_bps ⇣ | $tx_bps ⇡\"}"

        # Attendre avant la prochaine mise à jour
        sleep "$isecs"
    done
}

# Exécution de la fonction parse_traffic
parse_traffic

