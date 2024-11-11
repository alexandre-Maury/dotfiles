#!/bin/sh

# Obtenir le pourcentage de luminosité
brightness=$(brightnessctl get 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "Erreur: Impossible de récupérer la luminosité actuelle."
    exit 1
fi

max_brightness=$(brightnessctl max 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "Erreur: Impossible de récupérer la luminosité maximale."
    exit 1
fi

percent=$(( brightness * 100 / max_brightness ))

# Définir l'icône en fonction du niveau de luminosité
if [ "$percent" -ge 75 ]; then
  icon="  "  # Icône pour luminosité élevée
elif [ "$percent" -ge 50 ]; then
  icon="  "  # Icône pour luminosité moyenne
elif [ "$percent" -ge 25 ]; then
  icon="  "  # Icône pour luminosité basse
else
  icon="  "  # Icône pour luminosité très basse
fi

# Afficher l'icône et le pourcentage de luminosité
echo "$icon $percent%"

