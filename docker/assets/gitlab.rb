# Docker options for ARM Image

# Set the internal API URL
# fixes https://gitlab.com/gitlab-org/gitlab-ce/issues/29870
gitlab_rails['internal_api_url'] = 'http://localhost:8080/'

## Prevent Postgres from trying to allocate 25% of total memory
postgresql['shared_buffers'] = '1MB'
postgresql['autovacuum_max_workers'] = "2"

# Disable Prometheus node_exporter inside Docker.
node_exporter['enable'] = false

## To completely disable prometheus, and all of it's exporters, set to false
prometheus_monitoring['enable'] = false

## Set Unicorn timeout and lower processes (2 is the lowest allowed at this moment)
puma['max_threads'] = 2
puma['min_threads'] = 1
puma['worker_processes'] = 2
puma['worker_timeout'] = 60

## Set Sidekiq timeout and lower its concurrency to the lowest allowed
sidekiq['shutdown_timeout'] = 4
sidekiq['concurrency'] = 5

# Manage accounts with docker
# manage_accounts['enable'] = false

# Nginx settings
nginx['worker_processes'] = 2
nginx['worker_connections'] = 2048

# Get hostname from shell
host = `hostname`.strip
external_url "http://#{host}"

# Explicitly disable init detection since we are running on a container
package['detect_init'] = false

# Load custom config from environment variable: GITLAB_OMNIBUS_CONFIG
# Disabling the cop since rubocop considers using eval to be security risk but
# we don't have an easy way out, atleast yet.
eval ENV["GITLAB_OMNIBUS_CONFIG"].to_s # rubocop:disable Security/Eval

# Load configuration stored in /etc/gitlab/gitlab.rb
from_file("/etc/gitlab/gitlab.rb")
