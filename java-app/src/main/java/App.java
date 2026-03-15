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

        get("/", (req, res) -> pageTemplate("Java Job Inquiry App",
            "<span class='badge'>Java + Spark + SQLite</span>" +
            "<h1>Job Inquiry App</h1>" +
            "<p>This app collects job inquiry submissions with the applicant's name, email, and role of interest.</p>" +
            "<div class='nav'>" +
            "<a class='btn' href='/add'>Apply for Role</a>" +
            "<a class='btn secondary' href='/inquiries'>View Inquiries</a>" +
            "</div>"
        ));

        get("/add", (req, res) -> pageTemplate("Job Inquiry Form",
            "<h1>Job Inquiry Form</h1>" +
            "<p>Fill out the form below to submit a job inquiry.</p>" +
            "<div class='nav'>" +
            "<a class='btn secondary' href='/'>← Back Home</a>" +
            "<a class='btn secondary' href='/inquiries'>View Inquiries</a>" +
            "</div>" +
            "<form method='post' action='/add'>" +
            "<div><label>Name</label><input name='name' required placeholder='Enter full name'></div>" +
            "<div><label>Email</label><input name='email' type='email' required placeholder='Enter email address'></div>" +
            "<div><label>Role</label><input name='role' required placeholder='Enter desired role'></div>" +
            "<button type='submit'>Submit Inquiry</button>" +
            "</form>"
        ));

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
            StringBuilder rows = new StringBuilder();

            try (Connection conn = DriverManager.getConnection("jdbc:sqlite:java_app.db")) {
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT * FROM inquiries");

                while (rs.next()) {
                    rows.append("<tr>")
                        .append("<td>").append(rs.getInt("id")).append("</td>")
                        .append("<td>").append(rs.getString("name")).append("</td>")
                        .append("<td>").append(rs.getString("email")).append("</td>")
                        .append("<td>").append(rs.getString("role")).append("</td>")
                        .append("</tr>");
                }
            }

            if (rows.length() == 0) {
                rows.append("<tr><td colspan='4'>No inquiries yet.</td></tr>");
            }

            String content =
                "<h1>Inquiries Dashboard</h1>" +
                "<p>This page shows all submitted job inquiries.</p>" +
                "<div class='nav'>" +
                "<a class='btn secondary' href='/'>← Back Home</a>" +
                "<a class='btn' href='/add'>Add Inquiry</a>" +
                "</div>" +
                "<div class='table-wrap'>" +
                "<table>" +
                "<tr><th>ID</th><th>Name</th><th>Email</th><th>Role</th></tr>" +
                rows +
                "</table>" +
                "</div>";

            return pageTemplate("Inquiries Dashboard", content);
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

    private static String pageTemplate(String title, String content) {
        return "<!DOCTYPE html>" +
            "<html lang='en'>" +
            "<head>" +
            "<meta charset='UTF-8'>" +
            "<meta name='viewport' content='width=device-width, initial-scale=1.0'>" +
            "<title>" + title + "</title>" +
            "<style>" +
            "* { box-sizing: border-box; }" +
            "body { margin: 0; font-family: Arial, sans-serif; background: linear-gradient(135deg, #eef6ff, #f8fbff); color: #1f2937; }" +
            ".wrapper { min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 24px; }" +
            ".card { width: 100%; max-width: 900px; background: white; border-radius: 18px; padding: 32px; box-shadow: 0 12px 30px rgba(0,0,0,0.08); }" +
            "h1 { margin-top: 0; font-size: 2rem; color: #0f172a; }" +
            "p { color: #475569; line-height: 1.6; }" +
            ".nav { display: flex; flex-wrap: wrap; gap: 12px; margin-bottom: 24px; }" +
            ".btn, button { display: inline-block; background: #2563eb; color: white; text-decoration: none; border: none; border-radius: 10px; padding: 12px 18px; font-size: 0.95rem; cursor: pointer; }" +
            ".btn.secondary { background: #e2e8f0; color: #0f172a; }" +
            "form { display: grid; gap: 16px; margin-top: 20px; }" +
            "label { font-weight: bold; margin-bottom: 6px; display: block; }" +
            "input { width: 100%; padding: 14px; border: 1px solid #cbd5e1; border-radius: 10px; font-size: 1rem; background: #f8fafc; }" +
            ".table-wrap { overflow-x: auto; margin-top: 20px; }" +
            "table { width: 100%; border-collapse: collapse; min-width: 600px; }" +
            "th, td { padding: 14px; text-align: left; border-bottom: 1px solid #e2e8f0; }" +
            "th { background: #eff6ff; color: #1e3a8a; }" +
            ".badge { display: inline-block; background: #dbeafe; color: #1d4ed8; padding: 6px 10px; border-radius: 999px; font-size: 0.85rem; font-weight: bold; width: fit-content; }" +
            "@media (max-width: 640px) { .card { padding: 22px; border-radius: 14px; } h1 { font-size: 1.6rem; } .btn, button { width: 100%; text-align: center; } .nav { flex-direction: column; } }" +
            "</style>" +
            "</head>" +
            "<body>" +
            "<div class='wrapper'>" +
            "<div class='card'>" +
            content +
            "</div>" +
            "</div>" +
            "</body>" +
            "</html>";
    }
}
