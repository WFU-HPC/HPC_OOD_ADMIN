# OpenOnDemand Admin User Impersonation Dashboard
## Author

Brandon Biggs - Idaho National Laboratory

An administrative tool for OpenOnDemand (OOD) that enables authorized administrators to impersonate other users on HPC clusters. Developed at Idaho National Laboratory.

## Overview

This project provides a web-based admin page accessible directly from the OOD interface that allows HPC cluster administrators to:

- Impersonate any user account in the OpenOnDemand environment
- Record audit logs of all impersonation attempts with required justification
- Dynamically update authentication mappings for the impersonated user

## Directory Structure

```
public_ondemand_admin/
├── bin/
│   └── ood_auth_map.regex              # Bash script for authentication mapping
├── user_impersonation_dashboard/
│   ├── env                             # Environment configuration
│   ├── initializers/
│   │   ├── admin.rb                    # Rails controller and model logic
│   │   └── routes.rb                   # Route configuration with access control
│   └── views/
│       └── index.html.erb              # Web UI template
├── LICENSE
├── NOTICE.txt
└── README.md
```

## Components

### Authentication Mapping Script (`bin/ood_auth_map.regex`)

A Bash script that handles the core authentication mapping mechanism:

- Decodes the current login username
- Checks if the user matches a configured service account pattern (e.g., `ood-service-hpcuser`)
- Retrieves and applies the impersonated username from environment variables
- Returns the appropriate username for the session

You will need to update this to work with your current authentication mapping.

### Admin Dashboard (`user_impersonation_dashboard/`)

A Ruby on Rails integration that adds admin routes to the OpenOnDemand dashboard:

- **Access Control**: Routes are only available to users in the `OOD_ADMIN_GROUP`
- **Form Interface**: Provides fields for target username and impersonation reason
- **Audit Logging**: Records all impersonation attempts with timestamps and justifications

## Installation

1. Copy the `user_impersonation_dashboard` directory contents to your OOD dashboard configuration:

   ```bash
   cp -r user_impersonation_dashboard/* /etc/ood/config/apps/dashboard/
   ```

2. Copy the authentication mapping script to the OOD auth map directory. PLEASE double check this as to not overwrite your potentially custom settings.

   ```bash
   cp bin/ood_auth_map.regex /opt/ood/ood_auth_map/bin/
   chmod +x /opt/ood/ood_auth_map/bin/ood_auth_map.regex
   ```

3. Create the log file with appropriate permissions. This may change depending on what you set in `ENV`.

   ```bash
   touch /var/log/ood-impersonation.log
   chown apache:apache /var/log/ood-impersonation.log
   chmod 664 /var/log/ood-impersonation.log
   ```

4. Ensure the `OOD_ADMIN_GROUP` environment variable is set in your OOD configuration to specify which group has admin access.

## Configuration

The `env` file contains the following environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `OOD_DASHBOARD_ADMIN_AUTH_MAP_FILE` | Path to the authentication mapping script | `/opt/ood/ood_auth_map/bin/ood_auth_map.regex` |
| `OOD_DASHBOARD_ADMIN_AUTH_LOG_FILE` | Path to the impersonation audit log | `/var/log/ood-impersonation.log` |

## Usage

1. Log into the OpenOnDemand dashboard as an admin user (member of `OOD_ADMIN_GROUP`)
2. Navigate to `/admin` in the dashboard
3. Enter the username to impersonate
4. Provide a reason for the impersonation (e.g., ticket number, debugging purpose)
5. Submit the form

The system will update the authentication mapping and log the action. The next session created through the configured service account will run as the impersonated user.

## Security

- **Access Control**: Admin routes are only loaded for users in the designated admin group
- **Audit Trail**: All impersonation attempts are logged with:
  - Timestamp
  - Admin user performing the action
  - Target user being impersonated
  - Stated reason/justification
- **Input Validation**: Both username and reason fields are required
