from flask import Flask, request, redirect
import sqlite3

app = Flask(__name__)
DB_NAME = "python_app.db"

def init_db():
    conn = sqlite3.connect(DB_NAME)
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT,
            message TEXT
        )
    """)
    conn.commit()
    conn.close()

@app.route('/')
def home():
    return '''
    <h1>Python App</h1>
    <a href="/add">Add Entry</a><br>
    <a href="/entries">View Entries</a>
    '''

@app.route('/add', methods=['GET', 'POST'])
def add():
    if request.method == 'POST':
        name = request.form['name']
        email = request.form['email']
        message = request.form['message']

        conn = sqlite3.connect(DB_NAME)
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO entries (name, email, message) VALUES (?, ?, ?)",
            (name, email, message)
        )
        conn.commit()
        conn.close()
        return redirect('/entries')

    return '''
    <h1>Add Entry</h1>
    <form method="post">
        Name:<br><input name="name" required><br><br>
        Email:<br><input name="email" type="email" required><br><br>
        Message:<br><textarea name="message" required></textarea><br><br>
        <button type="submit">Save</button>
    </form>
    '''

@app.route('/entries')
def entries():
    conn = sqlite3.connect(DB_NAME)
    cur = conn.cursor()
    cur.execute("SELECT * FROM entries")
    rows = cur.fetchall()
    conn.close()

    html = """
    <html>
    <head>
        <title>Python Admin Dashboard</title>
        <style>
            body { font-family: Arial, sans-serif; background:#f4f8fb; padding:40px; }
            .container { max-width: 1000px; margin:auto; background:white; padding:30px; border-radius:12px; box-shadow:0 8px 24px rgba(0,0,0,0.08); }
            h1 { color:#2c3e50; }
            a { color:#0077cc; text-decoration:none; font-weight:bold; }
            table { width:100%; border-collapse:collapse; margin-top:20px; }
            th, td { border:1px solid #ddd; padding:12px; text-align:left; }
            th { background:#0077cc; color:white; }
            tr:nth-child(even) { background:#f9f9f9; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Python Contact Form Admin Dashboard</h1>
            <a href="/">← Back Home</a>
            <table>
                <tr><th>ID</th><th>Name</th><th>Email</th><th>Message</th></tr>
    """

    for row in rows:
        html += f"<tr><td>{row[0]}</td><td>{row[1]}</td><td>{row[2]}</td><td>{row[3]}</td></tr>"

    html += """
            </table>
        </div>
    </body>
    </html>
    """
    return html

if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5001)
