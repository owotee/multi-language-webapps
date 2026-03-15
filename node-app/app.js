const express = require("express");
const sqlite3 = require("sqlite3").verbose();
const bodyParser = require("body-parser");

const app = express();
const db = new sqlite3.Database("node_app.db");

app.use(bodyParser.urlencoded({ extended: true }));

db.serialize(() => {
  db.run(`
    CREATE TABLE IF NOT EXISTS feedback (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      rating TEXT,
      comment TEXT
    )
  `);
});

function pageTemplate(title, content) {
  return `
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>${title}</title>
    <style>
      * { box-sizing: border-box; }
      body {
        margin: 0;
        font-family: Arial, sans-serif;
        background: linear-gradient(135deg, #eef6ff, #f8fbff);
        color: #1f2937;
      }
      .wrapper {
        min-height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 24px;
      }
      .card {
        width: 100%;
        max-width: 900px;
        background: white;
        border-radius: 18px;
        padding: 32px;
        box-shadow: 0 12px 30px rgba(0,0,0,0.08);
      }
      h1 {
        margin-top: 0;
        font-size: 2rem;
        color: #0f172a;
      }
      p {
        color: #475569;
        line-height: 1.6;
      }
      .nav {
        display: flex;
        flex-wrap: wrap;
        gap: 12px;
        margin-bottom: 24px;
      }
      .btn, button {
        display: inline-block;
        background: #2563eb;
        color: white;
        text-decoration: none;
        border: none;
        border-radius: 10px;
        padding: 12px 18px;
        font-size: 0.95rem;
        cursor: pointer;
        transition: 0.2s ease;
      }
      .btn:hover, button:hover {
        background: #1d4ed8;
      }
      .btn.secondary {
        background: #e2e8f0;
        color: #0f172a;
      }
      .btn.secondary:hover {
        background: #cbd5e1;
      }
      form {
        display: grid;
        gap: 16px;
        margin-top: 20px;
      }
      label {
        font-weight: bold;
        margin-bottom: 6px;
        display: block;
      }
      input, textarea, select {
        width: 100%;
        padding: 14px;
        border: 1px solid #cbd5e1;
        border-radius: 10px;
        font-size: 1rem;
        background: #f8fafc;
      }
      input:focus, textarea:focus, select:focus {
        outline: none;
        border-color: #2563eb;
        background: white;
      }
      textarea {
        min-height: 140px;
        resize: vertical;
      }
      .table-wrap {
        overflow-x: auto;
        margin-top: 20px;
      }
      table {
        width: 100%;
        border-collapse: collapse;
        min-width: 600px;
      }
      th, td {
        padding: 14px;
        text-align: left;
        border-bottom: 1px solid #e2e8f0;
      }
      th {
        background: #eff6ff;
        color: #1e3a8a;
      }
      tr:hover {
        background: #f8fafc;
      }
      .badge {
        display: inline-block;
        background: #dbeafe;
        color: #1d4ed8;
        padding: 6px 10px;
        border-radius: 999px;
        font-size: 0.85rem;
        font-weight: bold;
        width: fit-content;
      }
      @media (max-width: 640px) {
        .card {
          padding: 22px;
          border-radius: 14px;
        }
        h1 {
          font-size: 1.6rem;
        }
        .btn, button {
          width: 100%;
          text-align: center;
        }
        .nav {
          flex-direction: column;
        }
      }
    </style>
  </head>
  <body>
    <div class="wrapper">
      <div class="card">
        ${content}
      </div>
    </div>
  </body>
  </html>
  `;
}

app.get("/", (req, res) => {
  const content = `
    <span class="badge">Node.js + Express + SQLite</span>
    <h1>Feedback Form App</h1>
    <p>This app collects user feedback, stores ratings and comments, and displays them in a simple dashboard.</p>
    <div class="nav">
      <a class="btn" href="/add">Leave Feedback</a>
      <a class="btn secondary" href="/feedback">View Feedback</a>
    </div>
  `;
  res.send(pageTemplate("Node Feedback App", content));
});

app.get("/add", (req, res) => {
  const content = `
    <h1>Leave Feedback</h1>
    <p>Submit your rating and comment below.</p>
    <div class="nav">
      <a class="btn secondary" href="/">← Back Home</a>
      <a class="btn secondary" href="/feedback">View Feedback</a>
    </div>
    <form method="post" action="/add">
      <div>
        <label>Name</label>
        <input name="name" required placeholder="Enter full name">
      </div>
      <div>
        <label>Rating</label>
        <select name="rating" required>
          <option value="">Select rating</option>
          <option value="1">1 - Poor</option>
          <option value="2">2 - Fair</option>
          <option value="3">3 - Good</option>
          <option value="4">4 - Very Good</option>
          <option value="5">5 - Excellent</option>
        </select>
      </div>
      <div>
        <label>Comment</label>
        <textarea name="comment" required placeholder="Write your feedback"></textarea>
      </div>
      <button type="submit">Submit Feedback</button>
    </form>
  `;
  res.send(pageTemplate("Leave Feedback", content));
});

app.post("/add", (req, res) => {
  const { name, rating, comment } = req.body;
  db.run(
    "INSERT INTO feedback (name, rating, comment) VALUES (?, ?, ?)",
    [name, rating, comment],
    () => res.redirect("/feedback")
  );
});

app.get("/feedback", (req, res) => {
  db.all("SELECT * FROM feedback", [], (err, rows) => {
    let rowsHtml = "";

    rows.forEach((row) => {
      rowsHtml += `
        <tr>
          <td>${row.id}</td>
          <td>${row.name}</td>
          <td>${row.rating}</td>
          <td>${row.comment}</td>
        </tr>
      `;
    });

    if (!rowsHtml) {
      rowsHtml = `<tr><td colspan="4">No feedback submitted yet.</td></tr>`;
    }

    const content = `
      <h1>Feedback Dashboard</h1>
      <p>This page shows all submitted feedback records.</p>
      <div class="nav">
        <a class="btn secondary" href="/">← Back Home</a>
        <a class="btn" href="/add">Leave Another Feedback</a>
      </div>
      <div class="table-wrap">
        <table>
          <tr><th>ID</th><th>Name</th><th>Rating</th><th>Comment</th></tr>
          ${rowsHtml}
        </table>
      </div>
    `;

    res.send(pageTemplate("Feedback Dashboard", content));
  });
});

app.listen(5002, "0.0.0.0", () => {
  console.log("Node.js feedback app running on port 5002");
});
