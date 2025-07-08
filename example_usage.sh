#!/bin/bash

#########################################################
# EXEMPLE D'UTILISATION DU SIMPLE LOGGER
#########################################################

# Configuration optionnelle (avant le source)
export LOG_LEVEL="DEBUG"
export LOG_PREFIX="example_app"
export ENABLE_TELEGRAM="false"  # Changez en "true" pour activer Telegram
# Note: Les credentials Telegram sont automatiquement chargés depuis /etc/telegram/credentials.cfg

# Importer le logger
source "$(dirname "$0")/logger.sh"

# Exemples d'utilisation
log_info "=== Démarrage de l'application exemple ==="

# Simulation d'une application
log_debug "Initialisation des variables"
APP_NAME="MonApp"
VERSION="1.0.0"

log_info "Application: $APP_NAME v$VERSION"

# Simulation de différents événements
log_debug "Chargement de la configuration"
sleep 1

log_info "Configuration chargée avec succès"
sleep 1

log_warning "Quota disque à 80% - surveillance recommandée"
sleep 1

# Simulation d'une erreur récupérable
log_error "Échec de connexion à la base de données - tentative de reconnexion"
sleep 1

log_info "Reconnexion réussie"
sleep 1

# Simulation d'une erreur critique
log_critical "Erreur critique détectée - arrêt de l'application"

log_info "=== Fin de l'exemple ==="

# Afficher le fichier de log créé
echo ""
echo "📁 Fichier de log créé: ${LOG_DIR}/${LOG_PREFIX}_$(date +%Y-%m-%d).log"
echo "📖 Pour voir les logs: cat ${LOG_DIR}/${LOG_PREFIX}_$(date +%Y-%m-%d).log"
