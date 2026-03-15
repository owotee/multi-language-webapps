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

def page_template(title, content):
    return f"""
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>{title}</title>
        <style>
            * {{
                box-sizing: border-box;
            }}

            body {{
                margin: 0;
                font-family: Arial, sans-serif;
                background: linear-gradient(135deg, #eef6ff, #f8fbff);
                color: #1f2937;
            }}

            .wrapper {{
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 24px;
            }}

            .card {{
                width: 100%;
                max-width: 900px;
                background: white;
                border-radius: 18px;
                padding: 32px;
                box-shadow: 0 12px 30px rgba(0, 0, 0, 0.08);
            }}

            h1 {{
                margin-top: 0;
                font-size: 2rem;
                color: #0f172a;
            }}

            p {{
                color: #475569;
                line-height: 1.6;
            }}

            .nav {{
                display: flex;
                flex-wrap: wrap;
                gap: 12px;
                margin-bottom: 24px;
            }}

            .btn, button {{
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
            }}

            .btn:hover, button:hover {{
                background: #1d4ed8;
            }}

            .btn.secondary {{
                background: #e2e8f0;
                color: #0f172a;
            }}

            .btn.secondary:hover {{
                background: #cbd5e1;
            }}

            form {{
                display: grid;
                gap: 16px;
                margin-top: 20px;
            }}

            label {{
                font-weight: bold;
                margin-bottom: 6px;
                display: block;
            }}

            input, textarea {{
                width: 100%;
                padding: 14px;
                border: 1px solid #cbd5e1;
                border-radius: 10px;
                font-size: 1rem;
                background: #f8fafc;
            }}

            input:focus, textarea:focus {{
                outline: none;
                border-color: #2563eb;
                background: white;
            }}

            textarea {{
                min-height: 140px;
                resize: vertical;
            }}

            .table-wrap {{
                overflow-x: auto;
                margin-top: 20px;
            }}

            table {{
                width: 100%;
                border-collapse: collapse;
                min-width: 600px;
            }}

            th, td {{
                padding: 14px;
                text-align: left;
                border-bottom: 1px solid #e2e8f0;
            }}

            th {{
                background: #eff6ff;
                color: #1e3a8a;
            }}

            tr:hover {{
                background: #f8fafc;
            }}

            .hero {{
                display: grid;
                gap: 16px;
            }}

            .badge {{
                display: inline-block;
                background: #dbeafe;
                color: #1d4ed8;
                padding: 6px 10px;
                border-radius: 999px;
                font-size: 0.85rem;
                font-weight: bold;
                width: fit-content;
            }}

            @media (max-width: 640px) {{
                .card {{
                    padding: 22px;
                    border-radius: 14px;
                }}

                h1 {{
                    font-size: 1.6rem;
                }}

                .btn, button {{
                    width: 100%;
                    text-align: center;
                }}

                .nav {{
                    flex-direction: column;
                }}
            }}
        </style>
    </head>
    <body>
        <div class="wrapper">
            <div class="card">
                {content}
            </div>
        </div>
    </body>
    </html>
    """

@app.route('/')
def home():
    content = """
    <div class="hero">
        <span class="badge">Python + Flask + SQLite</span>
        <h1>Contact Form App</h1>
        <p>
            This app collects contact form submissions, stores them in a SQLite database,
            and displays them in an admin-style entries page.
        </p>

        <div class="nav">
            <a class="btn" href="/add">Add Entry</a>
            <a class="btn secondary" href="/entries">View Entries</a>
        </div>
    </div>
    """
    return page_template("Python Contact Form", content)

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

    content = """
    <h1>Add Contact Entry</h1>
    <p>Fill out the form below to save a new contact record.</p>

    <div class="nav">
        <a class="btn secondary" href="/">← Back Home</a>
        <a class="btn secondary" href="/entries">View Entries</a>
    </div>

    <form method="post">
        <div>
            <label>Name</label>
            <input name="name" required placeholder="Enter full name">
        </div>

        <div>
            <label>Email</label>
            <input name="email" type="email" required placeholder="Enter email address">
        </div>

        <div>
            <label>Message</label>
            <textarea name="message" required placeholder="Write a message"></textarea>
        </div>

        <button type="submit">Save Entry</button>
    </form>
    """
    return page_template("Add Entry", content)

@app.route('/entries')
def entries():
    conn = sqlite3.connect(DB_NAME)
    cur = conn.cursor()
    cur.execute("SELECT * FROM entries")
    rows = cur.fetchall()
    conn.close()

    rows_html = ""
    for row in rows:
        rows_html += f"""
        <tr>
            <td>{row[0]}</td>
            <td>{row[1]}</td>
            <td>{row[2]}</td>
            <td>{row[3]}</td>
        </tr>
        """

    if not rows_html:
        rows_html = """
        <tr>
            <td colspan="4">No entries yet.</td>
        </tr>
        """

    content = f"""
    <h1>Submitted Entries</h1>
    <p>This page shows all contact form submissions stored in the database.</p>

    <div class="nav">
        <a class="btn secondary" href="/">← Back Home</a>
        <a class="btn" href="/add">Add Another Entry</a>
    </div>

    <div class="table-wrap">
        <table>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Email</th>
                <th>Message</th>
            </tr>
            {rows_html}
        </table>
    </div>
    """
    return page_template("Entries Dashboard", content)

if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5001)
