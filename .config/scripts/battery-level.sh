#!/bin/sh

# Defina o limite de bateria baixa e o limite para alerta de carga completa
threshold=20
charged=95

# Identifica o dispositivo de bateria automaticamente
battery=$(upower -e | grep 'battery_BAT1')

# Variáveis para armazenar o último estado e porcentagem
last_status=""
last_percentage=""

while true; do
    # Extrair status da bateria (charging/discharging/fully-charged/etc)
    battery_status=$(upower -i "$battery" | awk '/state:/ {print $2}')

    # Extrair a porcentagem da bateria (sem o símbolo %)
    battery_percentage=$(upower -i "$battery" | awk '/percentage:/ {gsub("%", "", $2); print $2}')

    # Verificar se o estado mudou
    if [ "$battery_status" != "$last_status" ]; then
        if [ "$battery_status" = "charging" ]; then
            dunstify "Aviso de Bateria" "A carregar. \nNível da bateria: ${battery_percentage}%"
        elif [ "$battery_status" = "discharging" ]; then
            dunstify "Aviso de Bateria" "A descarregar. \nNível da bateria: ${battery_percentage}%"
        fi
    fi

    # Verificar se a bateria está abaixo ou igual ao limite definido
    if [ "$battery_percentage" -le "$threshold" ] && [ "$battery_percentage" != "$last_percentage" ] && [ "$battery_status" = "discharging" ]; then
        dunstify "Bateria Baixa" "Nível da bateria: ${battery_percentage}%"
    fi

    # Alertar quando a carga estiver acima do valor definido
    if [ "$battery_percentage" -gt "$charged" ] && [ "$battery_percentage" != "$last_percentage" ] && [ "$battery_status" = "charging" ]; then
        dunstify "Bateria Carregada" "Nível da bateria: ${battery_percentage}%"
    fi

    # Atualizar variáveis
    last_status="$battery_status"
    last_percentage="$battery_percentage"

    # Esperar antes da próxima verificação
    sleep 60
done &
