#!/bin/bash

#########################################################
# PHIPS LOGGER
# Version: 2025.07.08
# Usage: source logger.sh && log "LEVEL" "message"
#########################################################

# Configuration par défaut (peut être surchargée avant le source)
LOG_DIR="${LOG_DIR:-/var/log/phips_logger}"
LOG_LEVEL="${LOG_LEVEL:-INFO}"
LOG_PREFIX="${LOG_PREFIX:-$(basename "${0%.*}")}"
ENABLE_TELEGRAM="${ENABLE_TELEGRAM:-false}"
HOSTNAME="${HOSTNAME:-$(hostname)}"

# Charger les credentials Telegram depuis le fichier centralisé
TELEGRAM_CREDENTIALS_FILE="/etc/telegram/credentials.cfg"
TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-}"

if [[ -f "$TELEGRAM_CREDENTIALS_FILE" ]]; then
    source "$TELEGRAM_CREDENTIALS_FILE" 2>/dev/null || true
    # Utiliser les variables du fichier si elles ne sont pas déjà définies
    TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-$TELEGRAM_BOT_TOKEN}"
    TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-$TELEGRAM_CHAT_ID}"
fi

# Niveaux de log avec priorités
declare -A LOG_LEVELS=( 
    ["DEBUG"]=0
    ["INFO"]=1
    ["WARNING"]=2
    ["ERROR"]=3
    ["CRITICAL"]=4
)

# Couleurs pour l'affichage console
declare -A LOG_COLORS=(
    ["DEBUG"]="\033[0;36m"      # Cyan
    ["INFO"]="\033[0;32m"       # Vert
    ["WARNING"]="\033[0;33m"    # Jaune
    ["ERROR"]="\033[0;31m"      # Rouge
    ["CRITICAL"]="\033[1;31m"   # Rouge gras
    ["RESET"]="\033[0m"         # Reset
)

# Fonction principale de logging
log() {
    local level="${1:-INFO}"
    local message="${2:-}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local caller_script="${BASH_SOURCE[1]##*/}"
    
    # Validation du niveau
    if [[ ! "${LOG_LEVELS[$level]}" ]]; then
        echo "ERREUR: Niveau de log invalide: $level" >&2
        return 1
    fi
    
    # Vérifier si le niveau est suffisant
    if [[ "${LOG_LEVELS[$level]}" -lt "${LOG_LEVELS[$LOG_LEVEL]}" ]]; then
        return 0
    fi
    
    # Préparer le message formaté
    local log_entry="[$timestamp] [$HOSTNAME] [$level] [$caller_script] $message"
    
    # Affichage console avec couleurs
    echo -e "${LOG_COLORS[$level]}$log_entry${LOG_COLORS[RESET]}"
    
    # Écriture dans le fichier de log
    _write_to_file "$log_entry"
    
    # Notification Telegram si activée et niveau suffisant
    if [[ "$ENABLE_TELEGRAM" == "true" ]] && [[ "${LOG_LEVELS[$level]}" -ge "${LOG_LEVELS[WARNING]}" ]]; then
        _send_telegram_notification "$level" "$message" "$caller_script"
    fi
}

# Fonction pour écrire dans le fichier de log
_write_to_file() {
    local log_entry="$1"
    local log_file="${LOG_DIR}/${LOG_PREFIX}_$(date +%Y-%m-%d).log"
    
    # Créer le répertoire si nécessaire
    if [[ ! -d "$LOG_DIR" ]]; then
        mkdir -p "$LOG_DIR" 2>/dev/null || {
            echo "ATTENTION: Impossible de créer $LOG_DIR" >&2
            return 1
        }
    fi
    
    # Écrire dans le fichier
    echo "$log_entry" >> "$log_file" 2>/dev/null || {
        echo "ATTENTION: Impossible d'écrire dans $log_file" >&2
        return 1
    }
}

# Fonction pour envoyer une notification Telegram
_send_telegram_notification() {
    local level="$1"
    local message="$2"
    local script="$3"
    
    # Vérifier la configuration Telegram
    if [[ -z "$TELEGRAM_BOT_TOKEN" ]] || [[ -z "$TELEGRAM_CHAT_ID" ]]; then
        return 0
    fi
    
    # Préparer le message Telegram
    local telegram_message="🚨 *$level* sur $HOSTNAME%0A"
    telegram_message+="📄 Script: \`$script\`%0A"
    telegram_message+="💬 Message: $message%0A"
    telegram_message+="🕒 $(date '+%Y-%m-%d %H:%M:%S')"
    
    # Envoyer la notification (en arrière-plan pour ne pas bloquer)
    curl -s -X POST \
        "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
        -d "chat_id=$TELEGRAM_CHAT_ID" \
        -d "text=$telegram_message" \
        -d "parse_mode=Markdown" \
        >/dev/null 2>&1 &
}

# Fonctions de convenance pour chaque niveau
log_debug() { log "DEBUG" "$1"; }
log_info() { log "INFO" "$1"; }
log_warning() { log "WARNING" "$1"; }
log_error() { log "ERROR" "$1"; }
log_critical() { log "CRITICAL" "$1"; }

# Fonction d'aide
log_help() {
    cat << 'EOF'
PHIPS LOGGER - Guide d'utilisation

UTILISATION DE BASE:
    source logger.sh
    log "LEVEL" "message"

NIVEAUX DISPONIBLES:
    DEBUG, INFO, WARNING, ERROR, CRITICAL

FONCTIONS DE CONVENANCE:
    log_debug "message"
    log_info "message"
    log_warning "message"
    log_error "message"
    log_critical "message"

CONFIGURATION (variables d'environnement):
    LOG_DIR="/var/log/phips_logger"
    LOG_LEVEL="INFO"
    LOG_PREFIX="script_name"
    ENABLE_TELEGRAM="false"
    TELEGRAM_BOT_TOKEN="your_token"     # Ou dans /etc/telegram/credentials.cfg
    TELEGRAM_CHAT_ID="your_chat_id"     # Ou dans /etc/telegram/credentials.cfg

EXEMPLE:
    #!/bin/bash
    source /path/to/logger.sh
    
    log_info "Démarrage du script"
    log_error "Une erreur s'est produite"
EOF
}

# Message d'initialisation
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script exécuté directement
    log_help
else
    # Script sourcé
    log_debug "Logger initialisé pour ${BASH_SOURCE[1]##*/}"
fi
