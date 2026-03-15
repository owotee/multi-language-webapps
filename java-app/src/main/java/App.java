import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

import static spark.Spark.*;

public class App {
    public static void main(String[] args) {
        port(5005);

        initDatabase();

        get("/", (req, res) ->
            "<h1>Java Job Inquiry App</h1>" +
            "<a href='/add'>Apply for Role</a><br>" +
            "<a href='/inquiries'>View Inquiries</a>"
        );

        get("/add", (req, res) ->
            "<h1>Job Inquiry Form</h1>" +
            "<form method='post' action='/add'>" +
            "Name:<br><input name='name' required><br><br>" +
            "Email:<br><input name='email' type='email' required><br><br>" +
            "Role:<br><input name='role' required><br><br>" +
            "<button type='submit'>Submit</button>" +
            "</form><br><a href='/'>Home</a>"
        );

        post("/add", (req, res) -> {
            String name = req.queryParams("name");
            String email = req.queryParams("email");
            String role = req.queryParams("role");

            try (Connection conn = DriverManager.getConnection("jdbc:sqlite:java_app.db")) {
                PreparedStatement stmt = conn.prepareStatement(
                    "INSERT INTO inquiries (name, email, role) VALUES (?, ?, ?)"
                );
                stmt.setString(1, name);
                stmt.setString(2, email);
                stmt.setString(3, role);
                stmt.executeUpdate();
            }

            res.redirect("/inquiries");
            return null;
        });

        get("/inquiries", (req, res) -> {
            StringBuilder html = new StringBuilder();
            html.append("<h1>Job Inquiries</h1>");
            html.append("<table border='1' cellpadding='8'>");
            html.append("<tr><th>ID</th><th>Name</th><th>Email</th><th>Role</th></tr>");

            try (Connection conn = DriverManager.getConnection("jdbc:sqlite:java_app.db")) {
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT * FROM inquiries");

                while (rs.next()) {
                    html.append("<tr>")
                        .append("<td>").append(rs.getInt("id")).append("</td>")
                        .append("<td>").append(rs.getString("name")).append("</td>")
                        .append("<td>").append(rs.getString("email")).append("</td>")
                        .append("<td>").append(rs.getString("role")).append("</td>")
                        .append("</tr>");
                }
            }

            html.append("</table><br><a href='/'>Home</a>");
            return html.toString();
        });
    }

    private static void initDatabase() {
        try (Connection conn = DriverManager.getConnection("jdbc:sqlite:java_app.db")) {
            Statement stmt = conn.createStatement();
            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS inquiries (" +
                "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                "name TEXT, " +
                "email TEXT, " +
                "role TEXT)"
            );
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
