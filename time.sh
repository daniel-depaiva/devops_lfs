#!/bin/bash

echo "===== CONFIGURANDO DATA E HORA ====="

# Timezone
echo "Definindo timezone..."
sudo timedatectl set-timezone America/Sao_Paulo

# Ativar sincronização automática (NTP)
echo "Ativando NTP..."
sudo timedatectl set-ntp true

# Garantir serviço ativo
sudo systemctl enable systemd-timesyncd
sudo systemctl restart systemd-timesyncd

# Forçar sync imediato
echo "Forçando sincronização..."
sudo timedatectl status

echo "===== FINALIZADO ====="