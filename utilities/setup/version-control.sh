#!/bin/bash
# Version Control and Build Tracking System
# Manages semantic versioning and build metadata

set -euo pipefail
trap 'echo "Error at line $LINENO"' ERR

# Source configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$PROJECT_ROOT/.kernel.env"

# Version files
VERSION_FILE="$PROJECT_ROOT/VERSION"
BUILD_INFO="$PROJECT_ROOT/BUILD_INFO"
CHANGELOG="$PROJECT_ROOT/CHANGELOG.md"

# Get current version
get_version() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE"
    else
        echo "0.0.0"
    fi
}

# Parse semantic version
parse_version() {
    local version="$1"
    # Remove pre-release and build metadata
    local base_version="${version%%-*}"
    local pre_release=""
    local build_meta=""
    
    if [[ "$version" == *"-"* ]]; then
        local suffix="${version#*-}"
        if [[ "$suffix" == *"+"* ]]; then
            pre_release="${suffix%%+*}"
            build_meta="${suffix#*+}"
        else
            pre_release="$suffix"
        fi
    fi
    
    echo "$base_version|$pre_release|$build_meta"
}

# Bump version
bump_version() {
    local bump_type="${1:-patch}"  # major, minor, patch, pre
    local current=$(get_version)
    local parsed=$(parse_version "$current")
    
    IFS='|' read -r base pre build <<< "$parsed"
    IFS='.' read -r major minor patch <<< "$base"
    
    case "$bump_type" in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            pre=""
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            pre=""
            ;;
        patch)
            patch=$((patch + 1))
            pre=""
            ;;
        pre|alpha|beta|rc)
            if [ -z "$pre" ]; then
                pre="${bump_type}.1"
            else
                # Extract number from pre-release
                local pre_type="${pre%%.*}"
                local pre_num="${pre##*.}"
                if [[ "$pre_num" =~ ^[0-9]+$ ]]; then
                    pre_num=$((pre_num + 1))
                else
                    pre_num=1
                fi
                pre="${pre_type}.${pre_num}"
            fi
            ;;
        *)
            echo "Unknown bump type: $bump_type"
            exit 1
            ;;
    esac
    
    local new_version="${major}.${minor}.${patch}"
    [ -n "$pre" ] && new_version="${new_version}-${pre}"
    
    echo "$new_version"
}

# Update version
update_version() {
    local new_version="$1"
    local message="${2:-Version bump to $new_version}"
    
    echo "$new_version" > "$VERSION_FILE"
    
    # Update .kernel.env
    sed -i "s/export PROJECT_VERSION=.*/export PROJECT_VERSION=\"$new_version\"/" "$PROJECT_ROOT/.kernel.env"
    
    # Update kernel module version if exists
    local module_src="$PROJECT_ROOT/source/kernel/src/drivers/${KERNEL_MODULE_NAME}/${KERNEL_MODULE_NAME}_core.c"
    if [ -f "$module_src" ]; then
        sed -i "s/#define ${KERNEL_MODULE_PREFIX}_VERSION.*/#define ${KERNEL_MODULE_PREFIX}_VERSION \"$new_version\"/" "$module_src"
    fi
    
    echo "Version updated to: $new_version"
}

# Generate build info
generate_build_info() {
    local version=$(get_version)
    local git_hash=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    local git_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    local build_date=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
    local builder="${USER}@$(hostname)"
    
    cat > "$BUILD_INFO" <<EOF
QuillKernel Build Information
=============================
Version: $version
Git Hash: $git_hash
Git Branch: $git_branch
Build Date: $build_date
Builder: $builder
Module: ${KERNEL_MODULE_PREFIX}
Kernel: ${KERNEL_VERSION}
Architecture: ${KERNEL_ARCH}
=============================
EOF
    
    echo "Build info generated: $BUILD_INFO"
}

# Tag release
tag_release() {
    local version=$(get_version)
    local tag_name="v${version}"
    local message="${1:-Release ${version}}"
    
    # Remove pre-release suffix for major releases
    if [[ ! "$version" == *"-"* ]]; then
        echo "Creating release tag: $tag_name"
        git tag -a "$tag_name" -m "$message"
        echo "Tag created. Push with: git push origin $tag_name"
    else
        echo "Creating pre-release tag: $tag_name"
        git tag "$tag_name" -m "$message"
        echo "Lightweight tag created for pre-release"
    fi
}

# Show version info
show_info() {
    echo "===================================="
    echo "QuillKernel Version Information"
    echo "===================================="
    echo "Current Version: $(get_version)"
    echo ""
    
    if [ -f "$BUILD_INFO" ]; then
        cat "$BUILD_INFO"
    else
        echo "No build info available. Run 'build' to generate."
    fi
    
    echo ""
    echo "Recent Tags:"
    git tag -l "v*" | tail -5
}

# Update changelog
update_changelog() {
    local version=$(get_version)
    local date=$(date +"%Y-%m-%d")
    local changes="${1:-No changes specified}"
    
    if [ ! -f "$CHANGELOG" ]; then
        cat > "$CHANGELOG" <<EOF
# Changelog

All notable changes to QuillKernel will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

EOF
    fi
    
    # Insert new version at the top
    local temp_file=$(mktemp)
    cat > "$temp_file" <<EOF
# Changelog

All notable changes to QuillKernel will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [$version] - $date

### Changes
$changes

EOF
    
    # Append rest of changelog
    tail -n +7 "$CHANGELOG" >> "$temp_file"
    mv "$temp_file" "$CHANGELOG"
    
    echo "Changelog updated for version $version"
}

# Main command handler
case "${1:-help}" in
    get)
        get_version
        ;;
    bump)
        new_version=$(bump_version "${2:-patch}")
        update_version "$new_version" "Bump version to $new_version"
        generate_build_info
        echo "New version: $new_version"
        ;;
    set)
        if [ -z "${2:-}" ]; then
            echo "Usage: $0 set <version>"
            exit 1
        fi
        update_version "$2" "Set version to $2"
        generate_build_info
        ;;
    build)
        generate_build_info
        ;;
    tag)
        tag_release "${2:-}"
        ;;
    info)
        show_info
        ;;
    changelog)
        update_changelog "${2:-}"
        ;;
    help|*)
        cat <<EOF
QuillKernel Version Control System

Usage: $0 <command> [options]

Commands:
    get             Show current version
    bump [type]     Bump version (major|minor|patch|alpha|beta|rc)
    set <version>   Set specific version
    build           Generate build information
    tag [message]   Create git tag for current version
    info            Show version and build information
    changelog [msg] Update changelog with changes

Examples:
    $0 bump patch          # 1.0.0 -> 1.0.1
    $0 bump minor          # 1.0.1 -> 1.1.0
    $0 bump alpha          # 1.1.0 -> 1.1.0-alpha.1
    $0 set 2.0.0-beta.1    # Set to specific version
    $0 tag "First release" # Tag current version
    $0 changelog "Added boot support" # Update changelog

Current version: $(get_version)
EOF
        ;;
esac