#!/bin/bash
echo "Iniciando sincronización de CSS..."
while true; do
  if [ css/output.css -nt user/themes/portfolio-luis/css/output.css ]; then
    cp css/output.css user/themes/portfolio-luis/css/output.css
    echo "CSS actualizado: $(date)"
  fi
  sleep 2
done
