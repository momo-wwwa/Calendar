<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page language="java" %>
<%@ page import="java.io.*" %>

<%
    String newMemo = request.getParameter("newMemo");
    if (newMemo != null && !newMemo.trim().isEmpty()) {
    	//ファイルパス
    	String filePath = "C:/Users/momon/web2024/calapp/src/main/webapp/memos.txt";
        BufferedWriter writer = new BufferedWriter(new FileWriter(filePath, true));
        writer.write(newMemo);
        writer.newLine();
        writer.close();
    }
    response.sendRedirect("calendar.jsp");
%>
