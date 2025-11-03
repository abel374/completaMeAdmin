## Segurança do repositório

Este repositório teve uma chave sensível (service account) comprometida e removida da história do Git. Siga as instruções abaixo para alinhar os seus clones locais e evitar expor segredos no futuro.

### Importante — o que mudou

- O arquivo `assets/service-account.json` foi revogado e removido da história do Git usando BFG / reescrita de histórico.
- O histórico do repositório foi reescrito e já foi enviado para o remoto. Após isso, TODOS os colaboradores precisam sincronizar de forma limpa.

### Instruções para colaboradores

Recomendado (mais seguro): clonar novamente o repositório:

```powershell
git clone https://github.com/abel374/completaMeAdmin.git
```

Alternativa (se por algum motivo não puder clonar novamente): sobrescrever seu repositório local (irá descartar mudanças locais não commitadas):

```powershell
Set-Location -Path 'F:\path\to\seu\repositorio'
git fetch origin
git reset --hard origin/main
git clean -fd
```

Observação: após a reescrita de história, hashes de commits antigos não existirão mais no remoto — portanto qualquer branch ou referência que dependa desses commits antigos poderá precisar ser recriada.

### Boas práticas para evitar vazamento de segredos

- Nunca comite arquivos de credenciais no repositório (por exemplo: `service-account.json`, chaves privadas, tokens de API).
- Use variáveis de ambiente, segredos do CI/CD (GitHub Secrets, GitLab CI variables), ou serviços de gerenciamento de segredos (Vault, Google Secret Manager).
- Adicione padrões adequados no `.gitignore` (por exemplo: `assets/service-account.json`).
- Ative o Secret Scanning / Push Protection no GitHub e configure alertas para chaves cómpostas.
- Rotacione chaves imediatamente se alguma credencial for exposta e registre a ação (onde foi exposta, quando, e quem rotacionou).

### O que nós já fizemos

- A chave foi revogada no Google Cloud (rotacionada/removida). (verificar no console do GCP)
- Foram executados: BFG Repo-Cleaner, `git reflog expire --expire=now --all` e `git gc --prune=now --aggressive` e push forçado para o remoto.

### Contato

Se você tiver dúvidas ou encontrar problemas para sincronizar, abra uma issue privada no repo ou contate o mantenedor principal.

Obrigado por seguir as práticas de segurança.
