require 'sinatra'
require 'sqlite3'
require 'webrick'

set :bind, '0.0.0.0'
set :port, 5004
set :server, 'webrick'

DB = SQLite3::Database.new "ruby_app.db"
DB.execute <<-SQL
  CREATE TABLE IF NOT EXISTS registrations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    email TEXT,
    event_name TEXT
  );
SQL

def page_template(title, content)
  "
  <!DOCTYPE html>
  <html lang='en'>
  <head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>#{title}</title>
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
      }
      .btn.secondary {
        background: #e2e8f0;
        color: #0f172a;
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
      input {
        width: 100%;
        padding: 14px;
        border: 1px solid #cbd5e1;
        border-radius: 10px;
        font-size: 1rem;
        background: #f8fafc;
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
    <div class='wrapper'>
      <div class='card'>
        #{content}
      </div>
    </div>
  </body>
  </html>
  "
end

get '/' do
  content = "
    <span class='badge'>Ruby + Sinatra + SQLite</span>
    <h1>Event Registration App</h1>
    <p>This app collects event registrations and stores each attendee's name, email, and event choice.</p>
    <div class='nav'>
      <a class='btn' href='/add'>Register for Event</a>
      <a class='btn secondary' href='/registrations'>View Registrations</a>
    </div>
  "
  page_template("Ruby Event App", content)
end

get '/add' do
  content = "
    <h1>Event Registration</h1>
    <p>Fill out the form below to register for an event.</p>
    <div class='nav'>
      <a class='btn secondary' href='/'>← Back Home</a>
      <a class='btn secondary' href='/registrations'>View Registrations</a>
    </div>
    <form method='post' action='/add'>
      <div>
        <label>Name</label>
        <input name='name' required placeholder='Enter full name'>
      </div>
      <div>
        <label>Email</label>
        <input name='email' type='email' required placeholder='Enter email address'>
      </div>
      <div>
        <label>Event Name</label>
        <input name='event_name' required placeholder='Enter event name'>
      </div>
      <button type='submit'>Register</button>
    </form>
  "
  page_template("Event Registration", content)
end

post '/add' do
  DB.execute(
    "INSERT INTO registrations (name, email, event_name) VALUES (?, ?, ?)",
    [params[:name], params[:email], params[:event_name]]
  )
  redirect '/registrations'
end

get '/registrations' do
  rows = DB.execute("SELECT * FROM registrations")
  rows_html = ""

  rows.each do |row|
    rows_html += "<tr><td>#{row[0]}</td><td>#{row[1]}</td><td>#{row[2]}</td><td>#{row[3]}</td></tr>"
  end

  if rows_html.empty?
    rows_html = "<tr><td colspan='4'>No registrations yet.</td></tr>"
  end

  content = "
    <h1>Registrations Dashboard</h1>
    <p>This page shows all saved event registrations.</p>
    <div class='nav'>
      <a class='btn secondary' href='/'>← Back Home</a>
      <a class='btn' href='/add'>Register Another Attendee</a>
    </div>
    <div class='table-wrap'>
      <table>
        <tr><th>ID</th><th>Name</th><th>Email</th><th>Event Name</th></tr>
        #{rows_html}
      </table>
    </div>
  "
  page_template("Registrations Dashboard", content)
end
