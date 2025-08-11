# CI/CD Integration for QuillKernel

This guide explains how to integrate QuillKernel testing into continuous integration pipelines.

## Overview

QuillKernel's test suite is designed for CI/CD integration with:
- Exit codes for pass/fail detection
- Log files for artifact collection
- Graceful handling of missing hardware
- Parallel test execution support

## GitHub Actions Example

### Basic Workflow

`.github/workflows/quillkernel-test.yml`:

```yaml
name: QuillKernel Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build-verification:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Install dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y \
          gcc-arm-linux-gnueabi \
          sparse \
          bc
    
    - name: Apply patches
      run: |
        cd nst-kernel
        ./squire-kernel-patch.sh
    
    - name: Run build verification
      run: |
        cd nst-kernel/test
        ./verify-build-simple.sh
    
    - name: Upload logs
      if: always()
      uses: actions/upload-artifact@v3
      with:
        name: build-logs
        path: /tmp/quillkernel-*.log

  static-analysis:
    runs-on: ubuntu-latest
    needs: build-verification
    steps:
    - uses: actions/checkout@v3
    
    - name: Install analysis tools
      run: |
        sudo apt-get update
        sudo apt-get install -y sparse
        # Install smatch from source if needed
    
    - name: Run static analysis
      run: |
        cd nst-kernel/test
        ./static-analysis.sh
    
    - name: Upload results
      if: always()
      uses: actions/upload-artifact@v3
      with:
        name: static-analysis-results
        path: nst-kernel/test/static-analysis-results-*/

  software-tests:
    runs-on: ubuntu-latest
    needs: build-verification
    strategy:
      matrix:
        test: [test-proc, test-typewriter, low-memory-test]
    steps:
    - uses: actions/checkout@v3
    
    - name: Run ${{ matrix.test }}
      run: |
        cd nst-kernel/test
        ./${{ matrix.test }}.sh || echo "Test exited with code $?"
    
    - name: Check test results
      run: |
        # Parse logs for failures
        if grep -q "\[FAIL\]" /tmp/quillkernel-*.log; then
          echo "Test failures detected"
          exit 1
        fi
```

### Advanced Workflow with Docker

```yaml
name: QuillKernel Docker Tests

on: [push, pull_request]

jobs:
  docker-tests:
    runs-on: ubuntu-latest
    container:
      image: debian:11-slim
      options: --privileged
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup test environment
      run: |
        apt-get update
        apt-get install -y \
          build-essential \
          gcc-arm-linux-gnueabi \
          git \
          bc \
          python3
    
    - name: Run test suite
      run: |
        cd nst-kernel/test
        ./run-all-tests.sh
    
    - name: Generate test report
      if: always()
      run: |
        cd nst-kernel/test
        # Create summary report
        echo "# Test Results" > test-summary.md
        echo "## Summary" >> test-summary.md
        grep -h "Tests Passed\|Tests Failed" test-results-*/*.log >> test-summary.md
        
    - name: Upload test report
      if: always()
      uses: actions/upload-artifact@v3
      with:
        name: test-reports
        path: |
          nst-kernel/test/test-results-*/
          nst-kernel/test/test-summary.md
```

## GitLab CI Example

`.gitlab-ci.yml`:

```yaml
stages:
  - verify
  - analyze
  - test

variables:
  GIT_SUBMODULE_STRATEGY: recursive

verify:build:
  stage: verify
  image: debian:11-slim
  before_script:
    - apt-get update -qq
    - apt-get install -y gcc-arm-linux-gnueabi
  script:
    - cd nst-kernel
    - ./squire-kernel-patch.sh
    - cd test
    - ./verify-build-simple.sh
  artifacts:
    when: always
    paths:
      - /tmp/quillkernel-*.log
    expire_in: 1 week

analyze:static:
  stage: analyze
  image: debian:11-slim
  before_script:
    - apt-get update -qq
    - apt-get install -y sparse build-essential
  script:
    - cd nst-kernel/test
    - ./static-analysis.sh
  artifacts:
    when: always
    paths:
      - nst-kernel/test/static-analysis-results-*/

test:software:
  stage: test
  image: debian:11-slim
  parallel:
    matrix:
      - TEST: test-proc
      - TEST: test-typewriter
      - TEST: low-memory-test
  script:
    - cd nst-kernel/test
    - ./${TEST}.sh
  artifacts:
    when: always
    paths:
      - /tmp/quillkernel-*.log
```

## Jenkins Pipeline

`Jenkinsfile`:

```groovy
pipeline {
    agent any
    
    stages {
        stage('Setup') {
            steps {
                sh '''
                    # Install dependencies
                    sudo apt-get update
                    sudo apt-get install -y gcc-arm-linux-gnueabi sparse bc
                '''
            }
        }
        
        stage('Build Verification') {
            steps {
                dir('nst-kernel') {
                    sh './squire-kernel-patch.sh'
                    dir('test') {
                        sh './verify-build-simple.sh'
                    }
                }
            }
        }
        
        stage('Static Analysis') {
            steps {
                dir('nst-kernel/test') {
                    sh './static-analysis.sh || true'
                }
            }
        }
        
        stage('Parallel Tests') {
            parallel {
                stage('Proc Tests') {
                    steps {
                        dir('nst-kernel/test') {
                            sh './test-proc.sh'
                        }
                    }
                }
                stage('Typewriter Tests') {
                    steps {
                        dir('nst-kernel/test') {
                            sh './test-typewriter.sh'
                        }
                    }
                }
                stage('Memory Tests') {
                    steps {
                        dir('nst-kernel/test') {
                            sh './low-memory-test.sh'
                        }
                    }
                }
            }
        }
    }
    
    post {
        always {
            archiveArtifacts artifacts: '**/test-results-*/**', 
                           allowEmptyArchive: true
            archiveArtifacts artifacts: '/tmp/quillkernel-*.log',
                           allowEmptyArchive: true
            
            // Parse test results
            sh '''
                FAILURES=$(grep -h "\\[FAIL\\]" /tmp/quillkernel-*.log | wc -l || echo 0)
                if [ "$FAILURES" -gt 0 ]; then
                    echo "Found $FAILURES test failures"
                    exit 1
                fi
            '''
        }
        success {
            echo 'All QuillKernel tests passed!'
        }
        failure {
            echo 'QuillKernel tests failed - check logs'
        }
    }
}
```

