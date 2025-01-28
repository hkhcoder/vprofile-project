<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>User Not Found</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        body {
            font-family: 'Arial', sans-serif;
            background-color: #f8f9fa;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            text-align: center;
        }
        .container {
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            padding: 40px;
            max-width: 500px;
            width: 100%;
        }
        h1 {
            color: #dc3545;
            font-size: 48px;
            margin: 0;
        }
        p {
            color: #495057;
            font-size: 18px;
            margin: 20px 0;
        }
        a {
            color: #007bff;
            text-decoration: none;
            font-weight: bold;
        }
        a:hover {
            text-decoration: underline;
        }
        .icon {
            font-size: 100px;
            color: #dc3545;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="icon">
            <i class="fas fa-user-times"></i>
        </div>
        <h1>User Not Found</h1>
        <p>It seems we couldn't find your account. You can <a href="${pageContext.request.contextPath}/registration">create a new account</a> if you don't have one.</p>
    </div>
</body>
</html>
