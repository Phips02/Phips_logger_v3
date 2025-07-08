# Phips Logger

Un système de logging **simplifié** et **robuste** pour vos scripts Bash.

## 🎯 Avantages de cette version simplifiée

- **Un seul fichier** - Plus de fichier de configuration séparé
- **Installation en une commande** - `sudo ./install.sh`
- **API ultra-simple** - `log_info "message"` et c'est tout !
- **Configuration intégrée** - Variables d'environnement optionnelles
- **Robuste** - Fonctionne même sans configuration
- **Léger** - Moins de 200 lignes de code

## 🚀 Installation rapide

```bash
# Cloner ou télécharger le script
curl -O https://raw.githubusercontent.com/Phips02/Bash/main/Phips_logger_V2/logger.sh

# Installation système (optionnel)
sudo ./install.sh
```

## 📖 Utilisation de base

### Méthode 1: Source direct
```bash
#!/bin/bash
source /path/to/logger.sh

log_info "Démarrage du script"
log_error "Une erreur s'est produite"
log_critical "Erreur critique !"
```

### Méthode 2: Après installation système
```bash
#!/bin/bash
source /usr/local/bin/phips_logger

log_info "Script démarré"
```

## 🔧 Configuration (optionnelle)

Définissez ces variables **avant** le `source` :

```bash
#!/bin/bash

# Configuration personnalisée
export LOG_LEVEL="DEBUG"           # Niveau minimum (DEBUG, INFO, WARNING, ERROR, CRITICAL)
export LOG_PREFIX="mon_app"        # Préfixe des fichiers de log
export LOG_DIR="/tmp/logs"         # Répertoire des logs
export ENABLE_TELEGRAM="true"      # Notifications Telegram
# Note: TELEGRAM_BOT_TOKEN et TELEGRAM_CHAT_ID sont chargés depuis /etc/telegram/credentials.cfg

# Importer le logger
source logger.sh

# Utilisation
log_info "Configuration personnalisée active"
```

## 📝 Fonctions disponibles

### Fonction principale
```bash
log "LEVEL" "message"
```

### Fonctions de convenance
```bash
log_debug "Message de debug"
log_info "Information"
log_warning "Attention"
log_error "Erreur"
log_critical "Critique"
```

## 🎨 Fonctionnalités

- ✅ **Logs colorés** dans la console
- ✅ **Fichiers de log** avec rotation quotidienne
- ✅ **Notifications Telegram** pour WARNING/ERROR/CRITICAL
- ✅ **Détection automatique** du script appelant
- ✅ **Gestion des erreurs** robuste
- ✅ **Configuration flexible** via variables d'environnement

## 📁 Structure des logs

```
/var/log/phips_logger/
├── mon_script_2025-07-08.log
├── autre_script_2025-07-08.log
└── ...
```

Format des logs :
```
[2025-07-08 10:45:32] [hostname] [INFO] [script.sh] Message de log
```

## 🔔 Notifications Telegram

### Configuration automatique (recommandée)

Lors de l'installation avec `sudo ./install.sh`, le script vous demandera vos credentials Telegram et les stockera de manière sécurisée dans `/etc/telegram/credentials.cfg`.

### Configuration manuelle

1. Créez un bot Telegram avec @BotFather
2. Obtenez le token du bot
3. Obtenez votre chat ID
4. Créez le fichier `/etc/telegram/credentials.cfg` :

```bash
sudo mkdir -p /etc/telegram
sudo nano /etc/telegram/credentials.cfg
```

Contenu du fichier :
```bash
# Configuration Telegram pour Phips Logger
TELEGRAM_BOT_TOKEN="123456789:ABCdefGHIjklMNOpqrsTUVwxyz"
TELEGRAM_CHAT_ID="123456789"
```

5. Sécurisez le fichier :
```bash
sudo chmod 600 /etc/telegram/credentials.cfg
```

6. Activez les notifications dans vos scripts :
```bash
export ENABLE_TELEGRAM="true"
```

## 🆚 Comparaison avec l'ancienne version

| Fonctionnalité | Ancienne version | Version simplifiée |
|---|---|---|
| Fichiers | 4 fichiers | 1 fichier |
| Configuration | Fichier .cfg | Variables d'environnement |
| Installation | Script complexe | 1 commande |
| Utilisation | `print_log "LEVEL" "MODULE" "message"` | `log_info "message"` |
| Maintenance | Complexe | Simple |

## 🔧 Migration depuis l'ancienne version

Remplacez :
```bash
# Ancien
print_log "INFO" "$LOG_FILENAME" "message"
```

Par :
```bash
# Nouveau
log_info "message"
```

## 🆘 Aide

Exécutez le script directement pour voir l'aide :
```bash
./logger.sh
# ou après installation
/usr/local/bin/phips_logger
```

## 📄 Exemple complet

Voir `example_usage.sh` pour un exemple détaillé d'utilisation.
