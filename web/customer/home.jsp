<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entity.Customer" %>
<%
    Customer customer = (Customer) session.getAttribute("customer");
    if (customer == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Trang chủ - <%= customer.getFullName() %></title>

    <!-- Google Font -->
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">

    <!-- Css Styles -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/elegant-icons.css" type="text/css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/magnific-popup.css" type="text/css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/nice-select.css" type="text/css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/owl.carousel.min.css" type="text/css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/slicknav.min.css" type="text/css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css" type="text/css">
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
                            <p>Xin chào, <strong><%= customer.getFullName() %></strong>!</p>
                        </div>
                    </div>
                    <div class="col-lg-6 col-md-5">
                        <div class="header__top__right">
                            <div class="header__top__links">
                                <a href="<%= request.getContextPath() %>/customer/profile"><i class="fa fa-user"></i> Tài khoản</a>
                                <a href="<%= request.getContextPath() %>/logout"><i class="fa fa-sign-out"></i> Đăng xuất</a>
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
                        <a href="<%= request.getContextPath() %>/customer/home"><img src="<%= request.getContextPath() %>/img/logo.png" alt=""></a>
                    </div>
                </div>
                <div class="col-lg-6 col-md-6">
                    <nav class="header__menu mobile-menu">
                        <ul>
                            <li class="active"><a href="<%= request.getContextPath() %>/customer/home">Home</a></li>
                            <li><a href="<%= request.getContextPath() %>/customer/shop">Shop</a></li>
                            <li><a href="<%= request.getContextPath() %>/customer/orders">Blog</a></li>
                            <li><a href="<%= request.getContextPath() %>/customer/wishlist">Contact</a></li>
                        </ul>
                    </nav>
                </div>
                <div class="col-lg-3 col-md-3">
                    <div class="header__nav__option">
                        <a href="#" class="search-switch"><img src="<%= request.getContextPath() %>/img/icon/search.png" alt=""></a>
                        <a href="<%= request.getContextPath() %>/customer/wishlist"><img src="<%= request.getContextPath() %>/img/icon/heart.png" alt=""></a>
                        <a href="<%= request.getContextPath() %>/customer/cart"><img src="<%= request.getContextPath() %>/img/icon/cart.png" alt=""> <span>0</span></a>
                        <div class="price">$0.00</div>
                    </div>
                </div>
            </div>
            <div class="canvas__open"><i class="fa fa-bars"></i></div>
        </div>
    </header>
    <!-- Header Section End -->

    <!-- Hero Section Begin -->
    <section class="hero">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="hero__text" style="text-align: center; padding: 100px 0;">
                        <h2>Chào mừng <%= customer.getFullName() %>!</h2>
                        <p>Đây là trang chủ riêng của bạn. Chỉ bạn mới có thể truy cập trang này.</p>
                        <div style="margin-top: 30px;">
                            <a href="<%= request.getContextPath() %>/customer/shop" class="primary-btn">Mua sắm ngay <span class="arrow_right"></span></a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
    <!-- Hero Section End -->

    <!-- Customer Info Section Begin -->
    <section class="spad">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="section-title">
                        <h4>Thông tin tài khoản</h4>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-4 col-md-6">
                    <div class="card" style="padding: 30px; text-align: center; box-shadow: 0 0 20px rgba(0,0,0,0.05);">
                        <i class="fa fa-user" style="font-size: 48px; color: #ca1515; margin-bottom: 20px;"></i>
                        <h5>Họ và tên</h5>
                        <p><%= customer.getFullName() %></p>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="card" style="padding: 30px; text-align: center; box-shadow: 0 0 20px rgba(0,0,0,0.05);">
                        <i class="fa fa-envelope" style="font-size: 48px; color: #ca1515; margin-bottom: 20px;"></i>
                        <h5>Email</h5>
                        <p><%= customer.getEmail() %></p>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="card" style="padding: 30px; text-align: center; box-shadow: 0 0 20px rgba(0,0,0,0.05);">
                        <i class="fa fa-phone" style="font-size: 48px; color: #ca1515; margin-bottom: 20px;"></i>
                        <h5>Số điện thoại</h5>
                        <p><%= customer.getPhone() != null ? customer.getPhone() : "Chưa cập nhật" %></p>
                    </div>
                </div>
            </div>
        </div>
    </section>
    <!-- Customer Info Section End -->

    <!-- Footer Section Begin -->
    <footer class="footer">
        <div class="container">
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
    <script src="<%= request.getContextPath() %>/js/jquery-3.3.1.min.js"></script>
    <script src="<%= request.getContextPath() %>/js/bootstrap.min.js"></script>
    <script src="<%= request.getContextPath() %>/js/jquery.nice-select.min.js"></script>
    <script src="<%= request.getContextPath() %>/js/jquery.nicescroll.min.js"></script>
    <script src="<%= request.getContextPath() %>/js/jquery.magnific-popup.min.js"></script>
    <script src="<%= request.getContextPath() %>/js/jquery.countdown.min.js"></script>
    <script src="<%= request.getContextPath() %>/js/jquery.slicknav.js"></script>
    <script src="<%= request.getContextPath() %>/js/mixitup.min.js"></script>
    <script src="<%= request.getContextPath() %>/js/owl.carousel.min.js"></script>
    <script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>
