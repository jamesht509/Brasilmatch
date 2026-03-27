#!/bin/bash
# Auto-update script - monitora GitHub e faz git pull automático

echo "🔄 BrasilMatch Auto-Update Script"
echo "Monitorando repositório para atualizações..."
echo "Pressione Ctrl+C para parar"
echo ""

# Intervalo de checagem (em segundos)
INTERVAL=30

while true; do
  # Fetch latest changes
  git fetch origin main 2>/dev/null
  
  # Check if there are new commits
  LOCAL=$(git rev-parse HEAD)
  REMOTE=$(git rev-parse origin/main)
  
  if [ "$LOCAL" != "$REMOTE" ]; then
    echo "✨ Novo update detectado! ($(date '+%H:%M:%S'))"
    
    # Pull changes
    git pull origin main
    
    if [ $? -eq 0 ]; then
      echo "✅ Update aplicado com sucesso!"
      
      # Install dependencies if needed
      cd flutter_app
      flutter pub get
      cd ..
      
      echo "📱 Hot reload acontecerá automaticamente no device"
      echo ""
    else
      echo "❌ Erro ao fazer pull. Resolve conflitos manualmente."
      echo ""
    fi
  fi
  
  # Wait before next check
  sleep $INTERVAL
done
