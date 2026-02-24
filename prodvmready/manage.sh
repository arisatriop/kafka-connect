#!/bin/bash

# Kafka Connect Production Setup - Helper Scripts

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE} $1 ${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Check if Docker and Docker Compose are installed
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    print_status "Docker and Docker Compose are installed ✓"
}

# Start the entire stack
start_stack() {
    print_header "Starting Kafka Connect Stack"
    
    # Create directories if they don't exist
    mkdir -p ./connectors
    
    # Start services
    if docker compose version &> /dev/null; then
        docker compose up -d
    else
        docker-compose up -d
    fi
    
    print_status "Stack started successfully!"
    print_status "Services will be available at:"
    print_status "  • Kafka Broker: localhost:9092"
    print_status "  • PostgreSQL: localhost:5432"
    print_status "  • Schema Registry: http://localhost:8081"
    print_status "  • Kafka Connect: http://localhost:8083"
    print_status "  • Connect UI: http://localhost:8000"
    print_status "  • AKHQ: http://localhost:8080"
    print_status "  • Kafdrop: http://localhost:9000"
    
    print_warning "Please wait a few minutes for all services to be fully ready."
}

# Stop the entire stack
stop_stack() {
    print_header "Stopping Kafka Connect Stack"
    
    if docker compose version &> /dev/null; then
        docker compose down
    else
        docker-compose down
    fi
    
    print_status "Stack stopped successfully!"
}

# Clean up everything (including volumes)
cleanup() {
    print_header "Cleaning Up Everything"
    
    print_warning "This will remove all containers, networks, and volumes. Are you sure? (y/N)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        if docker compose version &> /dev/null; then
            docker compose down -v --remove-orphans
        else
            docker-compose down -v --remove-orphans
        fi
        
        # Remove any dangling volumes
        docker volume prune -f
        
        print_status "Cleanup completed!"
    else
        print_status "Cleanup cancelled."
    fi
}

# Check service health
check_health() {
    print_header "Checking Service Health"
    
    # Check Kafka
    print_status "Checking Kafka..."
    if curl -f http://localhost:9092 &> /dev/null; then
        print_status "Kafka: ✓ Healthy"
    else
        print_warning "Kafka: ⚠ Not responding"
    fi
    
    # Check Schema Registry
    print_status "Checking Schema Registry..."
    if curl -f http://localhost:8081/subjects &> /dev/null; then
        print_status "Schema Registry: ✓ Healthy"
    else
        print_warning "Schema Registry: ⚠ Not responding"
    fi
    
    # Check Kafka Connect
    print_status "Checking Kafka Connect..."
    if curl -f http://localhost:8083/connectors &> /dev/null; then
        print_status "Kafka Connect: ✓ Healthy"
    else
        print_warning "Kafka Connect: ⚠ Not responding"
    fi
    
    # Check PostgreSQL
    print_status "Checking PostgreSQL..."
    if docker exec postgres-db pg_isready -U postgres &> /dev/null; then
        print_status "PostgreSQL: ✓ Healthy"
    else
        print_warning "PostgreSQL: ⚠ Not responding"
    fi
}

# Note: Connectors will be created manually via REST API or UI
# Example: curl -X POST -H "Content-Type: application/json" --data @your-connector.json http://localhost:8083/connectors

# List existing connectors
list_connectors() {
    print_header "Listing Active Connectors"
    
    if ! curl -f http://localhost:8083/connectors &> /dev/null; then
        print_error "Kafka Connect is not available"
        exit 1
    fi
    
    connectors=$(curl -s http://localhost:8083/connectors)
    echo "Active connectors: $connectors"
    
    # Get status of each connector
    for connector in $(echo "$connectors" | jq -r '.[]' 2>/dev/null); do
        print_status "Status of $connector:"
        curl -s "http://localhost:8083/connectors/$connector/status" | jq .
    done
}

# View logs
view_logs() {
    print_header "Viewing Service Logs"
    
    if [ -z "$1" ]; then
        print_status "Available services:"
        print_status "  • kafka"
        print_status "  • postgres"
        print_status "  • kafka-connect"
        print_status "  • schema-registry"
        print_status "  • akhq"
        print_status "  • kafka-connect-ui"
        print_status ""
        print_status "Usage: $0 logs <service-name>"
        return
    fi
    
    docker logs -f "$1"
}

# Show help
show_help() {
    echo "Kafka Connect Production Setup - Management Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  start              Start the entire stack"
    echo "  stop               Stop the entire stack"
    echo "  restart            Restart the entire stack"
    echo "  cleanup            Stop and remove all containers, networks, and volumes"
    echo "  health             Check health of all services"
    echo "  list-connectors    List all active connectors and their status"
    echo "  logs <service>     View logs of a specific service"
    echo "  help               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start"
    echo "  $0 logs kafka-connect"
    echo "  $0 health"
}

# Main script logic
case "$1" in
    start)
        check_prerequisites
        start_stack
        ;;
    stop)
        stop_stack
        ;;
    restart)
        stop_stack
        sleep 5
        check_prerequisites
        start_stack
        ;;
    cleanup)
        cleanup
        ;;
    health)
        check_health
        ;;
    list-connectors)
        list_connectors
        ;;
    logs)
        view_logs "$2"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        if [ -z "$1" ]; then
            show_help
        else
            print_error "Unknown command: $1"
            show_help
            exit 1
        fi
        ;;
esac