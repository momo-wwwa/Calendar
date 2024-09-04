<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page language="java" %>
<%@ page import="java.io.*, java.util.*" %>

<%
    String memoToDelete = request.getParameter("memo");
    if (memoToDelete != null && !memoToDelete.trim().isEmpty()) {
    	//ファイルパス
    	String filePath = "C:/Users/momon/web2024/calapp/src/main/webapp/memos.txt";
        File inputFile = new File(filePath);
        File tempFile = new File(filePath + ".tmp");

        BufferedReader reader = new BufferedReader(new FileReader(inputFile));
        BufferedWriter writer = new BufferedWriter(new FileWriter(tempFile));

        String currentLine;
        while ((currentLine = reader.readLine()) != null) {
            // メモが削除対象でない場合は、一時ファイルに書き込む
            if (!currentLine.trim().equals(memoToDelete.trim())) {
                writer.write(currentLine);
                writer.newLine();
            }
        }
        writer.close();
        reader.close();

        // オリジナルファイルを削除し、一時ファイルをリネーム
        if (!inputFile.delete()) {
            System.out.println("Could not delete file");
        }
        if (!tempFile.renameTo(inputFile)) {
            System.out.println("Could not rename file");
        }
    }
    response.sendRedirect("calendar.jsp");
%>
