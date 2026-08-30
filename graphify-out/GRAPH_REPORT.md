# Graph Report - horizonte-financeiro  (2026-08-25)

## Corpus Check
- Corpus is ~12,137 words - fits in a single context window. You may not need a graph.

## Summary
- 52 nodes · 108 edges · 15 communities (8 shown, 7 thin omitted)
- Extraction: 95% EXTRACTED · 5% INFERRED · 0% AMBIGUOUS · INFERRED: 5 edges (avg confidence: 0.77)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Páginas do Site & Identidade
- Lógica do Formulário (JS)
- README & Schema do Banco
- Configuração do Vercel
- Privacidade & Conformidade LGPD
- Imagem Open Graph
- Voluntariado & Legislação
- Gotchas do vercel.json
- Segurança Anti-Spam & RLS
- SEO: Sitemap & Robots
- Logo Badge
- Logo Principal
- Símbolo da Marca
- Favicon

## God Nodes (most connected - your core abstractions)
1. `contato.html (Contato)` - 14 edges
2. `escolas.html (Para escolas)` - 13 edges
3. `privacidade.html (Política de Privacidade)` - 12 edges
4. `sobre.html (O projeto)` - 11 edges
5. `termos.html (Termos de Uso)` - 11 edges
6. `index.html (Início)` - 10 edges
7. `Horizonte Financeiro (projeto)` - 9 edges
8. `artigos.html (Artigos)` - 7 edges
9. `Google Fonts` - 7 edges
10. `Conteúdo educacional, não é recomendação de investimento` - 5 edges

## Surprising Connections (you probably didn't know these)
- `escolas.html (Para escolas)` --shares_data_with--> `tabela hf_escolas`  [EXTRACTED]
  escolas.html → README.md
- `contato.html (Contato)` --shares_data_with--> `tabela hf_mensagens`  [EXTRACTED]
  contato.html → README.md
- `index.html (Início)` --references--> `privacidade.html (Política de Privacidade)`  [EXTRACTED]
  index.html → privacidade.html
- `sobre.html (O projeto)` --references--> `privacidade.html (Política de Privacidade)`  [EXTRACTED]
  sobre.html → privacidade.html
- `escolas.html (Para escolas)` --references--> `Campo honeypot _gotcha anti-spam`  [EXTRACTED]
  escolas.html → README.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Padrão comum de página (header/nav/footer + Google Fonts) nas 7 páginas do site** — index, sobre, escolas, contato, artigos, privacidade, termos [INFERRED 0.85]
- **Tabelas do schema Supabase do projeto (hf_escolas, hf_mensagens, hf_voluntarios)** — concept_supabase, concept_hf_escolas, concept_hf_mensagens, concept_hf_voluntarios [INFERRED 0.85]
- **Formulários que implementam o campo honeypot anti-spam** — escolas, contato, concept_honeypot [INFERRED 0.75]

## Communities (15 total, 7 thin omitted)

### Community 0 - "Páginas do Site & Identidade"
Cohesion: 0.62
Nodes (11): artigos.html (Artigos), BNCC — educação financeira como tema transversal, Google Fonts, Horizonte Financeiro (projeto), @horizonte.financeiro_ (Instagram), Conteúdo educacional, não é recomendação de investimento, contato.html (Contato), escolas.html (Para escolas) (+3 more)

### Community 1 - "Lógica do Formulário (JS)"
Cohesion: 0.39
Nodes (6): enviar(), limparErros(), marcarErro(), montarPayload(), mostrarStatus(), validar()

### Community 2 - "README & Schema do Banco"
Cohesion: 0.33
Nodes (5): Paleta oficial de cores da marca, horizonte.financeiro.contato@gmail.com, tabela hf_escolas, tabela hf_mensagens, Site estático sem CMS/build

### Community 3 - "Configuração do Vercel"
Cohesion: 0.40
Nodes (4): cleanUrls, headers, $schema, trailingSlash

### Community 4 - "Privacidade & Conformidade LGPD"
Cohesion: 0.50
Nodes (4): LGPD (Lei Geral de Proteção de Dados), Supabase (projeto febhmuwmchfnmcnckpvj), Vercel (hospedagem/deploy), privacidade.html (Política de Privacidade)

### Community 5 - "Imagem Open Graph"
Cohesion: 1.00
Nodes (3): Educação Financeira em Escolas Públicas, Horizonte Financeiro, Open Graph Preview Image

### Community 6 - "Voluntariado & Legislação"
Cohesion: 0.67
Nodes (3): tabela hf_voluntarios (encerrada), Lei 9.608/1998 (trabalho voluntário), Mudança de modelo (ago/2026): fim do recrutamento de voluntário

## Knowledge Gaps
- **10 isolated node(s):** `$schema`, `cleanUrls`, `trailingSlash`, `headers`, `LGPD (Lei Geral de Proteção de Dados)` (+5 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **7 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `privacidade.html (Política de Privacidade)` connect `Privacidade & Conformidade LGPD` to `Páginas do Site & Identidade`, `README & Schema do Banco`?**
  _High betweenness centrality (0.035) - this node is a cross-community bridge._
- **Why does `escolas.html (Para escolas)` connect `Páginas do Site & Identidade` to `Segurança Anti-Spam & RLS`, `README & Schema do Banco`, `Privacidade & Conformidade LGPD`?**
  _High betweenness centrality (0.023) - this node is a cross-community bridge._
- **Why does `contato.html (Contato)` connect `Páginas do Site & Identidade` to `Segurança Anti-Spam & RLS`, `README & Schema do Banco`, `Privacidade & Conformidade LGPD`?**
  _High betweenness centrality (0.022) - this node is a cross-community bridge._
- **What connects `$schema`, `cleanUrls`, `trailingSlash` to the rest of the system?**
  _10 weakly-connected nodes found - possible documentation gaps or missing edges._