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

app.get("/", (req, res) => {
  res.send(`
    <h1>Node.js Feedback App</h1>
    <a href="/add">Leave Feedback</a><br>
    <a href="/feedback">View Feedback</a>
  `);
});

app.get("/add", (req, res) => {
  res.send(`
    <h1>Leave Feedback</h1>
    <form method="post" action="/add">
      Name:<br><input name="name" required><br><br>
      Rating:<br>
      <select name="rating" required>
        <option value="">Select rating</option>
        <option value="1">1</option>
        <option value="2">2</option>
        <option value="3">3</option>
        <option value="4">4</option>
        <option value="5">5</option>
      </select><br><br>
      Comment:<br><textarea name="comment" required></textarea><br><br>
      <button type="submit">Submit</button>
    </form>
  `);
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
    let html = "<h1>Feedback Entries</h1><table border='1'><tr><th>ID</th><th>Name</th><th>Rating</th><th>Comment</th></tr>";

    rows.forEach((row) => {
      html += `<tr>
        <td>${row.id}</td>
        <td>${row.name}</td>
        <td>${row.rating}</td>
        <td>${row.comment}</td>
      </tr>`;
    });

    html += "</table><br><a href='/'>Home</a>";
    res.send(html);
  });
});

app.listen(5002, "0.0.0.0", () => {
  console.log("Node.js feedback app running on port 5002");
});
