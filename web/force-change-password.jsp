<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Đổi mật khẩu - Pickleball Shop</title>

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
        .change-password-section {
            padding: 80px 0;
            min-height: 600px;
        }
        .change-password-form {
            max-width: 500px;
            margin: 0 auto;
            background: #fff;
            padding: 50px;
            border-radius: 5px;
            box-shadow: 0 0 20px rgba(0,0,0,0.05);
        }
        .change-password-form h3 {
            text-align: center;
            margin-bottom: 10px;
            font-weight: 700;
            color: #111;
        }
        .change-password-form p {
            text-align: center;
            color: #666;
            margin-bottom: 30px;
        }
        .change-password-form .form-group {
            margin-bottom: 25px;
        }
        .change-password-form label {
            font-weight: 600;
            color: #111;
            margin-bottom: 10px;
        }
        .change-password-form input[type="password"] {
            width: 100%;
            height: 50px;
            border: 1px solid #e1e1e1;
            padding: 0 20px;
            font-size: 14px;
            border-radius: 4px;
        }
        .change-password-form input:focus {
            border-color: #ca1515;
            outline: none;
        }
        .change-password-form .site-btn {
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
        .change-password-form .site-btn:hover {
            background: #111;
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
        .alert-info {
            background-color: #d1ecf1;
            border: 1px solid #bee5eb;
            color: #0c5460;
        }
        .password-requirements {
            font-size: 12px;
            color: #666;
            margin-top: 5px;
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
                        <h4>Đổi Mật Khẩu</h4>
                        <div class="breadcrumb__links">
                            <a href="./index.html">Trang chủ</a>
                            <span>Đổi mật khẩu</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
    <!-- Breadcrumb Section End -->

    <!-- Change Password Section Begin -->
    <section class="change-password-section">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="change-password-form">
                        <h3>Đổi Mật Khẩu</h3>
                        <p>Đây là lần đăng nhập đầu tiên của bạn. Vui lòng đổi mật khẩu để tiếp tục.</p>
                        
                        <div class="alert alert-info">
                            <i class="fa fa-info-circle"></i> 
                            Vì lý do bảo mật, bạn cần đặt mật khẩu mới trước khi sử dụng hệ thống.
                        </div>
                        
                        <% if (request.getAttribute("error") != null) { %>
                            <div class="alert alert-danger">
                                <%= request.getAttribute("error") %>
                            </div>
                        <% } %>
                        
                        <form action="force-change-password" method="post" id="changePasswordForm">
                            <div class="form-group">
                                <label>Mật khẩu mới <span class="text-danger">*</span></label>
                                <input type="password" name="newPassword" id="newPassword"
                                       placeholder="Nhập mật khẩu mới" required minlength="6">
                                <div class="password-requirements">
                                    Mật khẩu phải có ít nhất 6 ký tự
                                </div>
                            </div>
                            
                            <div class="form-group">
                                <label>Xác nhận mật khẩu mới <span class="text-danger">*</span></label>
                                <input type="password" name="confirmPassword" id="confirmPassword"
                                       placeholder="Nhập lại mật khẩu mới" required minlength="6">
                            </div>
                            
                            <button type="submit" class="site-btn">Đổi Mật Khẩu</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </section>
    <!-- Change Password Section End -->

    <%@include file="footer.jsp"%>

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
    
    <script>
        document.getElementById('changePasswordForm').addEventListener('submit', function(e) {
            var newPassword = document.getElementById('newPassword').value;
            var confirmPassword = document.getElementById('confirmPassword').value;
            
            if (newPassword.length < 6) {
                e.preventDefault();
                alert('Mật khẩu phải có ít nhất 6 ký tự!');
                return false;
            }
            
            if (newPassword !== confirmPassword) {
                e.preventDefault();
                alert('Mật khẩu xác nhận không khớp!');
                return false;
            }
            
            return true;
        });
    </script>
</body>
</html>