## Test Result Parsing

### Exit Codes
- `0`: All tests passed
- `1`: Test failures
- `4`: Tests skipped (missing requirements)

### Log Parsing
```bash
# Count failures
FAILURES=$(grep -c "\[FAIL\]" test.log)

# Count warnings  
WARNINGS=$(grep -c "\[WARN\]" test.log)

# Extract summary
grep "Tests Passed:" test.log
grep "Tests Failed:" test.log
```

### JUnit XML Generation
Create a script to convert logs to JUnit format:

```bash
#!/bin/bash
# convert-to-junit.sh

LOG_FILE=$1
XML_FILE=$2

cat > "$XML_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<testsuites name="QuillKernel Tests">
  <testsuite name="$(basename $LOG_FILE .log)">
EOF

# Parse log and generate test cases
while IFS= read -r line; do
    if [[ $line =~ \[(PASS|FAIL|SKIP)\]\ (.+) ]]; then
        STATUS="${BASH_REMATCH[1]}"
        TEST="${BASH_REMATCH[2]}"
        
        case $STATUS in
            PASS)
                echo "    <testcase name=\"$TEST\" />" >> "$XML_FILE"
                ;;
            FAIL)
                echo "    <testcase name=\"$TEST\">" >> "$XML_FILE"
                echo "      <failure message=\"Test failed\" />" >> "$XML_FILE"
                echo "    </testcase>" >> "$XML_FILE"
                ;;
            SKIP)
                echo "    <testcase name=\"$TEST\">" >> "$XML_FILE"
                echo "      <skipped message=\"Test skipped\" />" >> "$XML_FILE"
                echo "    </testcase>" >> "$XML_FILE"
                ;;
        esac
    fi
done < "$LOG_FILE"

echo "  </testsuite>" >> "$XML_FILE"
echo "</testsuites>" >> "$XML_FILE"
```

## Docker-based CI

### Dockerfile for CI
```dockerfile
FROM debian:11-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc-arm-linux-gnueabi \
    git \
    sparse \
    bc \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Copy test suite
COPY nst-kernel /nst-kernel
WORKDIR /nst-kernel

# Apply patches
RUN ./squire-kernel-patch.sh

# Run tests by default
CMD ["test/run-all-tests.sh"]
```

### Docker Compose for CI
```yaml
version: '3.8'

services:
  quillkernel-tests:
    build:
      context: .
      dockerfile: ci/Dockerfile
    volumes:
      - ./test-results:/nst-kernel/test/test-results
      - ./logs:/tmp
    environment:
      - CI=true
      - TERM=xterm
```

## Best Practices

### 1. Fail Fast
```yaml
# Stop on first failure
script:
  - set -e
  - ./test1.sh
  - ./test2.sh
```

### 2. Parallel Execution
Run independent tests in parallel:
```yaml
parallel:
  matrix:
    - TEST: [test1, test2, test3]
```

### 3. Artifact Collection
Always collect logs, even on failure:
```yaml
artifacts:
  when: always
  paths:
    - logs/
    - test-results/
```

### 4. Caching
Cache dependencies for faster builds:
```yaml
cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - .apt/
    - .cache/
```

### 5. Notifications
Send medieval-themed notifications:
```bash
# slack-notify.sh
if [ "$BUILD_STATUS" = "success" ]; then
    MSG="🏰 Huzzah! The build passes! Thy code is worthy!"
else
    MSG="🏰 Alas! The build fails! The jester weeps!"
fi

curl -X POST -H 'Content-type: application/json' \
    --data "{\"text\":\"$MSG\"}" \
    "$SLACK_WEBHOOK_URL"
```

## Monitoring Test Trends

Track test performance over time:

```python
#!/usr/bin/env python3
# analyze-trends.py

import json
import glob
from datetime import datetime

results = []
for log in glob.glob("test-results-*/summary.txt"):
    with open(log) as f:
        data = f.read()
        passed = int(re.search(r"Passed: (\d+)", data).group(1))
        failed = int(re.search(r"Failed: (\d+)", data).group(1))
        date = datetime.fromtimestamp(os.path.getmtime(log))
        
        results.append({
            "date": date.isoformat(),
            "passed": passed,
            "failed": failed,
            "success_rate": passed / (passed + failed) * 100
        })

# Generate report
print(json.dumps(results, indent=2))
```

## Conclusion

QuillKernel's test suite is designed for easy CI/CD integration:
- Clear exit codes
- Structured logging
- Parallel execution support
- Hardware-independent tests
- Medieval charm included!

Remember: A well-tested kernel is a happy kernel! 🏰