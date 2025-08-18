# Vanilla Debian Lenny 5.0 Docker Image
# Built from authentic February 2009 packages via archive.debian.org
#
# This image provides a clean, unmodified Debian Lenny 5.0 environment
# perfect for retro computing, legacy testing, and historical research.
#
# Build: docker build -f vanilla-debian-lenny.dockerfile -t debian:lenny .
#
# Maintainers: Percy Raskova
# Source: https://github.com/bogdanscarwash/nook-typewriter (JesterOS Project)
# License: Open source - help preserve computing history!

FROM scratch

# Extract authentic Debian Lenny 5.0 (built from archive.debian.org packages)
ADD lenny-rootfs.tar.gz /

# Set period-correct environment variables (February 2009)
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=linux
ENV SHELL=/bin/bash
ENV EDITOR=vi
ENV PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin
ENV HOME=/root

# Working directory
WORKDIR /root

# Configure authentic Lenny package sources
RUN echo "# Debian Lenny 5.0 - Archived (February 2009)" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian/ lenny main" >> /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security/ lenny/updates main" >> /etc/apt/sources.list

# Create essential directories that may be missing
RUN mkdir -p /proc /sys /dev /tmp /var/tmp && \
    chmod 1777 /tmp /var/tmp

# Set up basic hostname and networking (skip if read-only)
RUN echo "debian-lenny" > /etc/hostname 2>/dev/null || true && \
    echo "127.0.0.1 localhost debian-lenny" > /etc/hosts 2>/dev/null || true

# Metadata for community use
LABEL maintainer="Persephone Raskova" \
      source="https://github.com/bogdanscarwash/nook-typewriter" \
      project="JesterOS - Turning e-readers into distraction-free typewriters" \
      description="Vanilla Debian Lenny 5.0 built from authentic archive.debian.org packages" \
      version="5.0.10" \
      release-date="2009-02-14" \
      build-date="2024-08-17" \
      source="http://archive.debian.org/debian/" \
      purpose="Historical computing, retro projects, legacy software testing" \
      arch="armel" \
      authentic="true" \
      community="retro-computing"

# Default command is bash
CMD ["/bin/bash"]
