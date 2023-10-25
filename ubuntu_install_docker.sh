#!/bin/bash

# Usuń istniejące pakiety związane z Dockerem
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    sudo apt-get remove -y $pkg
done

# Aktualizuj repozytorium
sudo apt-get update -y

# Zainstaluj wymagane pakiety, jeśli nie są już zainstalowane
for pkg in ca-certificates curl gnupg; do
    if ! dpkg -l | grep -q $pkg; then
        sudo apt-get install -y $pkg
    fi
done

# Dodaj oficjalny klucz GPG Dockera
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Dodaj repozytorium Dockera do źródeł Apt
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Aktualizuj repozytorium
sudo apt-get update -y

# Sprawdź, czy Docker jest już zainstalowany
if ! command -v docker &> /dev/null; then
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

# Dodaj grupę docker i dodaj użytkownika do tej grupy
if ! grep -q docker /etc/group; then
    sudo groupadd docker
fi
sudo usermod -aG docker $USER

# Sprawdź działanie Dockera
if docker run hello-world; then
    echo "Docker został pomyślnie zainstalowany i skonfigurowany!"
    echo "Aby zastosować zmiany w grupach, zaloguj się ponownie lub uruchom komendę 'newgrp docker'."
else
    echo "Wystąpił problem podczas testowania Dockera. Sprawdź konfigurację i spróbuj ponownie."
    exit 1
fi
