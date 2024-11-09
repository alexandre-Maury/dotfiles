#!/bin/sh

# Obtenir le pourcentage de luminosité
brightness=$(brightnessctl get)
max_brightness=$(brightnessctl max)
percent=$(( brightness * 100 / max_brightness ))

# Définir l'icône en fonction du niveau de luminosité
if [ "$percent" -ge 75 ]; then
  icon=""  # Icône pour luminosité élevée
elif [ "$percent" -ge 50 ]; then
  icon=""  # Icône pour luminosité moyenne
elif [ "$percent" -ge 25 ]; then
  icon=""  # Icône pour luminosité basse
else
  icon=""  # Icône pour luminosité très basse
fi

# Afficher l'icône et le pourcentage de luminosité
echo "$icon $percent%"
