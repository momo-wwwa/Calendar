<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.util.*, javax.servlet.*, javax.servlet.http.*" %>

<%
    String date = request.getParameter("date");
    if (date == null) {
        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "日付パラメータが欠如しています。");
        return;
    }

    String filePath = "C:/Users/momon/web2024/calapp/src/main/webapp/schedules.txt";
    File file = new File(filePath);
    if (!file.exists()) {
        response.sendError(HttpServletResponse.SC_NOT_FOUND, "ファイルが見つかりません。");
        return;
    }

    // ファイルからエントリーを読み込む
    List<String> lines = new ArrayList<>();
    try (BufferedReader br = new BufferedReader(new FileReader(file))) {
        String line;
        while ((line = br.readLine()) != null) {
            lines.add(line);
        }
    }

    // 指定された日付のエントリーを除外してファイルに書き込む
    try (PrintWriter pw = new PrintWriter(new FileWriter(file))) {
        for (String line : lines) {
            // 日付が含まれる行のみを除外する
            if (!line.contains(date)) {
                pw.println(line);
            }
        }
    }

    response.setContentType("text/plain");
    response.getWriter().write("スケジュールが正常に削除されました。");
%>
