# PASSO A PASSO — PUBLICAR O CONTROLE DE GASTOS LEALE

**O site ainda não está publicado.** Primeiro configure o banco e os dois logins; depois faça a publicação na Vercel. Não use o modo demonstração para dados reais.

## 1 — Criar o banco Supabase
1. Abra https://supabase.com/dashboard e crie um novo projeto (guarde a senha do banco em local seguro).
2. Vá em **SQL Editor → New query**, cole TODO o conteúdo de `schema.sql`, EXCETO o `insert` final comentado dos UUIDs, e clique **Run**. Confira se não ocorreu erro.
3. Vá em **Authentication → Users**, crie ou convide os dois e-mails que terão acesso. Confirme os e-mails e configure as senhas de acesso. Se o convite redirecionar para uma página não configurada, use a opção administrativa apropriada de criar usuário com senha e e-mail confirmado.
4. Copie o ID UUID dos dois usuários em Authentication → Users.
5. Volte ao SQL Editor e execute, substituindo pelos IDs verdadeiros:

```sql
insert into public.authorized_users (user_id)
values ('UUID-DO-USUARIO-1'), ('UUID-DO-USUARIO-2');
```

6. Em **Authentication → Sign In / Providers → Email** (a nomenclatura pode variar), desative **Allow new users to sign up**. Assim, só os usuários já cadastrados conseguem entrar. Também confira as configurações de confirmação de e-mail.
7. Em **Project Settings → API Keys / Data API** copie a URL do projeto e a chave **publishable** (`sb_publishable_...`). Em `config.js`, coloque as duas strings nos campos `url` e `publishableKey`. Nunca use `sb_secret_...` nem `service_role` no front-end.

Exemplo de `config.js` (valores inventados):

```js
export const CONFIG = {
  url: 'https://SEU-PROJETO.supabase.co',
  publishableKey: 'sb_publishable_SUA_CHAVE_PUBLICA'
};
```

## 2 — Subir os arquivos para o GitHub
1. Abra https://github.com, entre ou crie uma conta.
2. Clique em **New repository**, nomeie `controle-de-gastos-leale` e selecione **Private**.
3. Abra o repositório → **Add file → Upload files**.
4. Envie o **conteúdo** desta pasta para a **raiz do repositório**: `index.html`, `config.js`, `schema.sql`, `vercel.json`, `README.md` e a pasta `api` com `parse-expense.js`. Confira que o arquivo `api/parse-expense.js` foi preservado. Clique em **Commit changes**.
5. **Nunca envie** a chave `OPENAI_API_KEY`, tokens secretos ou senhas ao GitHub.

## 3 — Publicar na Vercel
1. Abra https://vercel.com/new e conecte sua conta GitHub.
2. Importe o repositório privado `controle-de-gastos-leale`.
3. Deixe a pasta raiz como `./` e escolha preset **Other** (site estático com função em `/api`). Não defina um comando de build se não for exigido.
4. Em **Settings → Environment Variables** do projeto Vercel, crie as variáveis abaixo, marcando **Production**:

| Nome | Valor |
| --- | --- |
| `SUPABASE_URL` | a URL do seu projeto Supabase |
| `SUPABASE_PUBLISHABLE_KEY` | chave pública publishable do Supabase |
| `OPENAI_API_KEY` | sua chave secreta da plataforma de API da OpenAI |
| `OPENAI_MODEL` | `gpt-4o-mini` (opcional) |

5. Faça **Deploy**. Se adicionou as variáveis depois do primeiro deploy, vá em **Deployments → Redeploy** para aplicá-las. A Vercel gera um endereço parecido com `https://controle-de-gastos-leale.vercel.app` — o endereço real pode ser diferente.
6. **Não compartilhe a URL para uso real antes de testar o login.** Se a página informar “Modo demonstração”, o `config.js` não foi configurado ou publicado corretamente. Corrija antes de inserir despesas reais.

## 4 — Configurar IA real
1. Crie uma chave de API na plataforma https://platform.openai.com/api-keys e configure faturamento/limites de uso, se necessário. A assinatura ChatGPT não substitui cobrança da API.
2. Insira a chave somente em **Vercel → Settings → Environment Variables → OPENAI_API_KEY**, nunca em arquivos do site.
3. Redeploy. Após o login, vá em **Assistente IA** e tente: “Hoje gastei 180 reais de gasolina em Caxias do Sul no PIX”. Revise os campos antes de salvar.
4. O botão de microfone depende da permissão e suporte do navegador. Se não funcionar, use a digitação.

## 5 — Teste com os dois usuários
- Abra o site em dois aparelhos e entre com um e-mail distinto em cada um.
- Registre uma despesa no primeiro usuário e confira no segundo (pode ser necessário atualizar a página).
- Teste editar, apagar, anexar comprovante, exportar CSV e o assistente de IA.
- Tente acessar sem login; deve mostrar apenas a tela de login.
- Em caso de revogação de acesso, remova o UUID da tabela `authorized_users` no Supabase.

## 6 — Instalar no celular
- **iPhone:** Safari → Compartilhar → Adicionar à Tela de Início.
- **Android:** Chrome → menu ⋮ → Adicionar à tela inicial (ou Instalar, se disponível).

## Cuidados
- O código é um **MVP**; antes de armazenar informações financeiras sensíveis, faça testes de segurança e backups periódicos. As duas contas têm os mesmos poderes de ler, editar e excluir tudo.
- O aplicativo não se atualiza instantaneamente entre navegadores; atualize a página para ver as novas despesas.
- A IA usa uma função no servidor para verificar a identidade; o áudio pode ser processado pelo serviço de reconhecimento de voz do dispositivo/navegador. IA e hospedagem podem gerar custos.
- Para atualizar no futuro, modifique os arquivos no repositório GitHub e publique novamente pela Vercel (normalmente há deploy automático).
