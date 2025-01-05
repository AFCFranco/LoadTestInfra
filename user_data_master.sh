#!/bin/bash

# Actualizar paquetes
sudo dnf update -y

# Instalar Java (e.g., Amazon Corretto 17) y utilidades necesarias (wget, tar)
sudo dnf install -y java-17-amazon-corretto wget tar
sleep 10

# Variables
JMETER_VERSION="5.5"

# Crear directorio de trabajo
cd /opt

# Descargar JMeter
sudo wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz

# Descomprimir
sudo tar -xzf apache-jmeter-${JMETER_VERSION}.tgz

# Crear enlace simbólico para que /opt/jmeter apunte a la versión actual
sudo ln -s /opt/apache-jmeter-${JMETER_VERSION} /opt/jmeter

# (Opcional) Configurar JMeter como esclavo
cat <<EOF | sudo tee /opt/jmeter/start_slave.sh
#!/bin/bash

cd /opt/jmeter/bin

sudo chmod a+w jmeter.properties
sudo echo "server.rmi.ssl.disable=true" >> jmeter.properties

# nohup ./jmeter-server > /var/log/jmeter_slave.log 2>&1 &
EOF

sudo chmod +x /opt/jmeter/start_slave.sh
sudo /opt/jmeter/start_slave.sh
