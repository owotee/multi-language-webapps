<?php
$db = new SQLite3('php_app.db');

$db->exec("CREATE TABLE IF NOT EXISTS signups (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    email TEXT,
    interest TEXT
)");

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

    echo "<h1>Newsletter Signups</h1>";
    echo "<table border='1' cellpadding='8'>";
    echo "<tr><th>ID</th><th>Name</th><th>Email</th><th>Interest</th></tr>";

    while ($row = $results->fetchArray(SQLITE3_ASSOC)) {
        echo "<tr>";
        echo "<td>" . $row['id'] . "</td>";
        echo "<td>" . $row['name'] . "</td>";
        echo "<td>" . $row['email'] . "</td>";
        echo "<td>" . $row['interest'] . "</td>";
        echo "</tr>";
    }

    echo "</table><br>";
    echo "<a href='?page=home'>Home</a>";
    exit;
}

if ($page === 'add') {
    echo "
    <h1>Newsletter Signup</h1>
    <form method='post' action='?page=save'>
        Name:<br><input name='name' required><br><br>
        Email:<br><input name='email' type='email' required><br><br>
        Interest:<br><input name='interest' required><br><br>
        <button type='submit'>Sign Up</button>
    </form>
    <br><a href='?page=home'>Home</a>
    ";
    exit;
}

echo "
<h1>PHP Newsletter App</h1>
<a href='?page=add'>Sign Up</a><br>
<a href='?page=list'>View Signups</a>
";
?>
