<%@ page language="java" contentType="text/html; charset=Windows-31J" pageEncoding="UTF-8"%>
<%@ page import="java.net.*,java.util.*, java.io.*, java.util.concurrent.Executors, java.util.concurrent.ScheduledExecutorService,java.util.concurrent.TimeUnit, java.text.SimpleDateFormat,java.util.Calendar,java.util.Date,java.net.URLDecoder" %>
<%@ page import="java.io.*, java.net.URLEncoder" %>


<%
String filePathmemo = "C:/Users/momon/web2024/calapp/src/main/webapp/memos.txt";

//デフォルトのロケール、タイムゾーンを持つCalendarオブジェクトを生成
 //日時はロケールとタイムゾーンに基づいた現在日時が保持
 //＝現在のマシン日付を管理したカレンダーオブジェクトを生成
 // （Calendarクラスのコピーではない!)
 Calendar cal=Calendar.getInstance();
 
 //▼▼▼ 追記 ▼▼▼
 
 //JSPでは、宣言せずに使用できるオブジェクトとして9つの暗黙オブジェクト
 //（request, response, pageContext, session, application, config, page, exception）
 //が用意されています

   //getParameter:引数にパラメータ名を指定し、そのパラメータの値を取得【JSPのみ】
 //この場合、下の【Ａ】もしくは【Ｂ】で渡しているパラメータから
 //年、月の値をatrYear strMonthに代入
 //存在しなければnullを返す
 String strYear=request.getParameter("year");
 String strMonth=request.getParameter("month");
 
 int intYear;
 int intMonth;
 //パラメータ無しならばShowCalendar1と同様の処理。
 //パラメータあった場合は下記if文内の処理実施
 if(strYear!=null && strMonth!=null){
  //一旦intMonthTempに代入
  int intMonthTemp=Integer.parseInt(strMonth);
  //12で割ったあまりを代入：
  // 0の場合は0を代入(12月)
  //13の場合は1を代入( 1月)
  intMonth=intMonthTemp%12;
  //13の場合、1を足した年を代入、その他は年のまま
  intYear=Integer.parseInt(strYear)+intMonthTemp/12;
  //12月の場合はintMonthが0となるため、これを12月に変更し、年を一年減少
  if(intMonth==0){
   intMonth=12;
   intYear--;
  }
  //上記結果のintYearとintMonth-1で初期化
  cal.set(Calendar.YEAR,intYear);
  cal.set(Calendar.MONTH,intMonth-1);
 }
 //▲▲▲ 追記 ▲▲▲
 
 //calで管理している現在の年を取得
 intYear=cal.get(Calendar.YEAR);
 
 //現在の月を取得
 //Calendar.MONTHは1月＝０（０～１１）
 //よってここで１を足して何月かを示す
 intMonth=cal.get(Calendar.MONTH)+1;
 
 //現在の日を取得した上で、
 //set：第1引数にフィールド、第2引数に値を指定し、フィールドの値を設定
 //＝カレンダー上で受け取った日付を１日【月初】にセットする
 cal.set(Calendar.DATE,1);
 
 //【当年当月の１日の】曜日を取得した上で【1を引いて】【k】に代入
 //DAY_OF_WEEK ： 日曜が1で始まる1～7 の数字
 //DAY_OF_WEEK ： 日曜が１、土曜が７
 //結果、【ｋ】： 日曜が０、土曜が６
 int k=cal.get(Calendar.DAY_OF_WEEK)-1;
%>

