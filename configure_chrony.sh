#!/bin/bash

# Verifica se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
  echo "Este script precisa ser executado como root."
  exit 1
fi

# Instala o Chrony, se não estiver instalado
if ! command -v chronyd &>/dev/null; then
  echo "Instalando o Chrony..."
  
  # Verifica qual gerenciador de pacotes está disponível no sistema
  if command -v apt-get &>/dev/null; then
    apt-get update
    apt-get install -y chrony
  elif command -v yum &>/dev/null; then
    yum install -y chrony
  else
    echo "Gerenciador de pacotes não suportado."
    exit 1
  fi
fi

# Servidores NTP do Brasil
ntp_servers=(
  "a.st1.ntp.br"
  "b.st1.ntp.br"
  "c.st1.ntp.br"
)

# Faz um backup do arquivo de configuração original
cp /etc/chrony/chrony.conf /etc/chrony/chrony.conf.bak

# Configura o arquivo chrony.conf
cat <<EOF > /etc/chrony/chrony.conf
# Chrony configuration file

# Servidores NTP do Brasil
$(printf "server %s iburst\n" "${ntp_servers[@]}")

# Outras configurações aqui, se necessário

EOF

# Reinicia o serviço Chrony para aplicar as alterações
if command -v systemctl &>/dev/null; then
  systemctl restart chronyd
elif command -v service &>/dev/null; then
  service chronyd restart
else
  echo "Não foi possível reiniciar o serviço Chrony automaticamente."
fi

echo "Configuração do Chrony concluída."
