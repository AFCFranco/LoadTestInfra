#!/bin/bash
# =============================================================================
# User Data Script para Amazon Linux 2023
# Instala Java 17 (Corretto), InfluxDB 1.11.8 y Grafana.
# =============================================================================

# 1. Actualizar el sistema
dnf update -y

# 2. Instalar Java (Amazon Corretto 17)
echo "Instalando Java (Amazon Corretto 17)..."
dnf install -y java-17-amazon-corretto-headless

# 3. Descargar e instalar InfluxDB 1.11.8 desde .tar.gz
echo "Descargando InfluxDB 1.11.8..."
wget https://download.influxdata.com/influxdb/releases/influxdb-1.11.8-linux-amd64.tar.gz -O /tmp/influxdb-1.11.8-linux-amd64.tar.gz

echo "Descomprimiendo InfluxDB..."
cd /tmp
tar -xvzf influxdb-1.11.8-linux-amd64.tar.gz
cd influxdb-1.11.8-linux-amd64

echo "Instalando binarios de InfluxDB en /usr/local/bin/..."
cp influx* /usr/local/bin/

# Crear directorios para datos y logs (ajusta a tu preferencia)
mkdir -p /var/lib/influxdb
mkdir -p /var/log/influxdb

# 4. Crear servicio systemd para InfluxDB (opcional pero recomendado)
echo "Creando servicio systemd para InfluxDB..."
cat << 'EOF' > /etc/systemd/system/influxdb.service
[Unit]
Description=InfluxDB Service
After=network-online.target

[Service]
ExecStart=/usr/local/bin/influxd --config /etc/influxdb/influxdb.conf
Restart=on-failure
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF

# (Ajusta la ruta del archivo de configuración si tienes un influxdb.conf personalizado)

# 5. Habilitar e iniciar servicio de InfluxDB
systemctl daemon-reload
systemctl enable influxdb
systemctl start influxdb

# 6. Instalar Grafana
# Opción A: usando repositorio oficial 
# (Descomenta si quieres la última versión de Grafana; coméntalo si usas el RPM)
# tee /etc/yum.repos.d/grafana.repo <<EOF
# [grafana]
# name=grafana
# baseurl=https://packages.grafana.com/oss/rpm
# repo_gpgcheck=1
# enabled=1
# gpgcheck=1
# gpgkey=https://packages.grafana.com/gpg.key
# sslverify=1
# sslcacert=/etc/pki/tls/certs/ca-bundle.crt
# EOF
# dnf install -y grafana

# Opción B: instalando un RPM específico de Grafana
# Ajusta la versión según requieras:
GRAFANA_VERSION="10.0.0-1"
echo "Descargando e instalando Grafana v${GRAFANA_VERSION}..."
wget "https://dl.grafana.com/oss/release/grafana-${GRAFANA_VERSION}.x86_64.rpm" -O /tmp/grafana.rpm
dnf install -y /tmp/grafana.rpm

# 7. Habilitar e iniciar Grafana
systemctl enable grafana-server
systemctl start grafana-server

# 8. Mensaje final
echo "============================================================="
echo "Instalación completada. Se han instalado y habilitado:"
echo "  - Java 17 (Corretto)"
echo "  - InfluxDB 1.11.8 (servicio systemd: influxdb.service)"
echo "  - Grafana (servicio systemd: grafana-server)"
echo "============================================================="
