<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
    <!-- Page Preloder -->
    <div id="preloder">
        <div class="loader"></div>
    </div>

    <!-- Header Section Begin -->
    <header class="header">
        <div class="header__top">
            <div class="container">
                <div class="row">
                    <div class="col-lg-6 col-md-7">
                        <div class="header__top__left">
                            <p>Miễn phí vận chuyển, đổi trả trong 30 ngày</p>
                        </div>
                    </div>
                    <div class="col-lg-6 col-md-5">
                        <div class="header__top__right">
                            <div class="header__top__links">
                                <a href="login">Đăng nhập</a>
                                <a href="#">FAQs</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="container">
            <div class="row">
                <div class="col-lg-3 col-md-3">
                    <div class="header__logo">
                        <a href="./index.html"><img src="img/logo.png" alt=""></a>
                    </div>
                </div>
                <div class="col-lg-6 col-md-6">
                    <nav class="header__menu mobile-menu">
                        <ul>
                            <li><a href="./index.html">Trang chủ</a></li>
                            <li><a href="./shop.html">Sản phẩm</a></li>
                            <li><a href="./blog.html">Blog</a></li>
                            <li><a href="./contact.html">Liên hệ</a></li>
                        </ul>
                    </nav>
                </div>
                <div class="col-lg-3 col-md-3">
                    <div class="header__nav__option">
                        <a href="#" class="search-switch"><img src="img/icon/search.png" alt=""></a>
                        <a href="#"><img src="img/icon/heart.png" alt=""></a>
                        <a href="#"><img src="img/icon/cart.png" alt=""> <span>0</span></a>
                        <div class="price">$0.00</div>
                    </div>
                </div>
            </div>
            <div class="canvas__open"><i class="fa fa-bars"></i></div>
        </div>
    </header>
    <!-- Header Section End -->

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

    <!-- Footer Section Begin -->
    <footer class="footer">
        <div class="container">
            <div class="row">
                <div class="col-lg-3 col-md-6 col-sm-6">
                    <div class="footer__about">
                        <div class="footer__logo">
                            <a href="#"><img src="img/footer-logo.png" alt=""></a>
                        </div>
                        <p>Pickleball Shop - Cửa hàng vợt và phụ kiện Pickleball hàng đầu Việt Nam.</p>
                        <a href="#"><img src="img/payment.png" alt=""></a>
                    </div>
                </div>
                <div class="col-lg-2 offset-lg-1 col-md-3 col-sm-6">
                    <div class="footer__widget">
                        <h6>Mua sắm</h6>
                        <ul>
                            <li><a href="#">Vợt Pickleball</a></li>
                            <li><a href="#">Bóng</a></li>
                            <li><a href="#">Phụ kiện</a></li>
                            <li><a href="#">Sale</a></li>
                        </ul>
                    </div>
                </div>
                <div class="col-lg-2 col-md-3 col-sm-6">
                    <div class="footer__widget">
                        <h6>Hỗ trợ</h6>
                        <ul>
                            <li><a href="#">Liên hệ</a></li>
                            <li><a href="#">Thanh toán</a></li>
                            <li><a href="#">Vận chuyển</a></li>
                            <li><a href="#">Đổi trả</a></li>
                        </ul>
                    </div>
                </div>
                <div class="col-lg-3 offset-lg-1 col-md-6 col-sm-6">
                    <div class="footer__widget">
                        <h6>Nhận tin khuyến mãi</h6>
                        <div class="footer__newslatter">
                            <p>Đăng ký để nhận thông tin sản phẩm mới và ưu đãi!</p>
                            <form action="#">
                                <input type="text" placeholder="Email của bạn">
                                <button type="submit"><span class="icon_mail_alt"></span></button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12 text-center">
                    <div class="footer__copyright__text">
                        <p>Copyright © <script>document.write(new Date().getFullYear());</script> Pickleball Shop Vietnam</p>
                    </div>
                </div>
            </div>
        </div>
    </footer>
    <!-- Footer Section End -->

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
