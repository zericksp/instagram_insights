# 📱 Instagram Insights Dashboard

> Sistema completo para visualizar métricas do Instagram com app Flutter e renovação automática de tokens via PHP/MySQL.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=flat&logo=flutter)](https://flutter.dev)
[![PHP](https://img.shields.io/badge/PHP-7.4+-777BB4?style=flat&logo=php)](https://php.net)
[![MySQL](https://img.shields.io/badge/MySQL-5.7+-4479A1?style=flat&logo=mysql)](https://mysql.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 🎯 Funcionalidades

- 📊 **Dashboard Flutter** com gráficos interativos
- 🔄 **Renovação automática** de tokens Instagram/Facebook
- 🗄️ **Sistema de cache** inteligente
- 📧 **Alertas por email** para tokens vencidos
- 🔐 **Segurança avançada** com logs de auditoria
- 📈 **Métricas completas**: seguidores, alcance, engajamento
- 🌐 **API REST** para integração

## 📱 Screenshots

<div align="center">
  <img src="screenshots/overview.png" width="200" alt="Visão Geral">
  <img src="screenshots/followers.png" width="200" alt="Seguidores">
  <img src="screenshots/engagement.png" width="200" alt="Engajamento">
  <img src="screenshots/content.png" width="200" alt="Conteúdo">
</div>

## 🚀 Instalação Rápida

### 1. Clone o Repositório
```bash
git clone https://github.com/seuusuario/instagram-insights-dashboard.git
cd instagram-insights-dashboard
```

### 2. Setup Automático (Backend)
```bash
cd backend
php setup_instagram_system.php
```

### 3. Configurar Flutter App
```bash
cd flutter_app
flutter pub get
flutter run
```

**🎉 Pronto! Sistema funcionando em 5 minutos!**

---

## 📁 Estrutura do Projeto

```
instagram-insights-dashboard/
├── 📱 flutter_app/              # App Flutter
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/             # Telas do app
│   │   ├── services/            # APIs e serviços
│   │   └── widgets/             # Componentes reutilizáveis
│   └── pubspec.yaml
├── 🔧 backend/                  # Sistema PHP
│   ├── api/                     # Endpoints REST
│   ├── config/                  # Configurações
│   ├── cron/                    # Jobs automáticos
│   ├── logs/                    # Logs do sistema
│   └── setup_instagram_system.php
├── 📊 database/                 # Scripts SQL
│   └── migrations/
├── 📸 screenshots/              # Capturas de tela
├── 📝 docs/                     # Documentação
└── README.md
```

---

## ⚙️ Configuração Detalhada

### 🔧 Requisitos do Sistema

**Backend (PHP):**
- PHP 7.4+ (recomendado 8.1)
- MySQL 5.7+
- cURL habilitado
- Composer (opcional)

**Frontend (Flutter):**
- Flutter SDK 3.0+
- Dart 2.17+
- Android SDK / Xcode

### 🔑 Configuração do Instagram/Facebook

1. **Criar App no Facebook Developers:**
   - Acesse [developers.facebook.com](https://developers.facebook.com)
   - Crie novo app → Business
   - Adicione produtos: **Instagram Basic Display API**

2. **Obter Credenciais:**
   ```
   App ID: 1234567890
   App Secret: abc123def456...
   Instagram Account ID: 17841415250388479
   ```

3. **Configurar Permissões:**
   ```
   instagram_basic
   instagram_manage_insights
   pages_read_engagement
   business_management
   ```

### 🗄️ Setup do Banco de Dados

```bash
# 1. Executar script automático
php backend/setup_instagram_system.php

# 2. Ou manualmente
mysql -u root -p < database/migrations/001_create_tables.sql
```

### 📱 Configuração Flutter

```dart
// lib/services/instagram_api_service.dart
static const String _tokenApiUrl = 'https://seudominio.com/api/get_instagram_token.php';
```

---

## 🔄 Sistema de Renovação Automática

### Configurar Cron Job

```bash
# Editar crontab
crontab -e

# Adicionar linha (executa diariamente às 2h)
0 2 * * * /usr/bin/php /caminho/completo/backend/cron/refresh_tokens.php >> /var/log/instagram_cron.log 2>&1
```

### Monitoramento

```bash
# Ver status dos tokens
php backend/monitor_tokens.php

# Logs em tempo real
tail -f backend/logs/$(date +%Y-%m-%d)_instagram.log

# Testar renovação manual
php backend/cron/refresh_tokens.php
```

---

## 📊 Métricas Disponíveis

### Instagram Insights
- 👥 **Seguidores**: Contagem e crescimento
- 👀 **Alcance**: Usuários únicos alcançados
- 📈 **Impressões**: Total de visualizações
- ❤️ **Engajamento**: Curtidas, comentários, salvamentos
- 📍 **Demografia**: Localização e idade dos seguidores
- 📱 **Conteúdo**: Performance de posts e stories

### Dashboards Disponíveis
1. **Visão Geral**: Métricas principais + gráfico de alcance
2. **Seguidores**: Crescimento + demografia
3. **Engajamento**: Taxa de engajamento + interações
4. **Conteúdo**: Performance de posts + análise

---

## 🔐 Segurança

### Proteção de Dados
- ✅ Tokens criptografados no banco
- ✅ API com autenticação
- ✅ Logs de auditoria completos
- ✅ Arquivos sensíveis protegidos
- ✅ Validação de entrada

### .gitignore Configurado
```gitignore
# Dados sensíveis
backend/config/config.php
backend/logs/*.log
.env
*.key

# Cache Flutter
flutter_app/.dart_tool/
flutter_app/build/
```

---

## 🛠️ Desenvolvimento

### Estrutura do Flutter App

```dart
lib/
├── main.dart                    # Ponto de entrada
├── screens/
│   ├── main_screen.dart        # Bottom navigation
│   ├── overview_page.dart      # Dashboard principal
│   ├── followers_page.dart     # Análise de seguidores
│   ├── engagement_page.dart    # Métricas de engajamento
│   └── content_page.dart       # Performance de conteúdo
├── services/
│   └── instagram_api_service.dart  # Integração API
└── widgets/
    └── metric_card.dart        # Cards de métricas
```

### API Endpoints

```
GET  /api/get_instagram_token.php      # Obter token ativo
GET  /api/insights.php                 # Dados de insights
GET  /api/followers.php                # Dados de seguidores
POST /api/refresh_token.php            # Forçar renovação
```

### Comandos Úteis

```bash
# Flutter
flutter clean && flutter pub get
flutter run -d chrome                # Web
flutter build apk --release          # Android

# Backend
php -S localhost:8000                 # Servidor local
composer install                     # Dependências (se usar)
```

---

## 📈 Roadmap

### v1.1 (Próxima Release)
- [ ] 🌐 Dashboard web administrativo
- [ ] 📊 Relatórios em PDF
- [ ] 🔔 Notificações push
- [ ] 📱 Suporte a múltiplas contas

### v1.2 (Futuro)
- [ ] 🤖 Análise com IA
- [ ] 📧 Relatórios automáticos por email
- [ ] 🎯 Sugestões de melhorias
- [ ] 🔗 Integração com outras redes sociais

---

## 🤝 Contribuindo

1. **Fork** o projeto
2. **Crie** uma branch: `git checkout -b feature/nova-funcionalidade`
3. **Commit** suas mudanças: `git commit -m 'Adiciona nova funcionalidade'`
4. **Push** para a branch: `git push origin feature/nova-funcionalidade`
5. **Abra** um Pull Request

### Diretrizes
- 📝 Documente todas as funções
- 🧪 Adicione testes quando possível
- 📏 Siga os padrões de código
- 🔍 Teste antes de enviar PR

---

## 📞 Suporte

### 🐛 Encontrou um Bug?
- Abra uma [Issue](https://github.com/seuusuario/instagram-insights-dashboard/issues)
- Descreva o problema detalhadamente
- Inclua logs e screenshots

### 💡 Sugestões?
- Use [Discussions](https://github.com/seuusuario/instagram-insights-dashboard/discussions)
- Compartilhe ideias e melhorias

### 📧 Contato Direto
- Email: [seu@email.com](mailto:seu@email.com)
- LinkedIn: [Seu Nome](https://linkedin.com/in/seuperfil)

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.

---

## 🙏 Créditos

- **Instagram Basic Display API** - Meta/Facebook
- **Flutter Charts** - fl_chart package
- **PHP MySQL** - Renovação de tokens inspirada em sistemas profissionais

---

## ⭐ Mostre seu Apoio

Se este projeto te ajudou, considere dar uma ⭐ no GitHub!

---

<div align="center">
  <p>Desenvolvido com ❤️ por <a href="https://github.com/zericksp">José Ricardo dos Santos</a></p>
  <p>
    <a href="https://github.com/zericksp/instagram-insights-dashboard">🏠 Home</a>
    ·
    <a href="https://github.com/zericksp/instagram-insights-dashboard/issues">🐛 Report Bug</a>
    ·
    <a href="https://github.com/zericksp/instagram-insights-dashboard/discussions">💡 Request Feature</a>
  </p>
</div>