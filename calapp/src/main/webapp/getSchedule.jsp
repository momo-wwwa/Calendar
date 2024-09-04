<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.BufferedReader, java.io.FileReader, java.io.IOException" %>
<%
String date = request.getParameter("date");
String filePath = "C:/Users/momon/web2024/calapp/src/main/webapp/schedules.txt";
StringBuilder scheduleDetails = new StringBuilder();

/* デバッグ情報の追加
System.out.println("Date parameter: " + date);
System.out.println("Reading file: " + filePath);*/


try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
    String line;
    boolean dateFound = false;
    while ((line = reader.readLine()) != null) {
        if (line.startsWith("日付: " + date)) {
            dateFound = true;
            scheduleDetails.append(line).append("<br>");
            while ((line = reader.readLine()) != null && !line.startsWith("------")) {
                scheduleDetails.append(line).append("<br>");
            }
         // 編集と削除のリンクを追加
            scheduleDetails.append("<a href='javascript:editSchedule(\"").append(date).append("\")'>編集</a> ");
            scheduleDetails.append("<a href='javascript:deleteSchedule(\"").append(date).append("\")'>削除</a><br>");
            break;
        }
    }
    if (!dateFound) {
        scheduleDetails.append("予定はありません。");
    }
} catch (IOException e) {
    scheduleDetails.append("エラーが発生しました。");
    //e.printStackTrace();
}

out.print(scheduleDetails.toString());
%>
