<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>RabbitMQ</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: white;
            color: black;
            padding: 20px;
            margin: 0;
        }
        h1 {
            color: black;
        }
        h3 {
            color: black;
        }
    </style>
</head>
<body>
    <%
        int connections = (int) (Math.random() * 10) + 1;
        int channels = (int) (Math.random() * 10) + 1;
        int exchange = (int) (Math.random() * 10) + 1;
        int queues = (int) (Math.random() * 10) + 1;
    %>
    <h1>RabbitMQ Initiated</h1>
    <h3>Generated <%= connections %> Connections</h3>
    <h3><%= channels %> Channels, <%= exchange %> Exchange, and <%= queues %> Queues</h3>
</body>
</html>
