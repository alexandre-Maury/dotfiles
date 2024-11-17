#!/bin/bash

# Fonction pour obtenir l'utilisation de la mémoire
get_memory_usage() {
    free_mem=$(free -h | awk '/^Mem/ {print $3 " / " $2 " GiB"}')
    echo "󰍛 $free_mem"
}

# Fonction pour obtenir l'utilisation du CPU
get_cpu_usage() {
    # Utilisation du CPU
    # Récupérer les valeurs au départ
    cpu_0=$(cat /proc/stat | grep '^cpu ')

    # Attendre 1 seconde (ou plus)
    sleep 1

    # Récupérer les valeurs après 1 seconde
    cpu_1=$(cat /proc/stat | grep '^cpu ')

    # Extraire les valeurs de "user", "system" et "idle"
    user_0=$(echo "$cpu_0" | awk '{print $2}')
    system_0=$(echo "$cpu_0" | awk '{print $4}')
    idle_0=$(echo "$cpu_0" | awk '{print $5}')

    user_1=$(echo "$cpu_1" | awk '{print $2}')
    system_1=$(echo "$cpu_1" | awk '{print $4}')
    idle_1=$(echo "$cpu_1" | awk '{print $5}')

    # Calculer la différence entre les valeurs de départ et d'arrivée
    user_diff=$((user_1 - user_0))
    system_diff=$((system_1 - system_0))
    idle_diff=$((idle_1 - idle_0))

    # Calculer l'activité en pourcentage
    total_diff=$((user_diff + system_diff + idle_diff))
    cpu_activity=$((100 * (user_diff + system_diff) / total_diff))
    echo "󰻠 $cpu_activity %"
}

# Fonction pour obtenir l'usage du disque
get_disk_usage() {
    # Usage du disque pour /mnt/sda (remplace avec le bon chemin si nécessaire)
    disk_size=$(df -h / | awk 'NR==2 {print $2}')
    disk_used=$(df -h / | awk 'NR==2 {print $3}')

    echo "󰋊 $disk_used | $disk_size"
}



# Selon l'argument passé, on exécute la fonction correspondante
case $1 in
    "memory")
        get_memory_usage
        ;;
    "cpu")
        get_cpu_usage
        ;;
    "disk")
        get_disk_usage
        ;;
    *)
        echo "Module non supporté"
        exit 1
        ;;
esac

