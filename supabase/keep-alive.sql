-- ============================================================================
-- Função de keep-alive
--
-- Rodar UMA vez no SQL Editor do Supabase.
--
-- Por que existe: o plano gratuito pausa o projeto depois de alguns dias sem
-- atividade, e enquanto pausado o formulário das escolas falha em silêncio.
-- A tarefa .github/workflows/manter-supabase-acordado.yml chama esta função
-- duas vezes por semana para o relógio de inatividade nunca fechar.
--
-- Por que uma função, e não só bater na API: requisição recusada pelo RLS
-- pode ser barrada no gateway antes de tocar o Postgres, então não serve como
-- sinal de atividade. E inserir linha de mentira toda semana sujaria o banco.
-- Chamar esta função é consulta de verdade e não escreve nada.
--
-- Segurança: devolve só a hora do servidor. Não lê tabela, não aceita
-- parâmetro e não expõe dado nenhum.
-- ============================================================================

create or replace function public.ping()
returns timestamptz
language sql
stable
as $$ select now() $$;

comment on function public.ping() is
  'Keep-alive: chamada pela tarefa agendada do GitHub para o projeto não pausar por inatividade. Não lê nem escreve dado.';

grant execute on function public.ping() to anon, authenticated;
