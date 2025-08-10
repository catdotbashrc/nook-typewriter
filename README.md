# Nook Writer Docker Setup

A Docker-based writing environment optimized for e-readers and distraction-free writing, featuring Vim with specialized plugins and FBInk for e-ink display support.

## Features

- **Vim Editor**: Full-featured Vim with writing-focused plugins
- **FBInk**: E-ink display support for e-readers
- **Writing Plugins**: Pencil, Goyo, Zettel, and Lightline
- **Alpine Linux**: Lightweight, secure base image
- **Hardware Access**: Direct device access for e-reader connectivity
- **Data Persistence**: Automatic backups and data volume management

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- At least 1GB available RAM
- 2GB available disk space

## Quick Start

1. **Clone and navigate to the project:**
   ```bash
   cd nook
   ```

2. **Create required directories:**
   ```bash
   mkdir -p config data backups
   ```

3. **Build and start the services:**
   ```bash
   docker-compose up -d --build
   ```

4. **Access the writing environment:**
   ```bash
   docker-compose exec nookwriter bash
   ```

## Usage

### Starting the Service
```bash
# Start in background
docker-compose up -d

# Start with logs visible
docker-compose up

# Rebuild and start
docker-compose up -d --build
```

### Stopping the Service
```bash
# Stop services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

### Accessing the Container
```bash
# Interactive shell
docker-compose exec nookwriter bash

# Direct Vim access
docker-compose exec -it nookwriter vim

# Check logs
docker-compose logs nookwriter
```

### Writing Sessions
```bash
# Start a new writing session
docker-compose exec -it nookwriter vim

# Use Goyo for distraction-free writing
docker-compose exec -it nookwriter vim -c "Goyo"
```

## Configuration

### Volume Mounts
- `./config` → `/root/config` (read-only configuration files)
- `./data` → `/root/data` (writing projects and documents)
- `/dev` → `/dev` (device access for e-readers)
- `/sys` → `/sys` (system information)
- `/proc` → `/proc` (process information)

### Environment Variables
- `TERM=xterm-256color`: Terminal color support
- `EDITOR=vim`: Default editor
- `PAGER=less`: Default pager

### Resource Limits
- **Memory**: 256MB reserved, 512MB limit
- **CPU**: 0.5 cores reserved, 1.0 core limit

## Backup Service

The backup service automatically creates daily compressed backups of your writing data:
- **Location**: `./backups/`
- **Format**: `nookwriter-YYYYMMDD-HHMMSS.tar.gz`
- **Frequency**: Daily at midnight

## Security Considerations

⚠️ **Warning**: This container runs in privileged mode with host network access for hardware compatibility. This provides maximum access but reduces security isolation.

### Security Features
- Non-root user execution where possible
- Read-only configuration mounts
- Resource limits to prevent abuse
- Alpine Linux base for minimal attack surface

### Recommendations
- Run on isolated networks when possible
- Regularly update base images
- Monitor container logs for suspicious activity
- Use firewall rules to restrict external access

## Troubleshooting

### Common Issues

**Container won't start:**
```bash
# Check logs
docker-compose logs nookwriter

# Verify Docker daemon is running
docker info

# Check available resources
docker system df
```

**Permission denied errors:**
```bash
# Ensure proper directory permissions
chmod 755 config data backups

# Check Docker group membership
groups $USER
```

**Vim plugins not loading:**
```bash
# Rebuild container
docker-compose down
docker-compose up -d --build

# Check plugin installation
docker-compose exec nookwriter ls -la /root/.vim/pack/plugins/start/
```

### Performance Issues
- Monitor resource usage: `docker stats nookwriter`
- Adjust resource limits in `docker-compose.yml`
- Consider using SSD storage for data volumes

## Development

### Modifying the Dockerfile
1. Edit `nookwriter.dockerfile`
2. Rebuild: `docker-compose up -d --build`
3. Test changes in the container

### Adding New Plugins
1. Add plugin installation to Dockerfile
2. Rebuild container
3. Verify plugin loads correctly

### Custom Configurations
1. Place custom configs in `./config/`
2. Mount additional volumes in `docker-compose.yml`
3. Restart services: `docker-compose restart`

## License

This project is provided as-is for educational and personal use. Please ensure compliance with the licenses of included software (Vim, FBInk, Alpine Linux, etc.).

## Support

For issues and questions:
1. Check the troubleshooting section above
2. Review Docker and Docker Compose logs
3. Verify system requirements and permissions
4. Check for updates to base images and dependencies
