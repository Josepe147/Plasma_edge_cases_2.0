// Navigation bar component
// Auto-injects into pages

document.addEventListener('DOMContentLoaded', () => {
  const navHTML = `
    <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 10px 20px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
      <div style="display: flex; align-items: center; gap: 15px;">
        <button onclick="history.back()" style="background: rgba(255,255,255,0.2); color: white; border: none; padding: 8px 15px; border-radius: 4px; cursor: pointer; font-size: 16px;" title="Go Back">
          ← Back
        </button>
        <a href="/" style="color: white; text-decoration: none; font-weight: bold; font-size: 18px;">
          🏠 Home
        </a>
      </div>
      <div style="display: flex; gap: 10px;">
        <a href="/login.html" style="color: white; text-decoration: none; padding: 8px 15px; background: rgba(255,255,255,0.2); border-radius: 4px;">Login</a>
        <a href="/register.html" style="color: white; text-decoration: none; padding: 8px 15px; background: rgba(255,255,255,0.2); border-radius: 4px;">Register</a>
        <a href="/send.html" style="color: white; text-decoration: none; padding: 8px 15px; background: rgba(255,255,255,0.2); border-radius: 4px;">Send</a>
        <a href="/dashboard.html" style="color: white; text-decoration: none; padding: 8px 15px; background: rgba(255,255,255,0.2); border-radius: 4px;">Dashboard</a>
      </div>
    </div>
  `;

  // Insert nav at the top of body
  document.body.insertAdjacentHTML('afterbegin', navHTML);
});
