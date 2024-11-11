#!/bin/bash
set -e

# Vérifier si wpctl est installé
if ! command -v wpctl &>/dev/null; then
    echo "wpctl est nécessaire pour ce script, mais il n'est pas installé."
    exit 1
fi

# Icônes pour le volume (haut-parleurs)
ICON_VOLUME_SPEAKER=(
    "   "  # Mute
    "   "  # Volume faible
    "   "  # Volume fort
)

# Fichiers pour contrôler le mute du volume
MUTE_VOLUME_FILE="/tmp/waybar_toggle_mute_volume"
VOLUME_UP_FILE="/tmp/waybar_volume_up"
VOLUME_DOWN_FILE="/tmp/waybar_volume_down"

# Délai en secondes entre les mises à jour
DELAY=1

# Fonction pour couper le son du volume des haut-parleurs (mute/unmute)
toggle_mute_volume() {
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
}

# Fonction pour augmenter le volume
increase_volume() {
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
}

# Fonction pour diminuer le volume
decrease_volume() {
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
}

# Fonction pour obtenir et afficher le volume du système (haut-parleur uniquement)
get_volume() {
    # Récupérer le volume actuel du périphérique audio
    INPUT=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)

    while read -r LINE; do
        # Extraire les informations de volume
        if [[ "$LINE" =~ ^Volume:.([0-9]+)\.([0-9]{2})(([[:blank:]]\[MUTED\])?)$ ]]; then
            volume=$((10#${BASH_REMATCH[1]}${BASH_REMATCH[2]}))
            # Vérifier si le son est coupé (muté)
            if [[ -n "${BASH_REMATCH[3]}" ]]; then
                echo "${ICON_VOLUME_SPEAKER[0]} Mute"  # Icône de mute
            else
                echo "${ICON_VOLUME_SPEAKER[2]} $volume%"  # Icône et volume
            fi
        fi
    done <<< "$INPUT"
}

# Vérification des fichiers d'action pour la roulette de la souris
if [[ -f "$VOLUME_UP_FILE" ]]; then
    increase_volume
    rm -f "$VOLUME_UP_FILE"  # Supprimer après l'augmentation du volume
fi

if [[ -f "$VOLUME_DOWN_FILE" ]]; then
    decrease_volume
    rm -f "$VOLUME_DOWN_FILE"  # Supprimer après la diminution du volume
fi

# Si le fichier de contrôle existe pour basculer le mute du volume
if [[ -f "$MUTE_VOLUME_FILE" ]]; then
    toggle_mute_volume
    rm -f "$MUTE_VOLUME_FILE"  # Supprimer le fichier après basculement
fi

# Afficher l'icône de volume et attendre les prochaines actions
get_volume

