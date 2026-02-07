// register.js
const API_URL = "http://localhost:3000/api";

const statusOutput = document.createElement("div");
statusOutput.id = "statusOutput";
statusOutput.style.marginTop = "20px";
document.getElementById("registerForm").parentElement.appendChild(statusOutput);

function updateStatus(message, isError = false) {
  statusOutput.innerHTML = `<p style="color: ${isError ? 'red' : 'green'}">${message}</p>`;
}

document.getElementById("registerForm").addEventListener("submit", async (e) => {
  e.preventDefault();

  const forename = document.getElementById("forename").value;
  const surname = document.getElementById("surname").value;
  const username = document.getElementById("username").value;
  const password = document.getElementById("password").value;
  const email = document.getElementById("email")?.value || "";

  try {
    const submitButton = e.target.querySelector('button[type="submit"]');
    submitButton.disabled = true;
    updateStatus("⏳ Creating account and generating wallet...");

    const response = await fetch(`${API_URL}/register`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        username,
        password,
        forename,
        surname,
        email
      })
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error || "Registration failed");
    }

    updateStatus("✅ Account created! Wallet generated. Logging you in...");

    // Auto-login after registration
    const loginResponse = await fetch(`${API_URL}/login`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username, password })
    });

    const loginData = await loginResponse.json();

    if (loginResponse.ok) {
      // Store user session
      sessionStorage.setItem("plasmaUser", JSON.stringify(loginData.user));
      sessionStorage.setItem("plasmaPrivateKey", loginData.privateKey);

      updateStatus("✅ Success! Redirecting to dashboard...");

      setTimeout(() => {
        window.location.href = "dashboard.html";
      }, 1500);
    }

  } catch (error) {
    console.error("❌ Registration error:", error);
    updateStatus(`❌ ${error.message}`, true);
    e.target.querySelector('button[type="submit"]').disabled = false;
  }
});
