# Issabel Telephony Dashboard

Um dashboard moderno, ágil e em tempo real para o ecossistema Issabel/Asterisk, construído de forma nativa e aderente às políticas de módulos estruturais da Palo Santo.

Este painel traz recursos visuais limpos e contemporâneos utilizando **Tailwind CSS** e **Alpine.js**, contornando o envelhecimento visual das telas originais, focado puramente na gestão operacional e de contact center. Não requer frameworks JS pesados ou compilações Node.js para rodar em produção.

## 🌟 Funcionalidades

- **Visão Geral em Tempo Real:** Conexão direta (PDO) na base `asteriskcdrdb.cdr` provendo KPIs do dia (Total, Atendidas, Abandonos, TME e TMA).
- **Console Dinâmico de Filas:** Análise direta através da Asterisk API (`queue show`) exibindo tempo de espera, abandono e ocupação de agentes em formato de "Bento Grid".
- **Monitoramento de Agentes & Canais:** Parsing eficiente (`core show channels`) identificando instantaneamente os contatos em andamento com badges dinâmicos de cor.
- **Saúde do Sistema:** Indicadores visuais do Status do Asterisk e MySQL.
- **Leveza de SPA (Single Page Application):** Requisições efetuadas silenciosamente a cada 5 segundos que se integram no front-end como JSON via o backend nativo, sem dar resfresh ou piscar a interface pesada do Issabel.

## 📂 Arquitetura do Módulo

O módulo respeita 100% a estrutura imposta pelo container Issabel original (CentOS / PHP 5.4 / Smarty 2):

```text
telephony_dashboard/
├── index.php             # Controlador e Parser Backend de métricas do sistema e do Asterisk CLI
├── menu.xml              # Manifesto padrão do Issabel para construção de módulo embarcado via RPM
├── README.md             # Guia atual
├── hooks/
│   └── apply.sh          # Hook autônomo bash + SQLite para injeção limpa de permissões de ACL e Menu
└── themes/
    └── default/
        └── index.tpl     # View Front-End blindada em {literal} contendo Tailwind + AlpineJs
```

## 🚀 Como Instalar (Standalone / Produção Física)

1. **Copie a pasta para o Servidor:**
   Transfira toda esta pasta (`telephony_dashboard`) para o caminho base de módulos do sistema no seu Issabel físico.
   ```bash
   cp -r telephony_dashboard /var/www/html/modules/
   ```
2. **Defina Permissões Adequadas:**
   Isso permite que os scripts da interface leiam os arquivos.
   ```bash
   chown -R asterisk:asterisk /var/www/html/modules/telephony_dashboard
   ```
3. **Registre o Módulo e Menus:**
   Utilize nosso hook embutido que injetará as regras de ACL e o atalho no menu principal (aba **PBX**).
   ```bash
   bash /var/www/html/modules/telephony_dashboard/hooks/apply.sh
   ```

Pronto! Acesse o Issabel e procure pelo menu **PBX > Telephony Dash**.

---

### *Anotações para o Desenvolvedor*
- **Sintaxe Smarty vs JavaScript:** Observe o uso da diretiva obrigatória `{literal}` dentro do arquivo `index.tpl`. Sem ela, o compilador Smarty vai crashear tentando ler arrays Javascript `{...}` e propriedades dinâmicas do AlpineJs, o que resulta num "Erro 500".
- **Customização de Filas do Frontend:** A integração real (`index.php`) foi desenhada com tolerância a falhas. Se a sua fila personalizada do ElastixCallCenter não renderizar agentes ocupados, o parser de canais e de filas deve ser aprimorado com expressões regulares para capturar os "Local/" e "Agent/" dinamicamente.
