/* ==========================================================================
   Configuração pública do site.
   Estas duas chaves são PÚBLICAS por natureza: elas ficam visíveis no
   navegador de qualquer visitante. A segurança de verdade está nas políticas
   de RLS do banco (ver supabase/schema.sql): com esta chave só é possível
   INSERIR inscrições, nunca ler, editar ou apagar o que já está lá.

   NUNCA coloque aqui a service_role key do Supabase.
   ========================================================================== */

window.HF_CONFIG = {
  supabaseUrl: "https://febhmuwmchfnmcnckpvj.supabase.co",
  supabaseKey: "sb_publishable_qz9EYZBELY3OfuCUxc9vUA_ANwP-OoK",

  // Canais de contato usados nos botões e no rodapé
  instagram: "https://instagram.com/horizonte.financeiro_",
  instagramHandle: "@horizonte.financeiro_",
  email: "horizonte.financeiro.contato@gmail.com",
};
