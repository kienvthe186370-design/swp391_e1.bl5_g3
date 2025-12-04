<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.regex.*" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Quên mật khẩu - Pickleball Shop</title>

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
        .forgot-section {
            padding: 80px 0;
            min-height: 600px;
        }
        .forgot-form {
            max-width: 550px;
            margin: 0 auto;
            background: #fff;
            padding: 50px;
            border-radius: 5px;
            box-shadow: 0 0 20px rgba(0,0,0,0.05);
        }
        .forgot-form h3 {
            text-align: center;
            margin-bottom: 10px;
            font-weight: 700;
            color: #111;
        }
        .forgot-form > p {
            text-align: center;
            color: #666;
            margin-bottom: 30px;
        }
        .forgot-form .info-text {
            color: #666;
            font-size: 14px;
            margin-bottom: 25px;
            padding: 15px;
            background: #f8f9fa;
            border-left: 3px solid #ca1515;
            border-radius: 4px;
        }
        .forgot-form .form-group {
            margin-bottom: 25px;
        }
        .forgot-form label {
            font-weight: 600;
            color: #111;
            margin-bottom: 10px;
        }
        .forgot-form input[type="email"],
        .forgot-form input[type="text"],
        .forgot-form input[type="password"] {
            width: 100%;
            height: 50px;
            border: 1px solid #e1e1e1;
            padding: 0 20px;
            font-size: 14px;
            border-radius: 4px;
        }
        .forgot-form input:focus {
            border-color: #ca1515;
            outline: none;
        }
        .forgot-form .site-btn {
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
        .forgot-form .site-btn:hover {
            background: #111;
        }
        .forgot-links {
            text-align: center;
            margin-top: 25px;
        }
        .forgot-links a {
            color: #ca1515;
            text-decoration: none;
            font-weight: 600;
        }
        .forgot-links a:hover {
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
                        <h4>Quên Mật Khẩu</h4>
                        <div class="breadcrumb__links">
                            <a href="./index.html">Trang chủ</a>
                            <span>Quên mật khẩu</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
    <!-- Breadcrumb Section End -->

    <!-- Forgot Password Section Begin -->
    <section class="forgot-section">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="forgot-form">
                        <h3>Quên Mật Khẩu</h3>
                        <p>Đặt lại mật khẩu của bạn</p>
                        
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
                        
                        <% if (request.getAttribute("showTokenForm") == null) { %>
                            <!-- Form nhập email -->
                            <p class="info-text">
                                <i class="fa fa-info-circle"></i>
                                Nhập email đã đăng ký của bạn. Chúng tôi sẽ gửi mã xác nhận để đặt lại mật khẩu.
                            </p>
                            
                            <form action="forgot-password" method="post">
                                <div class="form-group">
                                    <label>Email</label>
                                    <input type="email" name="email" 
                                           placeholder="Nhập email của bạn" required>
                                </div>
                                
                                <button type="submit" class="site-btn">Gửi Mã Xác Nhận</button>
                            </form>
                        <% } else { %>
                            <!-- Form nhập mã và mật khẩu mới -->
                            <p class="info-text">
                                <i class="fa fa-info-circle"></i>
                                Nhập mã xác nhận đã được hiển thị ở trên và mật khẩu mới của bạn.
                            </p>
                            
                            <form action="reset-password" method="post">
                                <div class="form-group">
                                    <label>Mã xác nhận</label>
                                    <input type="text" name="token" 
                                           placeholder="Nhập mã xác nhận" required>
                                </div>
                                
                                <div class="form-group">
                                    <label>Mật khẩu mới</label>
                                    <input type="password" name="newPassword" 
                                           placeholder="Nhập mật khẩu mới (tối thiểu 6 ký tự)" required>
                                </div>
                                
                                <div class="form-group">
                                    <label>Xác nhận mật khẩu mới</label>
                                    <input type="password" name="confirmPassword" 
                                           placeholder="Nhập lại mật khẩu mới" required>
                                </div>
                                
                                <button type="submit" class="site-btn">Đặt Lại Mật Khẩu</button>
                            </form>
                        <% } %>
                        
                        <div class="forgot-links">
                            <p><a href="login"><i class="fa fa-arrow-left"></i> Quay lại đăng nhập</a></p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
    <!-- Forgot Password Section End -->

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
