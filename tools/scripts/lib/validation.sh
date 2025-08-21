#!/bin/bash
# Validation helper functions for JesterOS build system

validate_docker_image() {
    local image="$1"
    if ! docker images | grep -q "$image"; then
        echo "Error: Docker image $image not found"
        return 1
    fi
    return 0
}

validate_kernel_source() {
    local kernel_path="$1"
    if [ ! -f "${kernel_path}/Makefile" ] || \
       [ ! -d "${kernel_path}/arch/arm" ] || \
       [ ! -f "${kernel_path}/arch/arm/Kconfig" ]; then
        echo "Error: Invalid kernel source at $kernel_path"
        return 1
    fi
    return 0
}

validate_build_output() {
    local output_file="$1"
    local expected_size_min="$2"
    
    if [ ! -f "$output_file" ]; then
        echo "Error: Expected output file $output_file not found"
        return 1
    fi
    
    local file_size=$(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file")
    if [ "$file_size" -lt "$expected_size_min" ]; then
        echo "Error: Output file $output_file too small ($file_size bytes)"
        return 1
    fi
    
    return 0
}