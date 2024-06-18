
<%
    
    String pageContent = (String) session.getAttribute("pageContent");
    if (pageContent != null) {
        out.println(pageContent);
    } else {
        out.println("<p>No content .</p>");
    }
%>
