<%@ page language="java" contentType="text/html; charset=Windows-31J" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.net.URLEncoder, java.util.*" %>

<%
    String searchTitle = request.getParameter("searchTitle");
	String filePath = "C:/Users/momon/web2024/calapp/src/main/webapp/schedules.txt";
    List<String> results = new ArrayList<>();

    if (searchTitle != null && !searchTitle.isEmpty()) {
        BufferedReader reader = null;
        try {
            reader = new BufferedReader(new FileReader(filePath));
            String line;
            boolean matchFound = false;
            StringBuilder schedule = new StringBuilder();

            while ((line = reader.readLine()) != null) {
                if (line.startsWith("日付:")) {
                    if (schedule.length() > 0) {
                        if (matchFound) {
                            results.add(schedule.toString());
                        }
                        schedule.setLength(0);
                        matchFound = false;
                    }
                }
                schedule.append(line).append("<br>");
                if (line.startsWith("タイトル:") && line.contains(searchTitle)) {
                    matchFound = true;
                }
            }
            if (matchFound && schedule.length() > 0) {
                results.add(schedule.toString());
            }
        } catch (IOException e) {
            out.println("ファイル読み込み中にエラーが発生しました。");
        } finally {
            if (reader != null) {
                try {
                    reader.close();
                } catch (IOException e) {
                    // Handle exception
                }
            }
        }
    }
    
    StringBuilder query = new StringBuilder();
    for(String result : results){
    	query.append(URLEncoder.encode(result,"UTF-8")).append(",");
    }
    
    response.sendRedirect("calendar.jsp?searchResults="+query.toString());
%>
