# Horizonte Financeiro: site

Site institucional do projeto. HTML e CSS puros, sem build, sem npm, sem
framework. Abrir o `index.html` no navegador já funciona.

```
index.html          Início
sobre.html          O projeto, as 4 aulas, perguntas frequentes
escolas.html        Inscrição de escola      → tabela hf_escolas
contato.html        Mensagem livre           → tabela hf_mensagens
privacidade.html    Política de Privacidade (LGPD)
termos.html         Termos de Uso
artigos.html        Listagem de artigos (vazia até o primeiro ser publicado)
artigos/<slug>.html cada artigo publicado, um arquivo por texto

sitemap.xml         7 URLs, para o Google
robots.txt          libera tudo, aponta o sitemap
llms.txt            resumo do projeto para modelos de linguagem

assets/css/style.css
assets/js/config.js  chaves do Supabase e canais de contato
assets/js/site.js    menu no celular + envio dos formulários
supabase/schema.sql  estrutura do banco (rodar uma vez)
vercel.json          cabeçalhos de segurança e cache
```

A estrutura de páginas e os arquivos de SEO seguem o mesmo padrão do projeto
Vestra: páginas legais no rodapé, `sitemap`, `robots` e `llms.txt` na raiz.

**Domínio.** O site está no ar em
<https://horizontefinanceiro.ong.br>. Esse endereço aparece no
`sitemap.xml`, no `robots.txt` e no `llms.txt`. Se um dia registrar domínio
próprio, um comando atualiza os três:

```bash
grep -rl horizontefinanceiro.ong.br . | xargs sed -i 's|horizontefinanceiro.ong.br|seu-dominio.com.br|g'
```

## Mudança de modelo, agosto de 2026

O projeto deixou de recrutar voluntário por inscrição aberta: as aulas passaram
a ser dadas pela equipe própria. Por isso `voluntarios.html` foi removida, o
botão principal do menu virou **Inscrever escola** e a escola passou a ser o
único caminho de conversão do site.

O caráter voluntário do projeto **não** mudou: a equipe atua sem remuneração,
nos termos da Lei 9.608/1998, então "projeto voluntário sem fins lucrativos", o
rodapé e a seção 3 dos Termos continuam valendo. O que saiu foi o recrutamento,
não o voluntariado.

A tabela `hf_voluntarios` continua no banco e no `schema.sql`, sem receber
escrita nenhuma. Está documentada como encerrada.

## O banco não pode dormir

O plano gratuito do Supabase pausa o projeto depois de alguns dias sem
atividade. Isso é pior do que parece: **enquanto pausado, o formulário das
escolas falha em silêncio**, e uma coordenadora que tentar se inscrever recebe
erro sem que ninguém do projeto fique sabendo.

Para evitar, existe `.github/workflows/manter-supabase-acordado.yml`, que chama
a função `public.ping()` toda segunda e quinta. É consulta de verdade ao
Postgres, que é o que zera o relógio de inatividade.

**Se você clonar isso para outro projeto, rode `supabase/keep-alive.sql` uma
vez no SQL Editor**, senão a tarefa falha com 404 e você recebe e-mail do
GitHub a cada execução.

Dois detalhes que valem saber:

A chave no arquivo do workflow é a **publicável**, a mesma que já está em
`assets/js/config.js` e visível para qualquer visitante. Por isso não usa
GitHub Secret: não é segredo. Quem protege os dados é o RLS.

O GitHub **desativa tarefas agendadas depois de 60 dias sem commit** no
repositório. Ele avisa por e-mail antes. Se o site ficar muito tempo parado, é
só reativar no painel do GitHub, em Actions.

## Publicar um artigo novo

O site não tem CMS nem editor visual, de propósito: é HTML estático, sem
build. Um artigo novo é sempre um arquivo novo. O fluxo combinado é: quem
escreve manda o texto pronto (Google Docs, Word, o que for) para quem
administra o site, que passa para uma sessão do Claude Code publicar. Não
existe painel onde o autor publica sozinho.

Passo a passo para quem estiver publicando:

1. **Crie o arquivo** em `artigos/<slug-do-titulo>.html`, por exemplo
   `artigos/como-funciona-o-cdb.html`. Slug em minúsculas, sem acento, hífen
   no lugar de espaço.

