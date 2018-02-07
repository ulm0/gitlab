# Docker options for ARM Image

## Prevent Postgres from trying to allocate 25% of total memory
postgresql['shared_buffers'] = '1MB'
postgresql['autovacuum_max_workers'] = "2"

## To completely disable prometheus, and all of it's exporters, set to false
prometheus_monitoring['enable'] = false

## Set Unicorn timeout and lower processes (2 is the lowest allowed at this moment)
unicorn['worker_timeout'] = 60
unicorn['worker_processes'] = 2

## Set Sidekiq timeout and lower its concurrency to the lowest allowed
sidekiq['shutdown_timeout'] = 4
sidekiq['concurrency'] = 4

# Manage accounts with docker
manage_accounts['enable'] = false

# Nginx settings
nginx['worker_processes'] = 2
nginx['worker_connections'] = 2048

# Get hostname from shell
host = `hostname`.strip
external_url "http://#{host}"

# Load custom config from environment variable: GITLAB_OMNIBUS_CONFIG
eval ENV["GITLAB_OMNIBUS_CONFIG"].to_s

# Load configuration stored in /etc/gitlab/gitlab.rb
from_file("/etc/gitlab/gitlab.rb")
