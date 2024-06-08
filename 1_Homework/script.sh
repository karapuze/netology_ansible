#!/bin/bash

# задаем имена контейнеров и используемые образы
containers=(
  "centos7:centos:7"
  "ubuntu:ubuntu:latest"
  "fedora:fedora:latest"
)

# Функция для поднятия контейнеров
start_containers() {
  for container in "${containers[@]}"; do
    IFS=':' read -r name image <<< "$container"
    echo "Запуск контейнера $name на базе образа $image"
    docker run -d --name "$name" "$image" tail -f /dev/null
  done
}

# Функция для установки Python 3 в контейнере Ubuntu, потому что без него ошибка возникает
install_python_in_ubuntu() {
  echo "Устанавливаем Python 3 в контейнере Ubuntu"
  docker exec ubuntu apt-get update
  docker exec ubuntu apt-get install -y python3
}

# Функция для остановки и удаления контейнеров
stop_containers() {
  for container in "${containers[@]}"; do
    IFS=':' read -r name image <<< "$container"
    echo "Остановка контейнера $name"
    docker stop "$name"
    echo "Удаление контейнера $name"
    docker rm "$name"
  done
}


# Поднимаем контейнеры
start_containers

# Даем контейнерам время для запуска
sleep 5

# Устанавливаем Python 3 в контейнере Ubuntu
install_python_in_ubuntu

# Запуск ansible-playbook

ansible-playbook -i 1_Homework/playbook/inventory/prod.yml 1_Homework/playbook/site.yml --ask-vault-pass 

# Останавливаем и удаляем контейнеры после завершения работы ansible-playbook
stop_containers

echo "Все выполнено"
