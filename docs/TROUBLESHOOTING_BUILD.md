# JesterOS Build System Troubleshooting Guide

## Common Issues and Solutions

### Issue: "Downloaded kernel appears invalid"
**Cause**: Validation checking for wrong file location
**Solution**: Already fixed - checks `arch/arm/Kconfig` instead of root `Kconfig`

### Issue: Docker build fails with BuildKit
**Solution**:
```bash
# Ensure BuildKit is enabled
export DOCKER_BUILDKIT=1

# Clean and rebuild
docker builder prune -f
make docker-base-all
```

### Issue: Build succeeds but kernel doesn't work
**Solution**:
```bash
# Run post-build validation
./build/scripts/post-build-validate.sh

# Check kernel size (should be ~1.9MB)
ls -lh firmware/boot/uImage
```

### Issue: Cached builds not working
**Solution**:
```bash
# Check cache status
make docker-cache-info

# Optimize cache for JesterOS
./tools/docker-cache-manager.sh optimize
```

## Validation Checklist

Before building:
- [ ] Docker installed and running
- [ ] BuildKit available (`docker buildx version`)
- [ ] Project structure intact
- [ ] Sufficient disk space (10GB+)

After building:
- [ ] Kernel image exists (~1.9MB)
- [ ] Modules built successfully
- [ ] Validation tests pass
- [ ] No error messages in build log

## Build Performance Tips

1. **Enable BuildKit**: Always use `DOCKER_BUILDKIT=1`
2. **Use cache mounts**: Already configured in dockerfiles
3. **Parallel builds**: Use `make -j4` for faster builds
4. **Layer sharing**: Build base images first with `make docker-base-all`

## Testing

Run comprehensive tests:
```bash
./tests/run-all-tests.sh
```

Run specific test category:
```bash
./tests/test-build-system.sh
./tests/test-validation.sh
```