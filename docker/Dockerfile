FROM ubuntu:16.04
LABEL maintainer "Pierre Ugaz <ulm0@innersea.xyz>"
SHELL ["/bin/sh", "-c"],
ENV LANG=C.UTF-8
# Install required packages
RUN set -eux; \
    apt-get update -qq \
    && apt-get upgrade -yqq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yqq --no-install-recommends \
      apt-transport-https \
      ca-certificates \
      less \
      nano \
      openssh-server \
      tzdata \
      vim \
      wget \
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
# Resolve error: TERM environment variable not set.
ENV TERM xterm
# Expose web & ssh
EXPOSE 443 80 22
# Define data volumes
VOLUME ["/etc/gitlab", "/var/opt/gitlab", "/var/log/gitlab"]
# Wrapper to handle signal, trigger runit and reconfigure GitLab
CMD ["/assets/wrapper"]
HEALTHCHECK --interval=60s --timeout=30s --retries=5 \
CMD /opt/gitlab/bin/gitlab-healthcheck --fail --max-time 10
