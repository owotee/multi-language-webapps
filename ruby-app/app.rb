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

get '/' do
  '
  <h1>Ruby Event Registration App</h1>
  <a href="/add">Register for Event</a><br>
  <a href="/registrations">View Registrations</a>
  '
end

get '/add' do
  '
  <h1>Event Registration</h1>
  <form method="post" action="/add">
    Name:<br><input name="name" required><br><br>
    Email:<br><input name="email" type="email" required><br><br>
    Event Name:<br><input name="event_name" required><br><br>
    <button type="submit">Register</button>
  </form>
  <br><a href="/">Home</a>
  '
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
  html = "<h1>Event Registrations</h1><table border='1' cellpadding='8'><tr><th>ID</th><th>Name</th><th>Email</th><th>Event Name</th></tr>"

  rows.each do |row|
    html += "<tr><td>#{row[0]}</td><td>#{row[1]}</td><td>#{row[2]}</td><td>#{row[3]}</td></tr>"
  end

  html += "</table><br><a href='/'>Home</a>"
  html
end
