# JesterOS Integration Test Environment - DEPRECATED
# 
# This file has been replaced by the modular approach:
#   1. Base Image: build/docker/jesteros-base.dockerfile
#   2. Test Scripts: tests/*.sh  
#   3. Test Runner: tests/test-runner.sh
#
# Usage:
#   ./tests/test-runner.sh                    # Build and test
#   ./tests/test-runner.sh jesteros-base      # Test existing image
#
# "By quill and candlelight, we modernize the realm!"

FROM jesteros-base

# This image now simply extends the base for compatibility
# All tests are external scripts mounted at runtime

# Show deprecation notice
RUN echo '#!/bin/bash' > /deprecated-notice.sh && \
    echo 'echo "════════════════════════════════════════════════════════════════"' >> /deprecated-notice.sh && \
    echo 'echo "This image is DEPRECATED. Use the modular test approach:"' >> /deprecated-notice.sh && \
    echo 'echo "  ./tests/test-runner.sh"' >> /deprecated-notice.sh && \
    echo 'echo "════════════════════════════════════════════════════════════════"' >> /deprecated-notice.sh && \
    echo 'echo ""' >> /deprecated-notice.sh && \
    echo '/usr/local/bin/jesteros-status.sh' >> /deprecated-notice.sh && \
    chmod +x /deprecated-notice.sh

CMD ["/deprecated-notice.sh"]