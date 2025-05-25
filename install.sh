#!/bin/bash

# Kolory
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Funkcje pomocnicze
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}❌ Błąd: $1 nie jest zainstalowany. Zainstaluj go przed kontynuacją.${NC}"
        exit 1
    fi
}

# Sprawdzenie wymagań wstępnych
echo -e "${YELLOW}🔍 Sprawdzanie wymagań wstępnych...${NC}"
check_command node
check_command npm
check_command docker

# Instalacja zależności Node.js
echo -e "\n${YELLOW}📦 Instalacja zależności Node.js...${NC}
npm install
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Błąd podczas instalacji zależności Node.js${NC}"
    exit 1
fi

# Instalacja n8n globalnie
echo -e "\n${YELLOW}🚀 Instalacja n8n...${NC}
npm install -g n8n
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}⚠️  Uwaga: Nie udało się zainstalować n8n globalnie. Próba instalacji lokalnej...${NC}"
    npm install n8n --save
fi

# Tworzenie katalogów
echo -e "\n${YELLOW}📂 Tworzenie struktury katalogów...${NC}"
mkdir -p workflows

# Kopiowanie pliku konfiguracyjnego
if [ ! -f ".env" ]; then
    if [ -f "sample.env" ]; then
        cp sample.env .env
        echo -e "${GREEN}✓ Skopiowano sample.env do .env${NC}"
        echo -e "${YELLOW}ℹ️  Edytuj plik .env i ustaw swoje dane dostępowe.${NC}"
    else
        echo -e "${YELLOW}⚠️  Uwaga: Brak pliku sample.env. Utwórz plik .env ręcznie.${NC}"
    fi
else
    echo -e "${GREEN}✓ Plik .env już istnieje.${NC}"
fi

# Ustawianie uprawnień do skryptów
chmod +x n8n_setup.sh

# Instalacja zależności Dockera (jeśli potrzebne)
echo -e "\n${YELLOW}🐳 Sprawdzanie Dockera...${NC}
if ! docker info &> /dev/null; then
    echo -e "${YELLOW}ℹ️  Docker nie jest uruchomiony. Uruchom Docker przed użyciem n8n.${NC}
else
    echo -e "${GREEN}✓ Docker jest uruchomiony.${NC}"
fi

# Podsumowanie
echo -e "\n${GREEN}✅ Instalacja zakończona pomyślnie!${NC}"
echo -e "\nNastępne kroki:"
echo -e "1. Edytuj plik ${YELLOW}.env${NC} i ustaw swoje dane dostępowe"
echo -e "2. Uruchom aplikację komendą: ${YELLOW}npm start${NC}"
echo -e "3. Aby uruchomić n8n: ${YELLOW}./n8n_setup.sh${NC}"

echo -e "\n${GREEN}🎉 Gotowe! Możesz teraz uruchomić aplikację.${NC}"
