<%@ page import="java.sql.Connection, java.sql.DriverManager, java.sql.PreparedStatement, java.sql.ResultSet" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.security.NoSuchAlgorithmException" %>
<%@ page import="java.util.logging.Level" %>
<%@ page import="java.util.logging.Logger" %>

<%
    // Устанавливаем заголовки для предотвращения кэширования
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setDateHeader("Expires", 0); 

    String login = request.getParameter("login");
    String password = request.getParameter("password");
    String message = "";

    if (login != null && password != null) {
        boolean authenticated = false;
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            // Подключение к базе данных
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/auth", "root", "ol29pa13le15ur27");

            // Извлечение захешированного пароля и прав пользователя из базы данных
            String sql = "SELECT password, admin FROM users WHERE login = ?";
            preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setString(1, login);
            resultSet = preparedStatement.executeQuery();

            if (resultSet.next()) {
                String storedHashedPassword = resultSet.getString("password");
                int isAdmin = resultSet.getInt("admin");

                // Хеширование введенного пароля
                MessageDigest md = MessageDigest.getInstance("SHA-256");
                md.update(password.getBytes());
                byte[] digest = md.digest();
                StringBuilder sb = new StringBuilder();
                for (byte b : digest) {
                    sb.append(String.format("%02x", b));
                }
                String hashedPassword = sb.toString();

                
                if (storedHashedPassword.equals(hashedPassword)) {
                    authenticated = true;
                    session.setAttribute("user", login);

                   
                    String pageSql = "SELECT text FROM content WHERE id = ?";
                    PreparedStatement pageStatement = connection.prepareStatement(pageSql);
                    if (isAdmin == 1) {
                        pageStatement.setInt(1, 1); 
                    } else {
                        pageStatement.setInt(1, 2); 
                    }
                    ResultSet pageResult = pageStatement.executeQuery();
                    if (pageResult.next()) {
                        String pageContent = pageResult.getString("text");
                        session.setAttribute("pageContent", pageContent);
                        response.sendRedirect("content.jsp");
                    }
                    pageResult.close();
                    pageStatement.close();
                    return;
                } else {
                    message = "Invalid login or password.";
                }
            } else {
                message = "Invalid login or password.";
            }
        } catch (NoSuchAlgorithmException | ClassNotFoundException | IOException e) {
            Logger.getLogger(this.getClass().getName()).log(Level.SEVERE, null, e);
            message = "An error occurred during authentication.";
        } finally {
            if (resultSet != null) try { resultSet.close(); } catch (Exception e) {}
            if (preparedStatement != null) try { preparedStatement.close(); } catch (Exception e) {}
            if (connection != null) try { connection.close(); } catch (Exception e) {}
        }
    }
%>

<html>
<head>
    <title>Login Page</title>
</head>
<body>
    <h2>Login</h2>
    <form action="login.jsp" method="post">
        <label for="login">Login:</label>
        <input type="text" name="login"><br><br>
        <label for="password">Password:</label>
        <input type="password" name="password"><br><br>
        <input type="submit" value="Login">
    </form>
    <p><%= message %></p>
</body>
</html>
