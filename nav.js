// nav.js — Plasma-style top bar (uses your real assets/)
(function () {
  const links = [
    { href: "send.html", label: "Send" },
    { href: "claim.html", label: "Claim" },
    { href: "dashboard.html", label: "Dashboard" },
  ];

  const current = (location.pathname.split("/").pop() || "index.html").toLowerCase();

  // Minimal “logged in” heuristic (works with your current app)
  const hasSession =
    !!sessionStorage.getItem("plasmaPrivateKey") ||
    !!sessionStorage.getItem("plasmaUser") ||
    !!localStorage.getItem("plasmaUserWallet");

  const header = document.createElement("header");
  header.className = "plasma-topbar";
  header.innerHTML = `
    <div class="plasma-topbar__inner">
      <a class="plasma-brand" href="index.html" aria-label="Plasma home">
        <img class="plasma-brand__logo" id="plasmaLogo" alt="Plasma" />
        <span class="plasma-brand__text" id="plasmaLogoText" style="display:none;">Plasma</span>
      </a>

      <nav class="plasma-nav" aria-label="Primary">
        ${links
          .map((l) => {
            const active = l.href.toLowerCase() === current ? "is-active" : "";
            return `<a class="plasma-nav__link ${active}" href="${l.href}">${l.label}</a>`;
          })
          .join("")}
      </nav>

      <div class="plasma-actions">
        <button class="plasma-iconbtn" type="button" aria-label="Language / region (placeholder)" title="Language / region">
          🌐
        </button>
        <a id="plasmaCta" class="plasma-cta" href="${hasSession ? "dashboard.html" : "login.html"}">
          Go to Dashboard →
        </a>
      </div>
    </div>
  `;

  document.body.prepend(header);

  // Try your real logo files in order
  const logoCandidates = [
    "assets/Logo_horizontal_dark.svg",
    "assets/Logo_horizontal_light.svg",
    "assets/Logo_boxed_dark.svg",
    "assets/Logo_symbol_dark.svg",
    "assets/Logo_symbol_light.svg",
  ];

  const img = document.getElementById("plasmaLogo");
  const fallbackText = document.getElementById("plasmaLogoText");

  let i = 0;
  function tryNext() {
    if (i >= logoCandidates.length) {
      img.style.display = "none";
      fallbackText.style.display = "inline-block";
      return;
    }
    img.src = logoCandidates[i++];
  }

  img.onerror = tryNext;
  tryNext();
})();
