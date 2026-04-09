# DevOps Projects

A collection of DevOps automation scripts built while learning Linux, 
Bash scripting, and system administration.

## Scripts

### deploy.sh
A reusable deployment script with automatic rollback support.

**Features:**
- Accepts app name, version and environment as arguments
- Backs up current version before deploying
- Verifies deployment was successful
- Automatically rolls back if verification fails
- Logs everything with timestamps

**Usage:**
```bash
./deploy.sh <app_name> <version> <environment>
./deploy.sh myapp v1.0 staging
```

## Author
Shola — self taught DevOps engineer with 3 AWS certifications.