2. **Copie a estrutura de `termos.html` ou `privacidade.html`** como base: mesmo
   `<head>`, mesmo cabeçalho, mesmo rodapé, mesma `<div class="measure">` para
   o corpo do texto. Ajuste apenas:
   - `<title>`, `<meta name="description">`, `og:title`, `og:description`
   - `og:type` para `article` (já é o padrão de `sobre.html`)
   - `og:url` e `<link rel="canonical">` para
     `https://horizontefinanceiro.ong.br/artigos/<slug>.html`
   - O `<h1>` e o texto do artigo

3. **Inclua uma linha de autoria** logo abaixo do `<h1>`, dentro do
   `page-head`, no formato `<span class="meta">22 ago 2026 · por Fulano de
   Tal, analista de crédito</span>`. Data de publicação e uma linha curta de
   quem é o autor, sem precisar de foto nem bio longa.

4. **Termine o texto com o aviso de sempre**, o mesmo espírito do item 2 dos
   Termos de Uso: nada no artigo é recomendação de investimento. Um parágrafo
   simples antes do rodapé resolve, por exemplo: *"Este texto tem finalidade
   educacional e não é recomendação de investimento. Fale com um profissional
   antes de tomar qualquer decisão financeira."* Isso é inegociável, é a
   mesma regra que vale para as aulas.

5. **Adicione um card na listagem**, em `artigos.html`. A própria página tem
   um comentário HTML mostrando o modelo exato do card e onde ele entra.

6. **Adicione a URL ao `sitemap.xml`**, seguindo o padrão dos outros artigos
   já lá.

7. **Confira os links internos**: o card na listagem aponta para o artigo, e
   o artigo tem um link de volta para `artigos.html`.

Não é preciso mexer em `robots.txt` nem em `llms.txt` a cada artigo novo,
esses dois só precisam saber que a seção `/artigos.html` existe, o que já
está feito.

## 1. O banco, já conectado

Projeto Supabase `febhmuwmchfnmcnckpvj`, na organização `otomano3`, região
São Paulo. As tabelas e as políticas de RLS já foram criadas com
`supabase/schema.sql`, e as chaves já estão em `assets/js/config.js`.

Testado de ponta a ponta: os três formulários gravam, e a chave pública é
recusada (`401 / 42501`) ao tentar ler, alterar ou apagar qualquer uma das três
tabelas. O advisor de segurança do Supabase voltou sem alertas.

Se um dia precisar refazer isso em outro projeto: rode o `schema.sql` no
**SQL Editor**, pegue a **Project URL** e a **publishable key** em
**Project Settings → API**, e troque as duas linhas do `config.js`.

Essas duas chaves são públicas de propósito: qualquer visitante consegue vê-las
no navegador. Quem protege os dados é o RLS: com essa chave só é possível
**inserir** inscrições, nunca ler, editar ou apagar. **Nunca** coloque a
`service_role` key nesse arquivo.

Para ver as inscrições: Supabase → **Table Editor** → `hf_escolas` e
`hf_mensagens`. Dá para exportar CSV direto de lá.

## 2. Publicar na Vercel

Sem instalar nada, pelo site da Vercel:

1. Suba a pasta num repositório do GitHub.
2. vercel.com → **Add New → Project** → escolha o repositório.
3. Framework Preset: **Other**. Root Directory: a raiz. Sem build command.
4. **Deploy**.

Ou, pelo terminal:

```bash
npx vercel --prod
```

Cada `git push` na branch principal republica o site automaticamente.

## 3. Antes de mandar o link para alguém

- [ ] **Trocar os números da home quando houver histórico.** A seção "O
      combinado, em números" hoje descreve a *proposta* (4 aulas, 50 min, R$ 0,
      1 educador por turma) porque o projeto ainda não deu aula. Quando
      houver aulas dadas e alunos alcançados, troque por esses. Número de
      resultado convence mais que número de oferta. Não coloque métrica de
      resultado zerada ali.
- [ ] **Atualizar a contagem de escolas.** O parágrafo abaixo dos números diz
      "duas escolas públicas já confirmaram a parceria". Mude quando mudar.