<%!
String prettyPrintHTML(String s) {
    if (s == null)
        return "";
    return s.replace("&", "&amp;")
            .replace("\"", "&quot;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("'", "&#39;")
            .replace("\n", "<br>\n");
}

public class MyHttpClient {
    public String url; 
    public String tag;
    public String encoding = "UTF-8"; 
    public String header = ""; 
    public String body = ""; 

   
    public MyHttpClient(String url) {
        this.url = url;
    }
    
    public void doAccess() throws MalformedURLException, ProtocolException, IOException {
        URL u = new URL(url);
        HttpURLConnection con = (HttpURLConnection) u.openConnection();
        con.setRequestMethod("GET");
        con.setInstanceFollowRedirects(true);

        con.connect();

        // ヘッダー
        Map<String, List<String>> headers = con.getHeaderFields();
        StringBuilder sb = new StringBuilder();
        for (String key : headers.keySet()) {
            sb.append("  " + key + ": " + headers.get(key) + "\n");
        }

        sb.append("RESPONSE CODE [" + con.getResponseCode() + "]\n");
        sb.append("RESPONSE MESSAGE [" + con.getResponseMessage() + "]\n");

        header = sb.toString();

        // ボディ
        BufferedReader reader = new BufferedReader(
            new InputStreamReader(con.getInputStream(), encoding));
        String line;
        sb = new StringBuilder();

        while ((line = reader.readLine()) != null) {
            sb.append(line + "\n");
        }

        body = sb.toString();

        reader.close();
        con.disconnect();
    }
}

String extractFromXML2(String xml,String date,String tagName) {
  String startTag ="\"dateLabel\": \"" + date + "\",\n            " + tagName;
  String endTag = "\",";
  int startIndex = xml.indexOf(startTag);
  if (startIndex == -1) {
      return null;
  }
  startIndex += startTag.length();
  int endIndex = xml.indexOf(endTag, startIndex);
  if (endIndex == -1) {
      return null;
  }
  return xml.substring(startIndex, endIndex).trim();
}
%>

<%
//天気の表示
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");

String msg = ""; 
MyHttpClient mhc; 

String location = request.getParameter("location");

String Telop="";
try {
    mhc = new MyHttpClient("https://weather.tsukumijima.net/api/forecast/city/300010");
    mhc.doAccess();
    Telop += mhc.body;
    msg += "今日の天気：";
   msg += extractFromXML2(Telop, "今日","\"telop\": \"");
   msg += "&nbsp;&nbsp;";
   msg += "明日の天気：";
   msg += extractFromXML2(Telop,"明日", "\"telop\": \"");
   msg += "&nbsp;&nbsp;";
   msg += "明後日の天気：";
   msg += extractFromXML2(Telop,"明後日", "\"telop\": \"");
 
 } catch (IOException e) {
   msg += "何らかの不具合が発生しました。";
 }
%>
<!--日付表示-->
<%
Calendar calendar = Calendar.getInstance();

Date date = calendar.getTime();

SimpleDateFormat sformat = new SimpleDateFormat("yyyy/MM/dd");
String fdate = sformat.format(date);
%>

<%
    // クエリパラメータから検索結果を取得
    String searchResults = request.getParameter("searchResults");
    List<String> results = new ArrayList<>();

    if (searchResults != null && !searchResults.isEmpty()) {
        String[] encodedResults = searchResults.split(",");
        for (String encodedResult : encodedResults) {
            results.add(URLDecoder.decode(encodedResult, "UTF-8"));
        }
    }
%>

<!-- メモ保存 -->
<%
    String newMemo = request.getParameter("newMemo");
    if (newMemo != null && !newMemo.trim().isEmpty()) {
        BufferedWriter writer = new BufferedWriter(new FileWriter(filePathmemo, true));
        writer.write(newMemo);
        writer.newLine();
        writer.close();
    }
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
  "http://www.w3.org/TR/html4/strict.dtd">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
  "http://www.w3.org/TR/html4/strict.dtd">

<HTML><HEAD>
<TITLE>カレンダー</TITLE>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=Windows-31J">
<LINK REL="stylesheet" TYPE="text/css" HREF="main.css">
</HEAD><BODY>
<H1>CALENDAR</H1>
<a href="HowToUse.jsp">HowTo</a>
<!--天気表示-->
<p><%= msg %></p>
<!--現在の年月を表示-->
    <p><%= fdate %></p>
<div class="head">
    <%//▼▼▼ 追記【Ａ】 ▼▼▼%>
	<a href="calendar.jsp?year=<%=intYear%>&month=<%=intMonth-1%>">前月</a>
    <span class="title"><%=intYear%>年<%=intMonth%>月</span>
    <%//▼▼▼ 追記【Ｂ】 ▼▼▼%>
	<a href="calendar.jsp?year=<%=intYear%>&month=<%=intMonth+1%>">翌月</a>
</div>
<table>
    <tr>
        <!--TH : Table Header-->
        <th class="holiday">日</th>
        <th class="weekday">月</th>
        <th class="weekday">火</th>
        <th class="weekday">水</th>
        <th class="weekday">木</th>
        <th class="weekday">金</th>
        <th class="saturday">土</th>
    </tr>
    <%int d=1;
    //月内の間はループ
    while(cal.get(Calendar.MONTH)==intMonth-1){%>
    <tr>
        <!--必ず日曜～土曜の一週間分は処理をするループ-->
        <%for(int j=0;j<7;j++){%>
        <%
        //各曜日のクラス決定
        if(j==0){%>
        <td class="holiday">
        <%}else if(j==6){%>
        <td class="saturday">
        <%}else{%>
        <td class="weekday">
        <%}//■終了■各曜日のクラス決定%>
        
        <%
        //もしkが０（＝日曜）でなければkから１を引く
        //【ｋ】： 日曜が０、土曜が６
        // はじめの１日目を書き込む曜日の確定用 
        // ＝前月分の空枠 
        if(k!=0){
            k--;
        //もしkが０（＝日曜）なら、もし月内の間なら
        // 月が不一致の場合は空白出力 
        }else if (cal.get(Calendar.MONTH)==intMonth-1){%>
            <!--変数ｄを一増やして日付表示-->
            <%if(d<=cal.getActualMaximum(Calendar.DATE)){%>
            <a href="javascript:showSchedule('<%=intYear%>/<%=intMonth%>/<%=d%>')"><%=d++%></a>
            <%}%>
            <!--一日先の日付にする-->
            <%cal.add(Calendar.DATE,1);%>
        <%}%>    <!--/***if(k!=0)-->
        </td>    <!--/***td(holiday,saturday,weekday)-->
        <%}%>     <!--/***for-->
    </tr>      <!--/***tr(外側-->
    <%}%>      <!--/***while-->
</table>

<!-- 検索フォーム -->
<div>
    <form action="searchSchedules.jsp" method="get">
        <label for="searchTitle">予定タイトル検索:</label>
        <input type="text" id="searchTitle" name="searchTitle" required>
        <button type="submit">検索</button>
    </form>
</div>

<!-- 検索結果表示 -->
    <div>
        <% if (results.isEmpty()) { %>
            <p></p>
        <% } else { %>
        <h2>検索結果</h2>
            <ul>
                <% for (String result : results) { %>
                    <li><%= result %></li>
                <% } %>
            </ul>
        <% } %>
    </div>

<!-- メモ機能 -->
    <h1>メモアプリ</h1>
    <form action="addMemo.jsp" method="post">
        <textarea name="newMemo" rows="4" cols="50"></textarea><br>
        <input type="submit" value="メモを追加">
    </form>
    <hr>
    <h2>メモ一覧</h2>
    <ul>
        <%
            BufferedReader reader = new BufferedReader(new FileReader(filePathmemo));
            String line;
            while ((line = reader.readLine()) != null) {
            	String encodedLine = URLEncoder.encode(line, "UTF-8");
                out.println("<li>" + prettyPrintHTML(line) + " <a href='deleteMemo.jsp?memo=" + encodedLine + "'>削除</a></li>");
            }
            reader.close();
        %>
    </ul>

<!-- 予定入力 -->
<div id="popup" style="display: none;overflow-y: scroll;height:400px;">
    <h2>予定詳細</h2>
    <div id="scheduleDetails"></div>
    <h2>予定入力フォーム</h2>
    <form action="saveSchedule.jsp" method="post">
        <input type="hidden" name="date" id="scheduleDate" value="">
        <label for="hour">時間:</label>
        <select id="hour" name="hour">
            <% for (int i = 0; i < 24; i++) { %>
                <option value="<%= String.format("%02d", i) %>"><%= String.format("%02d", i) %></option>
            <% } %>
        </select>時
        <select id="minute" name="minute">
            <% for (int i = 0; i < 60; i++) { %>
                <option value="<%= String.format("%02d", i) %>"><%= String.format("%02d", i) %></option>
            <% } %>
        </select>分<br>
        <label for="title">タイトル:</label>
        <input type="text" id="title" name="title" required><br>
        <label for="details">詳細:</label><br>
        <textarea id="details" name="details" rows="4" cols="50"></textarea><br>

        <label for="repeat">繰り返し:</label>
        <select id="repeat" name="repeat">
            <option value="none">なし</option>
            <option value="daily">毎日</option>
            <option value="weekly">毎週</option>
            <option value="monthly">毎月</option>
        </select><br>
        <label for="repeatUntilYear">繰り返し終了日（年）:</label>
        <select id="repeatUntilYear" name="repeatUntilYear">
            <% for (int i = 2020; i <= 2030; i++) { %>
                <option value="<%= i %>"><%= i %></option>
            <% } %>
        </select>
        <label for="repeatUntilMonth">月:</label>
        <select id="repeatUntilMonth" name="repeatUntilMonth">
            <% for (int i = 1; i <= 12; i++) { %>
                <option value="<%= i %>"><%= i %></option>
            <% } %>
        </select>
        <label for="repeatUntilDay">日:</label>
        <select id="repeatUntilDay" name="repeatUntilDay">
            <% for (int i = 1; i <= 31; i++) { %>
                <option value="<%= i %>"><%= i %></option>
            <% } %>
        </select><br>
        
        <button type="submit">保存</button>
    </form>
    <button onclick="hidePopup()">閉じる</button>
</div>

<!-- 予定詳細表示 -->
<script>
	function showSchedule(date) {
	    document.getElementById('scheduleDate').value = date;
	    var xhr = new XMLHttpRequest();
	    xhr.open('GET', 'getSchedule.jsp?date=' + date + '&t=' + new Date().getTime(), true);  // キャッシュ無効化のためにタイムスタンプを追加
	    xhr.onreadystatechange = function() {
	        if (xhr.readyState == 4 && xhr.status == 200) {
	            document.getElementById('scheduleDetails').innerHTML = xhr.responseText;
	            document.getElementById('popup').style.display = 'block';
	        }
	    };
	    xhr.send();
	}


    function editSchedule(date) {
        document.getElementById('scheduleDate').value = date;
        var xhr = new XMLHttpRequest();
        xhr.open('GET', 'getSchedule.jsp?date=' + date + '&t=' + new Date().getTime(), true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState == 4 && xhr.status == 200) {
                var response = xhr.responseText;
                var lines = response.split('<br>');
                var title = lines[1].replace('タイトル: ', '');
                var details = lines[2].replace('詳細: ', '');
                document.getElementById('title').value = title;
                document.getElementById('details').value = details;
                document.getElementById('popup').style.display = 'block';
            }
        };
        xhr.send();
    }

    function deleteSchedule(date) {
        if (confirm('本当にこの予定を削除しますか？')) {
            var xhr = new XMLHttpRequest();
            xhr.open('GET', 'deleteSchedule.jsp?date=' + encodeURIComponent(date)+'&t=' + new Date().getTime(), true);
            xhr.onreadystatechange = function() {
                if (xhr.readyState == 4 && xhr.status == 200) {
                    alert(xhr.responseText);
                    hidePopup(); 
                }
            };
            xhr.send();
        }
    }

    function hidePopup() {
    	document.getElementById('scheduleDetails').innerHTML = '';
        document.getElementById('popup').style.display = 'none';
    }
</script>

</BODY></HTML>