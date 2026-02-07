const API_URL = "http://localhost:3000/api";

const statusOutput = document.getElementById("statusOutput");
const loginButton = document.getElementById("loginButton");

function updateStatus(message, isError = false) {
  statusOutput.innerHTML = `<p style="color: ${isError ? 'red' : 'green'}">${message}</p>`;
}

document.getElementById("loginForm").addEventListener("submit", async (e) => {
  e.preventDefault();

  const username = document.getElementById("username").value;
  const password = document.getElementById("password").value;

  try {
    loginButton.disabled = true;
    updateStatus("⏳ Logging in...");

    const response = await fetch(`${API_URL}/login`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username, password })
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error || "Login failed");
    }

    // Store user session
    sessionStorage.setItem("plasmaUser", JSON.stringify(data.user));
    sessionStorage.setItem("plasmaPrivateKey", data.privateKey);

    updateStatus("✅ Login successful! Redirecting...");

    // Redirect to dashboard
    setTimeout(() => {
      window.location.href = "dashboard.html";
    }, 1000);

  } catch (error) {
    console.error("❌ Login error:", error);
    updateStatus(`❌ ${error.message}`, true);
  } finally {
    loginButton.disabled = false;
  }
});
