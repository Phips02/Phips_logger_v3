#!/bin/bash

#########################################################
# INSTALLATION DU PHIPS LOGGER
#########################################################

set -e

# Configuration
INSTALL_DIR="/usr/local/bin"
LOG_DIR="/var/log/phips_logger"
TELEGRAM_DIR="/etc/telegram"
TELEGRAM_CREDENTIALS="$TELEGRAM_DIR/credentials.cfg"
SCRIPT_NAME="logger.sh"
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Installation du Phips Logger..."

# Vérifier les permissions
if [[ $EUID -ne 0 ]]; then
    echo "❌ Ce script doit être exécuté en tant que root (sudo)"
    exit 1
fi

# Créer le répertoire de logs
echo "📁 Création du répertoire de logs: $LOG_DIR"
mkdir -p "$LOG_DIR"
chmod 775 "$LOG_DIR"

# Copier le script principal
echo "📋 Installation du script: $INSTALL_DIR/$SCRIPT_NAME"
cp "$CURRENT_DIR/$SCRIPT_NAME" "$INSTALL_DIR/$SCRIPT_NAME"
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# Créer un lien symbolique pour faciliter l'accès
echo "🔗 Création du lien symbolique: /usr/local/bin/phips_logger"
ln -sf "$INSTALL_DIR/$SCRIPT_NAME" "/usr/local/bin/phips_logger"

# Configuration des credentials Telegram
setup_telegram_credentials() {
    echo ""
    echo "📱 Configuration des notifications Telegram"
    echo "   (Appuyez sur Entrée pour ignorer si vous ne voulez pas de notifications)"
    echo ""
    
    read -p "🤖 Token du bot Telegram (optionnel): " bot_token
    
    if [[ -n "$bot_token" ]]; then
        read -p "💬 Chat ID Telegram: " chat_id
        
        if [[ -n "$chat_id" ]]; then
            echo "📁 Création du répertoire: $TELEGRAM_DIR"
            mkdir -p "$TELEGRAM_DIR"
            chmod 755 "$TELEGRAM_DIR"
            
            echo "📝 Création du fichier de credentials: $TELEGRAM_CREDENTIALS"
            cat > "$TELEGRAM_CREDENTIALS" << EOF
# Configuration Telegram pour Phips Logger
# Généré automatiquement le $(date)

# Token du bot Telegram
TELEGRAM_BOT_TOKEN="$bot_token"

# ID du chat/groupe où envoyer les notifications
TELEGRAM_CHAT_ID="$chat_id"
EOF
            chmod 600 "$TELEGRAM_CREDENTIALS"
            echo "✅ Credentials Telegram configurés dans $TELEGRAM_CREDENTIALS"
        else
            echo "⚠️  Chat ID manquant - configuration Telegram ignorée"
        fi
    else
        echo "ℹ️  Configuration Telegram ignorée"
    fi
}

# Vérifier si le fichier de credentials existe déjà
if [[ -f "$TELEGRAM_CREDENTIALS" ]]; then
    echo "📱 Fichier de credentials Telegram existant trouvé: $TELEGRAM_CREDENTIALS"
    echo "ℹ️  Configuration Telegram conservée"
else
    setup_telegram_credentials
fi

# Créer un script d'exemple dans /usr/local/share/doc
DOC_DIR="/usr/local/share/doc/phips_logger"
mkdir -p "$DOC_DIR"
cp "$CURRENT_DIR/example_usage.sh" "$DOC_DIR/" 2>/dev/null || true

echo ""
echo "✅ Installation terminée avec succès !"
echo ""
echo "📖 UTILISATION:"
echo "   Dans vos scripts, ajoutez:"
echo "   source /usr/local/bin/phips_logger"
echo "   log_info \"Votre message\""
echo ""
echo "🔧 CONFIGURATION:"
echo "   Définissez ces variables avant le 'source' si nécessaire:"
echo "   export LOG_LEVEL=\"INFO\""
echo "   export LOG_PREFIX=\"mon_script\""
echo "   export ENABLE_TELEGRAM=\"true\""
echo ""
echo "📱 TELEGRAM:"
if [[ -f "$TELEGRAM_CREDENTIALS" ]]; then
    echo "   ✅ Credentials configurés: $TELEGRAM_CREDENTIALS"
    echo "   Pour modifier: sudo nano $TELEGRAM_CREDENTIALS"
else
    echo "   ⚠️  Pas de credentials - notifications désactivées"
    echo "   Pour configurer: relancez sudo ./install.sh"
fi
echo ""
echo "📂 LOGS: $LOG_DIR"
echo "📄 EXEMPLE: $DOC_DIR/example_usage.sh"
echo ""
echo "🆘 AIDE: /usr/local/bin/phips_logger"