- [ ] **Conferir o texto das 4 aulas** em `sobre.html`. Foi escrito a partir dos
      slides do projeto; ajuste para o que vocês realmente dão.
- [x] ~~Apagar as inscrições de voluntário da tabela `hf_voluntarios`~~ —
      feito pelo Thomas no SQL Editor em 2026-08-24, depois do encerramento do
      programa. A tabela continua existindo, vazia e sem receber escrita.
- [x] ~~Conectar o banco e testar os formulários~~
- [x] ~~Definir o e-mail de contato~~: `horizonte.financeiro.contato@gmail.com`
- [x] ~~Imagem de compartilhamento~~: `assets/img/og.png`, 1200×630

## Como editar o texto

Todo o conteúdo está direto no HTML, em português, sem template. Procure a
frase que quer mudar e mude. As cores ficam todas no topo de
`assets/css/style.css`, no bloco `:root`. Mudar `--gold` ali muda o site
inteiro.

Paleta oficial, do guia de identidade da marca:

| Cor | Hex | Papel |
|---|---|---|
| Azul profundo | `#0F2D44` | principal: cabeçalho, hero, seções escuras |
| Dourado | `#F5A623` | destaque: botões, réguas, o símbolo |
| Azul escuro | `#121A24` | secundária: rodapé, texto sobre fundo claro |
| Grafite | `#1E1E1E` | fundo: anel do badge |
| Cinza médio | `#8A9199` | texto secundário |
| Branco suave | `#F5F6F7` | texto principal sobre fundo escuro |

Três tons são derivados desses, só para dar contraste de leitura suficiente:
`--navy-soft` e `--navy-line` (cartões e bordas sobre o azul) e `--gold-ink`
(`#9C5C00`, o dourado escurecido para funcionar como texto sobre fundo claro, já que
o `#F5A623` puro só tem 2:1 sobre branco).

### Arquivos da logo

| Arquivo | Uso |
|---|---|
| `assets/img/logo-badge.svg` | marca completa: anel, disco azul e símbolo |
| `assets/img/logo-marca.svg` | símbolo isolado, em `currentColor` |
| `assets/img/logo.svg` | lockup horizontal com a assinatura |
| `favicon.svg` | disco sangrado, sem o anel (a 16px o anel virava ruído) |

**Importante:** essas quatro peças foram **redesenhadas em SVG a partir da
imagem do guia**, porque não havia arquivo vetorial da marca. As proporções
foram medidas na imagem, mas não são o original. Se aparecer o `.ai`, `.svg` ou
`.eps` do designer, troque, porque vetor original sempre ganha de redesenho.

No cabeçalho e no rodapé o símbolo está **embutido no HTML** (inline SVG), não
referenciado por `<img>`. Se mudar a forma da marca, mude nas sete páginas: são dois lugares
em cada uma.

## Notas de manutenção

### vercel.json

Duas coisas para não repetir erros já cometidos aqui:

**Não coloque comentário no arquivo.** A Vercel valida o `vercel.json` contra um
schema estrito e recusa qualquer propriedade fora dele, inclusive o truque de
usar uma chave `"//"` como comentário. O deploy falha com
*"should NOT have additional property"*. Explicação de decisão vai neste README.

**`cleanUrls` está `false` de propósito.** Com ele ligado, a Vercel responde 308
em `/sobre.html` redirecionando para `/sobre`, e como todos os links internos do
site usam `.html`, cada clique pagaria um salto extra. Desligado, o site se
comporta igual local e em produção. Se um dia quiser URL sem `.html`, ligue
`cleanUrls` **e** troque os `href` das sete páginas na mesma mudança. Meia
troca é o pior dos dois mundos.

- Os formulários validam no próprio JavaScript para as mensagens de erro saírem
  em português. Cada campo tem um `<p class="field__error">` onde a mensagem
  aparece.
- Há um campo escondido `_gotcha` em cada formulário: robô preenche, humano não.
  Se vier preenchido, o envio é descartado silenciosamente.
- O nome da tabela de destino de cada formulário está no atributo
  `data-tabela` da tag `<form>`. Se renomear tabela no banco, mude lá também.
