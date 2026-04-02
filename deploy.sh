#!/bin/bash
# =============================================================
# deploy.sh — Reusable deployment script with rollback support
# Usage: ./deploy.sh <app_name> <version> <environment>
# Example: ./deploy.sh myapp v2.1 production
# =============================================================

# ── Configuration ─────────────────────────────────────────────
APP_NAME=$1
VERSION=$2
ENVIRONMENT=$3
DEPLOY_DIR="/tmp/deployments"
BACKUP_DIR="/tmp/backups"
LOG_FILE="/tmp/deploy.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')


# ── Logging function ───────────────────────────────────────────
log() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# ── Validate arguments ─────────────────────────────────────────
validate_arguments() {
    if [ $# -lt 3 ]; then
        log "ERROR" "Missing arguments"
        log "ERROR" "Usage: ./deploy.sh <app_name> <version> <environment>"
        exit 1
    fi

    if [ "$ENVIRONMENT" != "staging" ] && [ "$ENVIRONMENT" != "production" ]; then
        log "ERROR" "Environment must be 'staging' or 'production'"
        exit 1
    fi
}




# ── Setup directories ──────────────────────────────────────────
setup() {
    log "INFO" "Setting up deployment directories"
    
    mkdir -p "$DEPLOY_DIR"
    mkdir -p "$BACKUP_DIR"
    
    if [ $? -ne 0 ]; then
        log "ERROR" "Failed to create directories"
        exit 1
    fi
    
    log "INFO" "Directories ready"
}

# ── Backup current version ─────────────────────────────────────
backup() {
    log "INFO" "Backing up current version of $APP_NAME"
    
    if [ -d "$DEPLOY_DIR/$APP_NAME" ]; then
        cp -r "$DEPLOY_DIR/$APP_NAME" "$BACKUP_DIR/${APP_NAME}_backup_${TIMESTAMP}"
        
        if [ $? -ne 0 ]; then
            log "ERROR" "Backup failed — aborting deployment"
            exit 1
        fi
        
        log "INFO" "Backup saved to $BACKUP_DIR/${APP_NAME}_backup_${TIMESTAMP}"
    else
        log "INFO" "No existing version found — skipping backup"
    fi
}




# ── Deploy new version ─────────────────────────────────────────
deploy() {
    log "INFO" "Starting deployment of $APP_NAME version $VERSION to $ENVIRONMENT"
    
    # Create app directory
    mkdir -p "$DEPLOY_DIR/$APP_NAME"
    
    # Simulate deploying files (in real life this would be git pull, 
    # copying files, pulling a docker image etc)
    echo "$VERSION" > "$DEPLOY_DIR/$APP_NAME/version.txt"
    echo "$TIMESTAMP" > "$DEPLOY_DIR/$APP_NAME/deployed_at.txt"
    echo "$ENVIRONMENT" > "$DEPLOY_DIR/$APP_NAME/environment.txt"
    
    if [ $? -ne 0 ]; then
        log "ERROR" "Deployment failed"
        return 1
    fi
    
    log "INFO" "Files deployed successfully"
    return 0
}

# ── Verify deployment ──────────────────────────────────────────
verify() {
    log "INFO" "Verifying deployment..."
    
    # Check all expected files exist
    if [ ! -f "$DEPLOY_DIR/$APP_NAME/version.txt" ]; then
        log "ERROR" "Verification failed — version.txt missing"
        return 1
    fi
    
    # Check deployed version matches what we intended
    DEPLOYED_VERSION=$(cat "$DEPLOY_DIR/$APP_NAME/version.txt")
    if [ "$DEPLOYED_VERSION" != "$VERSION" ]; then
        log "ERROR" "Version mismatch — expected $VERSION but found $DEPLOYED_VERSION"
        return 1
    fi
    
    log "INFO" "Verification passed — $APP_NAME $VERSION is live"
    return 0
}




# ── Rollback to previous version ──────────────────────────────
rollback() {
    log "WARN" "Initiating rollback for $APP_NAME"
    
    # Find the most recent backup
    LATEST_BACKUP=$(ls -t "$BACKUP_DIR" | grep "${APP_NAME}_backup" | head -1)
    
    if [ -z "$LATEST_BACKUP" ]; then
        log "ERROR" "No backup found — cannot rollback"
        exit 1
    fi
    
    log "INFO" "Rolling back to $LATEST_BACKUP"
    
    # Remove failed deployment
    rm -rf "$DEPLOY_DIR/$APP_NAME"
    
    # Restore backup
    cp -r "$BACKUP_DIR/$LATEST_BACKUP" "$DEPLOY_DIR/$APP_NAME"
    
    if [ $? -ne 0 ]; then
        log "ERROR" "Rollback failed — manual intervention required"
        exit 1
    fi
    
    log "INFO" "Rollback completed successfully"
}

# ── Main ───────────────────────────────────────────────────────
main() {
    log "INFO" "========================================"
    log "INFO" "Deployment started"
    log "INFO" "App: $APP_NAME | Version: $VERSION | Env: $ENVIRONMENT"
    log "INFO" "========================================"
    
    # Run each step in order
    validate_arguments "$@"
    setup
    backup
    
    # Deploy and check if it worked
    if deploy; then
        if verify; then
            log "INFO" "========================================"
            log "INFO" "Deployment successful!"
            log "INFO" "========================================"
            exit 0
        else
            log "ERROR" "Verification failed — rolling back"
            rollback
            exit 1
        fi
    else
        log "ERROR" "Deployment failed — rolling back"
        rollback
        exit 1
    fi
}

# ── Run ────────────────────────────────────────────────────────
main "$@"
