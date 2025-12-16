<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.regex.*" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Đăng nhập - Pickleball Shop</title>

    <!-- Google Font -->
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">

    <!-- Css Styles -->
    <link rel="stylesheet" href="css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="css/elegant-icons.css" type="text/css">
    <link rel="stylesheet" href="css/magnific-popup.css" type="text/css">
    <link rel="stylesheet" href="css/nice-select.css" type="text/css">
    <link rel="stylesheet" href="css/owl.carousel.min.css" type="text/css">
    <link rel="stylesheet" href="css/slicknav.min.css" type="text/css">
    <link rel="stylesheet" href="css/style.css" type="text/css">
    
    <style>
        .login-section {
            padding: 80px 0;
            min-height: 600px;
        }
        .login-form {
            max-width: 500px;
            margin: 0 auto;
            background: #fff;
            padding: 50px;
            border-radius: 5px;
            box-shadow: 0 0 20px rgba(0,0,0,0.05);
        }
        .login-form h3 {
            text-align: center;
            margin-bottom: 10px;
            font-weight: 700;
            color: #111;
        }
        .login-form p {
            text-align: center;
            color: #666;
            margin-bottom: 30px;
        }
        .login-form .form-group {
            margin-bottom: 25px;
        }
        .login-form label {
            font-weight: 600;
            color: #111;
            margin-bottom: 10px;
        }
        .login-form input[type="email"],
        .login-form input[type="password"] {
            width: 100%;
            height: 50px;
            border: 1px solid #e1e1e1;
            padding: 0 20px;
            font-size: 14px;
            border-radius: 4px;
        }
        .login-form input:focus {
            border-color: #ca1515;
            outline: none;
        }
        .login-form .site-btn {
            width: 100%;
            height: 50px;
            background: #ca1515;
            border: none;
            color: #fff;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 2px;
            cursor: pointer;
            border-radius: 4px;
        }
        .login-form .site-btn:hover {
            background: #111;
        }
        .login-links {
            text-align: center;
            margin-top: 25px;
        }
        .login-links a {
            color: #ca1515;
            text-decoration: none;
            font-weight: 600;
        }
        .login-links a:hover {
            text-decoration: underline;
        }
        .btn-google:hover {
            background: #f5f5f5 !important;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        .alert-danger {
            background-color: #f8d7da;
            border: 1px solid #f5c6cb;
            color: #721c24;
        }
        .alert-success {
            background-color: #d4edda;
            border: 1px solid #c3e6cb;
            color: #155724;
        }
    </style>
</head>

<body>
    <%@include file="header.jsp" %>

    <!-- Breadcrumb Section Begin -->
    <section class="breadcrumb-option">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="breadcrumb__text">
                        <h4>Đăng Nhập</h4>
                        <div class="breadcrumb__links">
                            <a href="./index.html">Trang chủ</a>
                            <span>Đăng nhập</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
    <!-- Breadcrumb Section End -->

    <!-- Login Section Begin -->
    <section class="login-section">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="login-form">
                        <h3>Đăng Nhập</h3>
                        <p>Chào mừng bạn quay trở lại!</p>
                        
                        <% if (request.getAttribute("error") != null) { %>
                            <div class="alert alert-danger">
                                <%= request.getAttribute("error") %>
                            </div>
                        <% } %>
                        
                        <% if (request.getAttribute("success") != null) { %>
                            <div class="alert alert-success">
                                <%= request.getAttribute("success") %>
                            </div>
                        <% } %>
                        
                        <form action="login" method="post">
                            <div class="form-group">
                                <label>Email</label>
                                <input type="email" name="email" 
                                       value="<%= request.getAttribute("email") != null ? request.getAttribute("email") : "" %>"
                                       placeholder="Nhập email của bạn" required>
                            </div>
                            
                            <div class="form-group">
                                <label>Mật khẩu</label>
                                <input type="password" name="password" 
                                       placeholder="Nhập mật khẩu" required>
                            </div>
                            
                            <button type="submit" class="site-btn">Đăng Nhập</button>
                        </form>
                        
                        <!-- Divider -->
                        <div class="text-center my-4">
                            <span style="color: #999; position: relative; display: inline-block; padding: 0 15px; background: #fff;">
                                hoặc đăng nhập với
                            </span>
                            <hr style="margin-top: -10px; border-color: #e1e1e1;">
                        </div>
                        
                        <!-- Google Login Button -->
                        <a href="google-login<%= request.getParameter("redirect") != null ? "?redirect=" + request.getParameter("redirect") : "" %>" 
                           class="btn btn-block" 
                           style="background: #fff; border: 1px solid #ddd; padding: 12px; border-radius: 4px; display: flex; align-items: center; justify-content: center; text-decoration: none; color: #333; font-weight: 600; transition: all 0.3s;">
                            <img src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg" 
                                 alt="Google" style="width: 20px; height: 20px; margin-right: 10px;">
                            Đăng nhập với Google
                        </a>
                        
                        <div class="login-links">
                            <p><a href="forgot-password">Quên mật khẩu?</a></p>
                            <p>Chưa có tài khoản? <a href="register">Đăng ký ngay</a></p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
    <!-- Login Section End -->

    <%@include  file="footer.jsp"%>

    <!-- Js Plugins -->
    <script src="js/jquery-3.3.1.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <script src="js/jquery.nice-select.min.js"></script>
    <script src="js/jquery.nicescroll.min.js"></script>
    <script src="js/jquery.magnific-popup.min.js"></script>
    <script src="js/jquery.countdown.min.js"></script>
    <script src="js/jquery.slicknav.js"></script>
    <script src="js/mixitup.min.js"></script>
    <script src="js/owl.carousel.min.js"></script>
    <script src="js/main.js"></script>
</body>
</html>
