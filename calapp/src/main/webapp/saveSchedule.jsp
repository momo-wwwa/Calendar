<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.BufferedReader, java.io.FileReader, java.io.FileWriter, java.io.PrintWriter, java.io.IOException, java.util.Calendar, java.text.SimpleDateFormat, java.text.ParseException" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>予定を保存しました</title>
</head>
<body>
    <%
    // フォームから送信されたデータを取得
    String date = request.getParameter("date");
    String title = request.getParameter("title");
    String details = request.getParameter("details");
    String repeat = request.getParameter("repeat");
    String repeatUntilYear = request.getParameter("repeatUntilYear");
    String repeatUntilMonth = request.getParameter("repeatUntilMonth");
    String repeatUntilDay = request.getParameter("repeatUntilDay");

    // 繰り返し終了日を組み立てる
    String repeatUntilStr = repeatUntilYear + "/" + repeatUntilMonth + "/" + repeatUntilDay;

    // 保存先のファイルパス
    String filePath = "C:/Users/momon/web2024/calapp/src/main/webapp/schedules.txt";
    StringBuilder fileContent = new StringBuilder();

    // 既存の内容を読み込み、該当の日付があれば上書き、なければ追記
    try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
        String line;
        boolean dateFound = false;
        while ((line = reader.readLine()) != null) {
            if (line.startsWith("日付: " + date)) {
                dateFound = true;
                fileContent.append("日付: ").append(date).append("\n");
                fileContent.append("タイトル: ").append(title).append("\n");
                fileContent.append("詳細: ").append(details).append("\n");
                fileContent.append("------\n");
                while ((line = reader.readLine()) != null && !line.startsWith("日付: ")) {
                    // Skip existing schedule details
                }
            }
            if (line != null) {
                fileContent.append(line).append("\n");
            }
        }
        if (!dateFound) {
            fileContent.append("日付: ").append(date).append("\n");
            fileContent.append("タイトル: ").append(title).append("\n");
            fileContent.append("詳細: ").append(details).append("\n");
            fileContent.append("------\n");
        }

        // 繰り返しの設定がある場合、繰り返し終了日までスケジュールを追加
        if (!"none".equals(repeat) && repeatUntilStr != null && !repeatUntilStr.trim().isEmpty()) {
            SimpleDateFormat sdf1 = new SimpleDateFormat("yyyy/MM/dd");
            SimpleDateFormat sdf2 = new SimpleDateFormat("yyyy/M/d");
            SimpleDateFormat sdf3 = new SimpleDateFormat("yyyy/M/dd");
            SimpleDateFormat sdf4 = null; 
            Calendar cal = Calendar.getInstance();
            Calendar repeatUntil = Calendar.getInstance();

            boolean dateParsed = false;
            try {
                cal.setTime(sdf2.parse(date));
                sdf4 = sdf2;
                dateParsed = true;
            } catch (ParseException e1) {
                try {
                    cal.setTime(sdf3.parse(date));
                    sdf4 = sdf3;
                    dateParsed = true;
                } catch (ParseException e2) {
                    try {
                        cal.setTime(sdf1.parse(date));
                        sdf4 = sdf1;
                        dateParsed = true;
                    } catch (ParseException e3) {
                        out.println("<h1>日付の形式が不正です</h1>");
                    }
                }
            }

            boolean repeatUntilParsed = false;
            try {
                repeatUntil.setTime(sdf2.parse(repeatUntilStr));
                sdf4 = sdf2;
                repeatUntilParsed = true;
            } catch (ParseException e1) {
                try {
                    repeatUntil.setTime(sdf3.parse(repeatUntilStr));
                    sdf4 = sdf3;
                    repeatUntilParsed = true;
                } catch (ParseException e2) {
                    try {
                        repeatUntil.setTime(sdf1.parse(repeatUntilStr));
                        sdf4 = sdf1;
                        repeatUntilParsed = true;
                    } catch (ParseException e3) {
                        out.println("<h1>繰り返し終了日の形式が不正です</h1>");
                    }
                }
            }

            if (dateParsed && repeatUntilParsed) {
                while (cal.before(repeatUntil)) {
                    if ("daily".equals(repeat)) {
                        cal.add(Calendar.DATE, 1);
                    } else if ("weekly".equals(repeat)) {
                        cal.add(Calendar.DATE, 7);
                    } else if ("monthly".equals(repeat)) {
                        cal.add(Calendar.MONTH, 1);
                    }
                    String newDate = sdf4.format(cal.getTime());
                    fileContent.append("日付: ").append(newDate).append("\n");
                    fileContent.append("タイトル: ").append(title).append("\n");
                    fileContent.append("詳細: ").append(details).append("\n");
                    fileContent.append("------\n");
                }
            }
        }
    } catch (IOException e) {
        out.println("<h1>予定の保存中にエラーが発生しました</h1>");
        //e.printStackTrace(out);
    }

    // 新しい内容を書き込み
    try (PrintWriter writer = new PrintWriter(new FileWriter(filePath))) {
        writer.print(fileContent.toString());
        out.println("<h1>予定を保存しました</h1>");
    } catch (IOException e) {
        out.println("<h1>予定の保存中にエラーが発生しました</h1>");
        //e.printStackTrace(out);
    }

    response.sendRedirect("calendar.jsp");
    %>
</body>
</html>
