#!/bin/bash

# Nook Writer Docker Management Script
# This script provides easy management of the Nook writer Docker services

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
}

# Function to check if Docker Compose is available
check_compose() {
    if ! command -v docker-compose >/dev/null 2>&1; then
        print_error "Docker Compose is not installed. Please install Docker Compose and try again."
        exit 1
    fi
}

# Function to create required directories
create_directories() {
    print_status "Creating required directories..."
    mkdir -p config data backups
    chmod 755 config data backups
    print_success "Directories created successfully"
}

# Function to start services
start_services() {
    print_status "Starting Nook writer services..."
    docker-compose up -d --build
    print_success "Services started successfully"
    
    # Wait a moment for services to fully start
    sleep 5
    
    # Check service status
    docker-compose ps
}

# Function to stop services
stop_services() {
    print_status "Stopping Nook writer services..."
    docker-compose down
    print_success "Services stopped successfully"
}

# Function to restart services
restart_services() {
    print_status "Restarting Nook writer services..."
    docker-compose restart
    print_success "Services restarted successfully"
}

# Function to show logs
show_logs() {
    print_status "Showing service logs..."
    docker-compose logs -f
}

# Function to access container
access_container() {
    print_status "Accessing Nook writer container..."
    docker-compose exec nookwriter bash
}

# Function to show status
show_status() {
    print_status "Service status:"
    docker-compose ps
    
    echo
    print_status "Resource usage:"
    docker stats --no-stream nookwriter 2>/dev/null || print_warning "Container not running"
}

# Function to clean up
cleanup() {
    print_warning "This will remove all containers, networks, and volumes. Are you sure? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        print_status "Cleaning up Docker resources..."
        docker-compose down -v --remove-orphans
        docker system prune -f
        print_success "Cleanup completed"
    else
        print_status "Cleanup cancelled"
    fi
}

# Function to show help
show_help() {
    echo "Nook Writer Docker Management Script"
    echo
    echo "Usage: $0 [COMMAND]"
    echo
    echo "Commands:"
    echo "  start     - Start the Nook writer services"
    echo "  stop      - Stop the Nook writer services"
    echo "  restart   - Restart the Nook writer services"
    echo "  logs      - Show service logs"
    echo "  access    - Access the container shell"
    echo "  status    - Show service status and resource usage"
    echo "  cleanup   - Remove all containers, networks, and volumes"
    echo "  help      - Show this help message"
    echo
    echo "Examples:"
    echo "  $0 start      # Start services"
    echo "  $0 access     # Access container"
    echo "  $0 logs       # View logs"
}

# Main script logic
main() {
    # Check prerequisites
    check_docker
    check_compose
    
    # Parse command line arguments
    case "${1:-start}" in
        start)
            create_directories
            start_services
            ;;
        stop)
            stop_services
            ;;
        restart)
            restart_services
            ;;
        logs)
            show_logs
            ;;
        access)
            access_container
            ;;
        status)
            show_status
            ;;
        cleanup)
            cleanup
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
