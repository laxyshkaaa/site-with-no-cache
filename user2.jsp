
<%
    
    if (session == null || session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

  
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); 
    response.setDateHeader("Expires", 0); 
%>

<html>
<head>
    <title>USER Page</title>
</head>
<body>
    <h2>Welcome, <%= session.getAttribute("user") %></h2>
    <a href="logout.jsp">Logout</a>
</body>
</html>
