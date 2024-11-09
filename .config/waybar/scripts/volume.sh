#!/bin/sh

# Obtenir le statut du volume
volume=$(pamixer --get-volume)
muted=$(pamixer --get-mute)

# Définir l'icône en fonction du niveau de volume et de l'état de sourdine
if [ "$muted" = "true" ]; then
  icon=""  # Icône de sourdine
else
  if [ "$volume" -ge 50 ]; then
    icon=""  # Icône pour volume élevé
  elif [ "$volume" -gt 0 ]; then
    icon=""  # Icône pour volume moyen
  else
    icon=""  # Icône pour volume bas
  fi
fi

# Afficher l'icône et le pourcentage de volume
echo "$icon $volume%"
