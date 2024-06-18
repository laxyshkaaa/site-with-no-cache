
<%
    
    if (session != null) {
        session.invalidate();
    }
    response.sendRedirect("login.jsp");
%>

<html>
<head>
    <title>Logout</title>
</head>
<body>
    <p>Logging out...</p>
</body>
</html>
