/* ==========================================================================
   Horizonte Financeiro: comportamento do site
   Sem dependências. Dois trabalhos: menu no celular e envio dos formulários
   para o Supabase via API REST.
   ========================================================================== */

(function () {
  "use strict";

  var CFG = window.HF_CONFIG || {};

  /* ---------- Menu no celular ------------------------------------------ */

  var toggle = document.querySelector(".nav-toggle");
  var nav = document.getElementById("nav-principal");

  if (toggle && nav) {
    toggle.addEventListener("click", function () {
      var aberto = nav.classList.toggle("is-open");
      toggle.setAttribute("aria-expanded", aberto ? "true" : "false");
    });

    // Fecha ao clicar num link (o menu cobre a tela no celular)
    nav.addEventListener("click", function (e) {
      if (e.target.tagName === "A") {
        nav.classList.remove("is-open");
        toggle.setAttribute("aria-expanded", "false");
      }
    });
  }

  /* ---------- Preenche canais de contato vindos do config -------------- */

  document.querySelectorAll("[data-hf-instagram]").forEach(function (el) {
    if (CFG.instagram) el.setAttribute("href", CFG.instagram);
  });
  document.querySelectorAll("[data-hf-email]").forEach(function (el) {
    if (CFG.email) {
      el.setAttribute("href", "mailto:" + CFG.email);
      if (el.dataset.hfEmail === "texto") el.textContent = CFG.email;
    }
  });

  /* ---------- Formulários ---------------------------------------------- */

  var EMAIL_RE = /^[^\s@]+@[^\s@]+\.[a-z]{2,}$/i;

  function configurado() {
    return (
      typeof CFG.supabaseUrl === "string" &&
      CFG.supabaseUrl.indexOf("http") === 0 &&
      typeof CFG.supabaseKey === "string" &&
      CFG.supabaseKey.length > 20
    );
  }

  function mostrarStatus(form, tipo, texto) {
    var box = form.querySelector(".form-status");
    if (!box) return;
    box.className = "form-status is-visible form-status--" + tipo;
    box.textContent = texto;
    if (tipo === "erro") box.setAttribute("role", "alert");
    else box.removeAttribute("role");
  }

  function limparErros(form) {
    form.querySelectorAll(".field__error").forEach(function (el) {
      el.textContent = "";
    });
    form.querySelectorAll("[aria-invalid]").forEach(function (el) {
      el.removeAttribute("aria-invalid");
    });
  }

  function marcarErro(campo, mensagem) {
    campo.setAttribute("aria-invalid", "true");
    var alvo = campo.closest(".field");
    var slot = alvo && alvo.querySelector(".field__error");
    if (slot) slot.textContent = mensagem;
  }

  // Validação própria para conseguir mensagens em português e um foco previsível
  function validar(form) {
    limparErros(form);
    var primeiroErro = null;

    form.querySelectorAll("input, select, textarea").forEach(function (campo) {
      if (campo.type === "hidden" || campo.name === "_gotcha") return;

      var valor = (campo.value || "").trim();

      if (campo.required && campo.type === "checkbox" && !campo.checked) {
        marcarErro(campo, "Precisamos do seu consentimento para continuar.");
        primeiroErro = primeiroErro || campo;
        return;
      }
      if (campo.required && campo.type !== "checkbox" && !valor) {
        marcarErro(campo, "Este campo é obrigatório.");
        primeiroErro = primeiroErro || campo;
        return;
      }
      if (campo.type === "email" && valor && !EMAIL_RE.test(valor)) {
        marcarErro(campo, "Confira o e-mail, parece estar incompleto.");
        primeiroErro = primeiroErro || campo;
      }
    });

    if (primeiroErro) {
      primeiroErro.focus();
      return false;
    }
    return true;
  }

  function montarPayload(form) {
    var dados = {};
    new FormData(form).forEach(function (valor, chave) {
      if (chave.charAt(0) === "_") return; // campos de controle
      if (typeof valor !== "string") return;
      var limpo = valor.trim();
      if (limpo) dados[chave] = limpo;
    });

    // Checkboxes marcados chegam como "on"; guardamos como booleano
    form.querySelectorAll('input[type="checkbox"][name]').forEach(function (cb) {
      if (cb.name.charAt(0) === "_") return;
      dados[cb.name] = cb.checked;
    });

    // Números precisam ir como número, não texto
    form.querySelectorAll('input[type="number"][name]').forEach(function (n) {
      var v = (n.value || "").trim();
      dados[n.name] = v ? Number(v) : null;
      if (dados[n.name] === null) delete dados[n.name];
    });

    return dados;
  }

  async function enviar(form) {
    var tabela = form.dataset.tabela;
    var botao = form.querySelector('button[type="submit"]');
    var textoOriginal = botao ? botao.textContent : "";

    if (botao) {
      botao.disabled = true;
      botao.textContent = "Enviando…";
    }
    mostrarStatus(form, "enviando", "Enviando sua inscrição…");

    try {
      var resposta = await fetch(
        CFG.supabaseUrl.replace(/\/+$/, "") + "/rest/v1/" + tabela,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            apikey: CFG.supabaseKey,
            Authorization: "Bearer " + CFG.supabaseKey,
            Prefer: "return=minimal",
          },
          body: JSON.stringify(montarPayload(form)),
        }
      );

      if (!resposta.ok) {
        var detalhe = await resposta.text();
        throw new Error("HTTP " + resposta.status + ": " + detalhe);
      }

      form.reset();
      mostrarStatus(
        form,
        "ok",
        form.dataset.sucesso ||
          "Inscrição recebida. A gente entra em contato em poucos dias."
      );
      if (botao) botao.textContent = textoOriginal;
    } catch (erro) {
      console.error("[Horizonte Financeiro] falha no envio:", erro);
      mostrarStatus(
        form,
        "erro",
        "Não conseguimos enviar agora. Tente de novo em alguns minutos ou fale com a gente no Instagram " +
          (CFG.instagramHandle || "") +
          "."
      );
      if (botao) botao.textContent = textoOriginal;
    } finally {
      if (botao) botao.disabled = false;
    }
  }

  document.querySelectorAll("form[data-tabela]").forEach(function (form) {
    form.setAttribute("novalidate", "novalidate");

    form.addEventListener("submit", function (e) {
      e.preventDefault();

      // Armadilha para robôs: campo escondido que humano nenhum preenche
      var isca = form.querySelector('input[name="_gotcha"]');
      if (isca && isca.value) {
        mostrarStatus(form, "ok", "Inscrição recebida.");
        return;
      }

      if (!validar(form)) {
        mostrarStatus(form, "erro", "Confira os campos destacados acima.");
        return;
      }

      if (!configurado()) {
        mostrarStatus(
          form,
          "erro",
          "O formulário ainda não está conectado ao banco. Preencha as chaves em assets/js/config.js."
        );
        return;
      }

      enviar(form);
    });
  });
})();
