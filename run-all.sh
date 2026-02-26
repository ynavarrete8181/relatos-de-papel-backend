#!/bin/bash
set -e

echo "=========================================="
echo "  INICIANDO MICRO-SERVICIOS (Mac/Linux)"
echo "=========================================="

run_service () {
  local name="$1"
  local dir="$2"
  echo "→ Iniciando $name en $dir ..."
  (cd "$dir" && ./mvnw spring-boot:run) &
  echo "   PID: $!"
}

run_service "Eureka Server" "eureka-server"
sleep 10

run_service "ms-books-catalogue" "ms-books-catalogue"
sleep 8

run_service "ms-books-payments" "ms-books-payments"
sleep 8

run_service "API Gateway" "api-gateway"

echo "=========================================="
echo "  LISTO."
echo "  Eureka: http://localhost:8761"
echo "=========================================="

wait
