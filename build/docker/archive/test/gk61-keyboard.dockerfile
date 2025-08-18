FROM debian:bullseye-slim

# Install basic tools needed for testing
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    coreutils \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Create JesterOS directory structure
RUN mkdir -p /runtime/1-ui/setup \
    && mkdir -p /runtime/3-system/services \
    && mkdir -p /runtime/4-hardware/input \
    && mkdir -p /var/jesteros/keyboard \
    && mkdir -p /var/jesteros/usb \
    && mkdir -p /var/jesteros/buttons \
    && mkdir -p /var/log \
    && mkdir -p /usr/local/bin

# Copy our GK61 implementation files
COPY runtime/3-system/services/usb-keyboard-manager.sh /runtime/3-system/services/
COPY runtime/4-hardware/input/button-handler.sh /runtime/4-hardware/input/
COPY runtime/1-ui/setup/usb-keyboard-setup.sh /runtime/1-ui/setup/

# Make scripts executable
RUN chmod +x /runtime/3-system/services/usb-keyboard-manager.sh \
    && chmod +x /runtime/4-hardware/input/button-handler.sh \
    && chmod +x /runtime/1-ui/setup/usb-keyboard-setup.sh

# Create mock system files that scripts expect
RUN echo "#!/bin/bash\necho 'evtest not available in test environment'" > /usr/bin/evtest \
    && chmod +x /usr/bin/evtest

# Set working directory
WORKDIR /

# Default command
CMD ["/bin/bash"]