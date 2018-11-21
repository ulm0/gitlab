# FROM resin/armv7hf-debian:jessie
FROM registry.gitlab.com/ulm0/ubuntu:16.04-arm
LABEL maintainer "Mauricio Ugaz <ulm0@innersea.xyz>"

SHELL ["/bin/sh", "-c"],

# Install required packages
RUN apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yqq --no-install-recommends \
      ca-certificates \
      openssh-server \
      wget \
      apt-transport-https \
      vim \
      tzdata \
      nano \
    && rm -rf /var/lib/apt/lists/* \
    && sed 's/session\s*required\s*pam_loginuid.so/session optional pam_loginuid.so/g' -i /etc/pam.d/sshd \
    # Remove MOTD
    && rm -rf /etc/update-motd.d /etc/motd /etc/motd.dynamic \
    && ln -fs /dev/null /run/motd.dynamic

# Copy assets
COPY RELEASE /
COPY assets/ /assets/
RUN /assets/setup

# Allow to access embedded tools
ENV PATH /opt/gitlab/embedded/bin:/opt/gitlab/bin:/assets:$PATH

# # Patch mattermost
# RUN rm -f /opt/gitlab/embedded/bin/mattermost
# COPY mattermost /opt/gitlab/embedded/bin/mattermost

# Resolve error: TERM environment variable not set.
ENV TERM xterm

# Expose web & ssh
EXPOSE 443 80 22

# Define data volumes
VOLUME ["/etc/gitlab", "/var/opt/gitlab", "/var/log/gitlab"]

# Wrapper to handle signal, trigger runit and reconfigure GitLab
CMD ["/assets/wrapper"]

HEALTHCHECK --interval=60s --timeout=30s --retries=5 \
CMD /opt/gitlab/bin/gitlab-healthcheck --fail
