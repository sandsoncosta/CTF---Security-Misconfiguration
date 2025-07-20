# CTF Path Traversal - Lab de Segurança

🔐 **Um lab de Capture The Flag focado em Path Traversal e escalação de privilégios**

[![Docker](https://img.shields.io/badge/Docker-Required-blue?logo=docker)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-sandsoncosta-blue?logo=linkedin)](https://www.linkedin.com/in/sandsoncosta/)

---

## 📋 Sobre o Projeto

Este repositório contém um ambiente completo de CTF (Capture The Flag) desenvolvido para demonstrar vulnerabilidades de **Path Traversal** e técnicas de **escalação de privilégios** em um ambiente controlado e seguro. O ambiente é a replicação da box **OWASP 03** da **Extreme Hacking**.

O laboratório foi criado baseado no artigo: [CTF: De um Path Traversal ao acesso root](https://sandsoncosta.github.io/blog/ctf-de-um-path-traversal-ao-acesso-root/)

### 🎯 Objetivos de Aprendizagem

- Identificar e explorar vulnerabilidades de Path Traversal
- Praticar técnicas de enumeração e reconhecimento
- Aprender escalação de privilégios via PostgreSQL
- Desenvolver habilidades com reverse shells
- Compreender configurações inseguras de serviços web

---

## 🏗️ Arquitetura do Ambiente

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│    Nginx    │───▶│   Apache    │    │ PostgreSQL  │
│   (Port 80) │    │ (Port 8080) │    │ (Port 5432) │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       ├── T-Shirts App    ├── Image Server    ├── Database
       ├── Login Page      ├── Chibi Gallery   ├── Sudo Access
       └── Path Traversal  └── File Exposure   └── Root Access
```

### Serviços Configurados

- **Nginx**: Proxy reverso com autenticação básica
- **Apache**: Servidor de imagens com diretório exposto  
- **PostgreSQL**: Banco de dados com privilégios sudo

---

## 🚀 Instalação e Setup

### Pré-requisitos

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io docker-compose curl

# CentOS/RHEL
sudo yum install docker docker-compose curl

# Verificar instalação
docker --version
docker-compose --version
```

### Setup Automático

1. **Clone o repositório:**
```bash
git clone https://github.com/sandsoncosta/CTF---Security-Misconfiguration.git
cd CTF---Security-Misconfiguration
```

2. **Execute o setup (como sudo):**
```bash
sudo chmod +x setup.sh
sudo ./setup.sh
```

3. **Aguarde a conclusão:**
O script irá:
- ✅ Configurar todos os containers
- ✅ Baixar imagens necessárias  
- ✅ Criar arquivos de configuração
- ✅ Garantir criação de todas as flags
- ✅ Verificar funcionamento dos serviços

---

## ⚠️ Aviso Legal

Este laboratório foi criado **exclusivamente para fins educacionais** e de treinamento em segurança da informação. 

**⚠️ USO RESPONSÁVEL:**
- Use apenas em ambiente controlado
- Não teste em sistemas de terceiros sem autorização
- Respeite as leis locais de cibersegurança
- O autor não se responsabiliza pelo uso indevido

---

## 📞 Contato

- **Autor**: Sandson Costa
- **LinkedIn**: [@sandsoncosta](https://www.linkedin.com/in/sandsoncosta/)
- **Blog**: [sandsoncosta.github.io](https://sandsoncosta.github.io/)

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 🙏 Agradecimentos

- À Extreme Hacking pela box incrível. Pude aprender um cadim nessa box.

---

<div align="center">
  <strong>🔐 Happy Hacking! 🔐</strong>
</div>
