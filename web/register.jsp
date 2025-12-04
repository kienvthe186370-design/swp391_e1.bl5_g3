<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.regex.*" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Đăng ký - Pickleball Shop</title>

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
        .register-section {
            padding: 80px 0;
            min-height: 600px;
        }
        .register-form {
            max-width: 600px;
            margin: 0 auto;
            background: #fff;
            padding: 50px;
            border-radius: 5px;
            box-shadow: 0 0 20px rgba(0,0,0,0.05);
        }
        .register-form h3 {
            text-align: center;
            margin-bottom: 10px;
            font-weight: 700;
            color: #111;
        }
        .register-form > p {
            text-align: center;
            color: #666;
            margin-bottom: 30px;
        }
        .register-form .form-group {
            margin-bottom: 25px;
        }
        .register-form label {
            font-weight: 600;
            color: #111;
            margin-bottom: 10px;
        }
        .register-form label span {
            color: #ca1515;
        }
        .register-form input[type="text"],
        .register-form input[type="email"],
        .register-form input[type="tel"],
        .register-form input[type="password"] {
            width: 100%;
            height: 50px;
            border: 1px solid #e1e1e1;
            padding: 0 20px;
            font-size: 14px;
            border-radius: 4px;
        }
        .register-form input:focus {
            border-color: #ca1515;
            outline: none;
        }
        .register-form .site-btn {
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
        .register-form .site-btn:hover {
            background: #111;
        }
        .register-links {
            text-align: center;
            margin-top: 25px;
        }
        .register-links a {
            color: #ca1515;
            text-decoration: none;
            font-weight: 600;
        }
        .register-links a:hover {
            text-decoration: underline;
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
                        <h4>Đăng Ký</h4>
                        <div class="breadcrumb__links">
                            <a href="./index.html">Trang chủ</a>
                            <span>Đăng ký</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
    <!-- Breadcrumb Section End -->

    <!-- Register Section Begin -->
    <section class="register-section">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="register-form">
                        <h3>Đăng Ký Tài Khoản</h3>
                        <p>Tạo tài khoản mới để mua sắm</p>
                        
                        <% if (request.getAttribute("error") != null) { %>
                            <div class="alert alert-danger">
                                <%= request.getAttribute("error") %>
                            </div>
                        <% } %>
                        
                        <form action="register" method="post">
                            <div class="form-group">
                                <label>Họ và tên <span>*</span></label>
                                <input type="text" name="fullName" 
                                       value="<%= request.getAttribute("fullName") != null ? request.getAttribute("fullName") : "" %>"
                                       placeholder="Nhập họ và tên" required>
                            </div>
                            
                            <div class="form-group">
                                <label>Email <span>*</span></label>
                                <input type="email" name="email" 
                                       value="<%= request.getAttribute("email") != null ? request.getAttribute("email") : "" %>"
                                       placeholder="Nhập email" required>
                            </div>
                            
                            <div class="form-group">
                                <label>Số điện thoại <span>*</span></label>
                                <input type="tel" name="phone" 
                                       value="<%= request.getAttribute("phone") != null ? request.getAttribute("phone") : "" %>"
                                       placeholder="Nhập số điện thoại" required>
                            </div>
                            
                            <div class="form-group">
                                <label>Mật khẩu <span>*</span></label>
                                <input type="password" name="password" 
                                       placeholder="Nhập mật khẩu (tối thiểu 6 ký tự)" required>
                            </div>
                            
                            <div class="form-group">
                                <label>Xác nhận mật khẩu <span>*</span></label>
                                <input type="password" name="confirmPassword" 
                                       placeholder="Nhập lại mật khẩu" required>
                            </div>
                            
                            <button type="submit" class="site-btn">Đăng Ký</button>
                        </form>
                        
                        <div class="register-links">
                            <p>Đã có tài khoản? <a href="login">Đăng nhập ngay</a></p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
    <!-- Register Section End -->

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
