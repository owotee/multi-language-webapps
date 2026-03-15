<?php
$db = new SQLite3('php_app.db');

$db->exec("CREATE TABLE IF NOT EXISTS signups (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    email TEXT,
    interest TEXT
)");

function pageTemplate($title, $content) {
    return "
    <!DOCTYPE html>
    <html lang='en'>
    <head>
        <meta charset='UTF-8'>
        <meta name='viewport' content='width=device-width, initial-scale=1.0'>
        <title>$title</title>
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
                $content
            </div>
        </div>
    </body>
    </html>
    ";
}

$page = $_GET['page'] ?? 'home';

if ($page === 'save' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $stmt = $db->prepare("INSERT INTO signups (name, email, interest) VALUES (:name, :email, :interest)");
    $stmt->bindValue(':name', $_POST['name'], SQLITE3_TEXT);
    $stmt->bindValue(':email', $_POST['email'], SQLITE3_TEXT);
    $stmt->bindValue(':interest', $_POST['interest'], SQLITE3_TEXT);
    $stmt->execute();

    header("Location: ?page=list");
    exit;
}

if ($page === 'list') {
    $results = $db->query("SELECT * FROM signups");
    $rows = "";

    while ($row = $results->fetchArray(SQLITE3_ASSOC)) {
        $rows .= "<tr>";
        $rows .= "<td>{$row['id']}</td>";
        $rows .= "<td>{$row['name']}</td>";
        $rows .= "<td>{$row['email']}</td>";
        $rows .= "<td>{$row['interest']}</td>";
        $rows .= "</tr>";
    }

    if ($rows === "") {
        $rows = "<tr><td colspan='4'>No signups yet.</td></tr>";
    }

    $content = "
        <h1>Newsletter Dashboard</h1>
        <p>This page shows all newsletter signup submissions.</p>
        <div class='nav'>
            <a class='btn secondary' href='?page=home'>← Back Home</a>
            <a class='btn' href='?page=add'>Add Signup</a>
        </div>
        <div class='table-wrap'>
            <table>
                <tr><th>ID</th><th>Name</th><th>Email</th><th>Interest</th></tr>
                $rows
            </table>
        </div>
    ";

    echo pageTemplate("Newsletter Dashboard", $content);
    exit;
}

if ($page === 'add') {
    $content = "
        <h1>Newsletter Signup</h1>
        <p>Join the newsletter by entering your details below.</p>
        <div class='nav'>
            <a class='btn secondary' href='?page=home'>← Back Home</a>
            <a class='btn secondary' href='?page=list'>View Signups</a>
        </div>
        <form method='post' action='?page=save'>
            <div>
                <label>Name</label>
                <input name='name' required placeholder='Enter full name'>
            </div>
            <div>
                <label>Email</label>
                <input name='email' type='email' required placeholder='Enter email address'>
            </div>
            <div>
                <label>Interest</label>
                <input name='interest' required placeholder='Example: Web Development'>
            </div>
            <button type='submit'>Sign Up</button>
        </form>
    ";

    echo pageTemplate("Newsletter Signup", $content);
    exit;
}

$content = "
    <span class='badge'>PHP + SQLite</span>
    <h1>Newsletter Signup App</h1>
    <p>This app stores newsletter subscriptions with each person's interest area.</p>
    <div class='nav'>
        <a class='btn' href='?page=add'>Sign Up</a>
        <a class='btn secondary' href='?page=list'>View Signups</a>
    </div>
";

echo pageTemplate("PHP Newsletter App", $content);
?>
