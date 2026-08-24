-- ============================================================================
-- Horizonte Financeiro: estrutura do banco
--
-- Como usar:
--   Supabase → SQL Editor → cole este arquivo inteiro → Run.
--
-- Ideia central de segurança: o site é estático, então a chave que fica no
-- navegador (publishable / anon) é pública. As políticas abaixo garantem que,
-- com essa chave, só dá para INSERIR. Ler, editar e apagar as inscrições fica
-- restrito a quem está logado no painel do Supabase (service_role).
--
-- Se um dia você mudar o site para um projeto Supabase próprio, rode este mesmo
-- arquivo lá e troque as duas linhas de assets/js/config.js. Nada mais muda.
--
-- Sobre o prefixo hf_: existe para as tabelas do Horizonte Financeiro poderem
-- conviver no mesmo banco de outro projeto sem confusão. Num projeto Supabase
-- exclusivo do Horizonte, o prefixo pode cair, mas aí lembre de ajustar o
-- atributo data-tabela dos <form> nas páginas escolas/contato.
-- ============================================================================


-- ---------------------------------------------------------------- voluntários
--
-- PROGRAMA ENCERRADO em agosto de 2026. O Horizonte passou a dar aula com
-- equipe própria e fechou a inscrição aberta de voluntário, então
-- voluntarios.html saiu do site e nada mais escreve nesta tabela.
--
-- O create continua aqui por ser idempotente e para o histórico do schema
-- ficar legível. Se for reabrir inscrição algum dia, a estrutura já existe.
-- Se decidir apagar de vez, lembre de remover também as políticas de RLS e
-- os índices logo abaixo.

create table if not exists public.hf_voluntarios (
  id              uuid primary key default gen_random_uuid(),
  criado_em       timestamptz not null default now(),

  nome            text not null check (char_length(nome) between 2 and 120),
  email           text not null check (email ~* '^[^@\s]+@[^@\s]+\.[a-z]{2,}$'),
  telefone        text check (char_length(telefone) <= 30),
  cidade          text not null check (char_length(cidade) between 2 and 80),
  estado          text not null check (char_length(estado) = 2),

  area            text not null check (char_length(area) <= 60),
  cargo           text check (char_length(cargo) <= 100),
  empresa         text check (char_length(empresa) <= 120),
  disponibilidade text not null check (char_length(disponibilidade) <= 40),
  formato         text not null check (char_length(formato) <= 20),
  experiencia     text check (char_length(experiencia) <= 30),
  linkedin        text check (char_length(linkedin) <= 200),
  mensagem        text check (char_length(mensagem) <= 1500),

  consentimento   boolean not null default false check (consentimento),

  -- controle interno, editado por você no painel
  situacao        text not null default 'novo'
                    check (situacao in ('novo', 'em contato', 'treinado', 'ativo', 'inativo')),
  anotacoes       text
);

comment on table public.hf_voluntarios is
  'Inscrições de voluntários vindas do site (voluntarios.html).';


-- -------------------------------------------------------------------- escolas

create table if not exists public.hf_escolas (
  id               uuid primary key default gen_random_uuid(),
  criado_em        timestamptz not null default now(),

  nome_escola      text not null check (char_length(nome_escola) between 2 and 160),
  rede             text not null check (char_length(rede) <= 30),
  etapa            text not null check (char_length(etapa) <= 40),
  cidade           text not null check (char_length(cidade) between 2 and 80),
  estado           text not null check (char_length(estado) = 2),
  turmas           integer check (turmas between 1 and 200),
  alunos_por_turma integer check (alunos_por_turma between 1 and 200),
  periodo          text not null check (char_length(periodo) <= 20),
  formato          text not null check (char_length(formato) <= 20),

  nome_contato     text not null check (char_length(nome_contato) between 2 and 120),
  cargo            text not null check (char_length(cargo) <= 40),
  email            text not null check (email ~* '^[^@\s]+@[^@\s]+\.[a-z]{2,}$'),
  telefone         text not null check (char_length(telefone) <= 30),
  mensagem         text check (char_length(mensagem) <= 1500),

  consentimento    boolean not null default false check (consentimento),

  situacao         text not null default 'novo'
                     check (situacao in ('novo', 'em contato', 'agendada', 'ativa', 'encerrada')),
  anotacoes        text
);

comment on table public.hf_escolas is
  'Inscrições de escolas vindas do site (escolas.html).';


-- ------------------------------------------------------------------ mensagens

create table if not exists public.hf_mensagens (
  id         uuid primary key default gen_random_uuid(),
  criado_em  timestamptz not null default now(),

  nome       text not null check (char_length(nome) between 2 and 120),
  email      text not null check (email ~* '^[^@\s]+@[^@\s]+\.[a-z]{2,}$'),
  assunto    text not null check (char_length(assunto) <= 60),
  mensagem   text not null check (char_length(mensagem) between 5 and 3000),

  respondida boolean not null default false
);

comment on table public.hf_mensagens is
  'Mensagens do formulário de contato (contato.html).';


-- ------------------------------------------------------------------- índices

create index if not exists hf_voluntarios_criado_em_idx on public.hf_voluntarios (criado_em desc);
create index if not exists hf_voluntarios_estado_idx    on public.hf_voluntarios (estado, cidade);
create index if not exists hf_escolas_criado_em_idx     on public.hf_escolas (criado_em desc);
create index if not exists hf_escolas_estado_idx        on public.hf_escolas (estado, cidade);
create index if not exists hf_mensagens_criado_em_idx   on public.hf_mensagens (criado_em desc);


-- ------------------------------------------------------- RLS: só pode inserir

alter table public.hf_voluntarios enable row level security;
alter table public.hf_escolas     enable row level security;
alter table public.hf_mensagens   enable row level security;

-- Recria as políticas de forma idempotente (dá para rodar o arquivo de novo)
drop policy if exists "site pode inscrever voluntario" on public.hf_voluntarios;
drop policy if exists "site pode inscrever escola"     on public.hf_escolas;
drop policy if exists "site pode enviar mensagem"      on public.hf_mensagens;

create policy "site pode inscrever voluntario"
  on public.hf_voluntarios for insert to anon, authenticated with check (true);

create policy "site pode inscrever escola"
  on public.hf_escolas for insert to anon, authenticated with check (true);

create policy "site pode enviar mensagem"
  on public.hf_mensagens for insert to anon, authenticated with check (true);

-- Nenhuma política de select/update/delete: com a chave pública do site é
-- impossível ler, alterar ou apagar qualquer inscrição. Você vê tudo pelo
-- Table Editor do Supabase, que usa uma chave privilegiada.

-- Garante que a chave pública não consiga espiar as colunas por outros meios
revoke select, update, delete on public.hf_voluntarios from anon;
revoke select, update, delete on public.hf_escolas     from anon;
revoke select, update, delete on public.hf_mensagens   from anon;
