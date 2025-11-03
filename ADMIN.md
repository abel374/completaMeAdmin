Admin instructions and security

Este arquivo descreve como usar as ferramentas administrativas do repositório de forma segura.

## Nunca comitar chaves

- Não deixe o arquivo de service account do Firebase no repositório. Ele dá acesso total ao projeto.
- O repositório já contém uma entrada em `.gitignore` para `assets/service-account.json`.

## Colocar a service account localmente

1. Faça download da chave de service account (JSON) no console do Firebase / Google Cloud (IAM & Admin > Service accounts).
2. Salve o arquivo localmente em `assets/service-account.json` (ou outro local de sua preferência).
3. Se usar outro local, passe o caminho como segundo argumento ao script `set-admin.js`.

Exemplo de uso do script (na raiz do projeto):

```
# instalar dependências (apenas uma vez)
npm init -y
npm install firebase-admin

# executar (substitua <UID> pelo uid do usuário)
node set-admin.js <UID>

# ou especificar o caminho do service account explicitamente
node set-admin.js <UID> C:\caminho\para\service-account.json
```

## Remover a chave do histórico do Git (se já foi comitada)

Se você já acidentalmente comitou a chave, remova-a do repositório e do histórico:

```
# remover do índice (mantém arquivo local)
git rm --cached assets/service-account.json
git commit -m "removendo service account do repo"

# Para remover do histórico (opcional e destrutivo):
# use com cuidado: reescreve o histórico do Git
# git filter-branch --force --index-filter "git rm --cached --ignore-unmatch assets/service-account.json" --prune-empty --tag-name-filter cat -- --all
```

## Uso seguro

- Execute `set-admin.js` apenas em máquinas seguras. Não exponha a service account em ambientes públicos.
- Prefira usar Cloud Functions protegidas ou uma ferramenta de administração interna para operações frequentes.
- Proteja suas rules do Firestore para checar `request.auth.token.admin == true` antes de permitir writes críticos.

## Recomendação final

- Se for necessário dar acesso administrativo a outros colaboradores, prefira criar um processo interno (Function callable protegida por admins existentes) em vez de distribuir a chave de service account.

---
Gerado automaticamente pelo assistente — revise e ajuste conforme sua política de segurança.
