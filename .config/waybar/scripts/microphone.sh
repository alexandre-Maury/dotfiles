#!/bin/bash
set -e

# Vérifier si wpctl est installé
if ! command -v wpctl &>/dev/null; then
    echo "wpctl est nécessaire pour ce script, mais il n'est pas installé."
    exit 1
fi

# Icônes pour le microphone
ICON_MICROPHONE=(
    "   "  # Microphone Mute
    "  "   # Microphone Actif
)

# Fichier pour contrôler le mute du microphone
MUTE_MIC_FILE="/tmp/waybar_toggle_mute_microphone"

# Délai en secondes entre les mises à jour
DELAY=1

# Fonction pour couper le son du micro (mute/unmute)
toggle_mute_microphone() {
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
}

# Fonction pour obtenir et afficher le volume du micro
get_microphone_volume() {
    INPUT=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)
    OUT=""
    
    while read LINE ; do
        if [[ "$LINE" =~ ^Volume:.([0-9]+)\.([0-9]{2})(([[:blank:]]\[MUTED\])?)$ ]] ; then
            volume=$((10#${BASH_REMATCH[1]}${BASH_REMATCH[2]}))
            if [[ -n "${BASH_REMATCH[3]}" ]]; then
                OUT+="${ICON_MICROPHONE[0]} MUTE"
            else
                OUT+="${ICON_MICROPHONE[1]} $volume%"
            fi
        else
            echo "Erreur dans la sortie de wpctl: '$LINE'"
        fi
    done <<< "$INPUT"
    
    echo "$OUT"
}

# Boucle principale avec délai
while : ; do
    # Si le fichier de contrôle existe pour basculer le mute du microphone
    if [[ -f "$MUTE_MIC_FILE" ]]; then
        toggle_mute_microphone
        rm -f "$MUTE_MIC_FILE"  # Supprimer le fichier après basculement
    fi

    # Afficher le volume du microphone
    get_microphone_volume
    sleep $DELAY
done

