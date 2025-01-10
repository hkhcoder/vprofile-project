<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="contextPath" value="${pageContext.request.contextPath}"/>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>Sign Up</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="icon" type="image/png" href="${contextPath}/resources/images/icons/favicon.ico"/>
    <link rel="stylesheet" type="text/css" href="${contextPath}/resources/vendor/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="${contextPath}/resources/fonts/font-awesome-4.7.0/css/font-awesome.min.css">
    <link rel="stylesheet" type="text/css" href="${contextPath}/resources/fonts/iconic/css/material-design-iconic-font.min.css">
    <link rel="stylesheet" type="text/css" href="${contextPath}/resources/vendor/animate/animate.css">
    <link rel="stylesheet" type="text/css" href="${contextPath}/resources/vendor/css-hamburgers/hamburgers.min.css">
    <link rel="stylesheet" type="text/css" href="${contextPath}/resources/vendor/animsition/css/animsition.min.css">
    <link rel="stylesheet" type="text/css" href="${contextPath}/resources/vendor/select2/select2.min.css">
    <link rel="stylesheet" type="text/css" href="${contextPath}/resources/vendor/daterangepicker/daterangepicker.css">
    <link rel="stylesheet" type="text/css" href="${contextPath}/resources/css/util.css">
    <link rel="stylesheet" type="text/css" href="${contextPath}/resources/css/main.css">
    <style>
        .navbar-custom {
            background: rgba(0, 0, 0, 0); /* Fully transparent */
            border: none;
            box-shadow: none; /* Remove any box shadow if present */
        }
        .navbar-custom .navbar-brand, .navbar-custom .navbar-nav > li > a {
            color: #fff;
        }
        .navbar-custom .navbar-nav > li > a:hover {
            color: #007bff;
        }
        .navbar-wrapper {
            position: absolute;
            width: 100%;
            top: 0;
            left: 0;
            z-index: 1000;
        }
        body {
            background-image: url('${contextPath}/resources/Images/bg-01.jpg');
            background-size: cover;
            background-repeat: no-repeat;
            background-attachment: fixed;
        }
        * {
            margin: 0px;
            padding: 0px;
            box-sizing: border-box;
            color:red;
        }
    </style>
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar navbar-custom navbar-expand-lg navbar-light">
        <a class="navbar-brand" href="${contextPath}/">HKH Infotech</a>
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarNav">

        </div>
    </nav>

    <div class="limiter">
        <div class="container-login100">
            <div class="wrap-login100 p-l-55 p-r-55 p-t-65 p-b-50">
                <form:form modelAttribute="userForm" method="post" class="login100-form validate-form">
                    <span class="login100-form-title p-b-30">Sign Up</span>

                    <!-- Email field -->
                    <div class="wrap-input100 validate-input m-b-23" data-validate="Email is required">
                        <span class="label-input100">Email ID</span>
                        <form:input path="userEmail" class="input100" placeholder="Type your email id"/>
                        <form:errors path="userEmail" cssClass="error"/>
                        <span class="focus-input100" data-symbol="&#xf206;"></span>
                    </div>

                    <!-- Username field -->
                    <div class="wrap-input100 validate-input m-b-23" data-validate="Username is required">
                        <span class="label-input100">Username</span>
                        <form:input path="username" class="input100" placeholder="Type your username"/>
                        <form:errors path="username" cssClass="error"/>
                        <span class="focus-input100" data-symbol="&#xf206;"></span>
                    </div>

                    <!-- Password field -->
                    <div class="wrap-input100 validate-input m-b-23" data-validate="Password is required">
                        <span class="label-input100">Password</span>
                        <form:password path="password" class="input100" placeholder="Type your password"/>
                        <form:errors path="password" cssClass="error"/>
                        <span class="focus-input100" data-symbol="&#xf190;"></span>
                    </div>

                    <!-- Confirm Password field -->
                    <div class="wrap-input100 validate-input m-b-23" data-validate="Confirm password is required">
                        <span class="label-input100">Confirm Password</span>
                        <br>
                        <form:password path="passwordConfirm" class="input100" placeholder="Confirm your password"/>
                        <form:errors path="passwordConfirm" cssClass="error"/>
                        <span class="focus-input100" data-symbol="&#xf190;"></span>
                    </div>

                    <!-- Sign Up button -->
                    <div class="container-login100-form-btn">
                        <div class="wrap-login100-form-btn">
                            <div class="login100-form-bgbtn"></div>
                            <button class="login100-form-btn">Sign Up</button>
                        </div>
                    </div>

                    <!-- Login link -->
                    <div class="flex-col-c p-t-155">
                        <span class="txt1 p-b-17">Already have an account?</span>
                        <a href="${contextPath}" class="txt2">Login</a>
                    </div>
                </form:form>
            </div>
        </div>
    </div>

    <div id="dropDownSelect1"></div>

    <script src="${contextPath}/resources/vendor/jquery/jquery-3.2.1.min.js"></script>
    <script src="${contextPath}/resources/vendor/animsition/js/animsition.min.js"></script>
    <script src="${contextPath}/resources/vendor/bootstrap/js/popper.js"></script>
    <script src="${contextPath}/resources/vendor/bootstrap/js/bootstrap.min.js"></script>
    <script src="${contextPath}/resources/vendor/select2/select2.min.js"></script>
    <script src="${contextPath}/resources/vendor/daterangepicker/moment.min.js"></script>
    <script src="${contextPath}/resources/vendor/daterangepicker/daterangepicker.js"></script>
    <script src="${contextPath}/resources/vendor/countdowntime/countdowntime.js"></script>
    <script src="${contextPath}/resources/js/main.js"></script>
</body>
</html>
