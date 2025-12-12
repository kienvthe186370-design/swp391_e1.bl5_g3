<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    // Check user session
    entity.Customer customer = (entity.Customer) session.getAttribute("customer");
    entity.Employee employee = (entity.Employee) session.getAttribute("employee");
    
    boolean isLoggedIn = (customer != null || employee != null);
    String userName = "";
    String userRole = "guest";
    
    if (customer != null) {
        userName = customer.getFullName();
        userRole = "customer";
    } else if (employee != null) {
        userName = employee.getFullName();
        userRole = employee.getRole().toLowerCase();
    }
    
    request.setAttribute("isLoggedIn", isLoggedIn);
    request.setAttribute("userName", userName);
    request.setAttribute("userRole", userRole);
    
    // Get cart info from session
    Integer cartCount = (Integer) session.getAttribute("cartCount");
    java.math.BigDecimal cartTotal = (java.math.BigDecimal) session.getAttribute("cartTotal");
    if (cartCount == null) cartCount = 0;
    if (cartTotal == null) cartTotal = java.math.BigDecimal.ZERO;
%>

<!-- Preloader - will be hidden by main.js -->
<div id="preloder">
    <div class="loader"></div>
</div>
<style>
    /* Preloader styles - ensure it can be hidden */
    #preloder {
        position: fixed;
        width: 100%;
        height: 100%;
        top: 0;
        left: 0;
        background: #000;
        z-index: 999999;
    }
    .loader {
        width: 40px;
        height: 40px;
        position: absolute;
        top: 50%;
        left: 50%;
        margin: -20px 0 0 -20px;
        border: 4px solid #6c5ce7;
        border-top-color: transparent;
        border-radius: 50%;
        animation: spin 1s linear infinite;
    }
    @keyframes spin {
        to { transform: rotate(360deg); }
    }
    /* Auto-hide after 3 seconds as fallback */
    #preloder.loaded, #preloder.loaded .loader {
        display: none !important;
    }
</style>
<script>
    // Auto-hide preloader after 3 seconds as fallback
    setTimeout(function() {
        var p = document.getElementById('preloder');
        if (p) p.classList.add('loaded');
    }, 3000);
</script>

<!-- Offcanvas Menu Begin -->
<div class="offcanvas-menu-overlay"></div>
<div class="offcanvas-menu-wrapper">
    <div class="offcanvas__option">
        <div class="offcanvas__links">
            <c:choose>
                <c:when test="${isLoggedIn}">
                    <a href="<%= request.getContextPath() %>/customer/profile">
                        <i class="fa fa-user"></i> ${userName}
                    </a>
                    <a href="<%= request.getContextPath() %>/logout">Đăng xuất</a>
                </c:when>
                <c:otherwise>
                    <a href="<%= request.getContextPath() %>/login.jsp">Đăng nhập</a>
                    <a href="<%= request.getContextPath() %>/register.jsp">Đăng ký</a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
    <div class="offcanvas__nav__option">
        <a href="#" class="search-switch"><img src="<%= request.getContextPath() %>/img/icon/search.png" alt=""></a>
        <a href="<%= request.getContextPath() %>/wishlist"><img src="<%= request.getContextPath() %>/img/icon/heart.png" alt=""></a>
        <a href="<%= request.getContextPath() %>/cart"><img src="<%= request.getContextPath() %>/img/icon/cart.png" alt=""> <span class="cart-count"><%= cartCount %></span></a>
        <div class="price cart-total">
            <fmt:formatNumber value="<%= cartTotal %>" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
        </div>
    </div>
    <div id="mobile-menu-wrap"></div>
    <div class="offcanvas__text">
        <p>Miễn phí vận chuyển, đổi trả trong 30 ngày.</p>
    </div>
</div>

<!-- Header Begin -->
<header class="header">
    <div class="header__top">
        <div class="container">
            <div class="row">
                <div class="col-lg-6 col-md-7">
                    <div class="header__top__left">
                        <p>Miễn phí vận chuyển, đổi trả trong 30 ngày.</p>
                    </div>
                </div>
                <div class="col-lg-6 col-md-5">
                    <div class="header__top__right">
                        <div class="header__top__links">
                            <c:choose>
                                <c:when test="${isLoggedIn}">
                                    <!-- Admin/Seller/Manager Dashboard -->
                                    <c:if test="${userRole == 'admin'}">
                                        <a href="<%= request.getContextPath() %>/AdminLTE-3.2.0/index.jsp">
                                            <i class="fa fa-tachometer-alt"></i> Admin Dashboard
                                        </a>
                                    </c:if>
                                    <c:if test="${userRole == 'seller'}">
                                        <a href="<%= request.getContextPath() %>/seller/dashboard">
                                            <i class="fa fa-tachometer-alt"></i> Seller Dashboard
                                        </a>
                                    </c:if>
                                    <c:if test="${userRole == 'sellermanager'}">
                                        <a href="<%= request.getContextPath() %>/seller-manager/dashboard">
                                            <i class="fa fa-tachometer-alt"></i> Manager Dashboard
                                        </a>
                                    </c:if>
                                    
                                    <!-- Customer Profile & Actions -->
                                    <c:if test="${userRole == 'customer'}">
                                        <a href="<%= request.getContextPath() %>/customer/profile">
                                            <i class="fa fa-user"></i> ${userName}
                                        </a>
                                        <a href="<%= request.getContextPath() %>/customer/orders">
                                            <i class="fa fa-list-alt"></i> Đơn hàng
                                        </a>
                                    </c:if>
                                    
                                    <a href="<%= request.getContextPath() %>/logout">Đăng xuất</a>
                                </c:when>
                                <c:otherwise>
                                    <a href="<%= request.getContextPath() %>/login.jsp">Đăng nhập</a>
                                    <a href="<%= request.getContextPath() %>/register.jsp">Đăng ký</a>
                                </c:otherwise>
                            </c:choose>
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
                    <a href="<%= request.getContextPath() %>/Home"><img src="<%= request.getContextPath() %>/img/logo.png" alt="Pickleball Shop"></a>
                </div>
            </div>
            <div class="col-lg-6 col-md-6">
                <nav class="header__menu mobile-menu">
                    <ul>
                        <li class="active"><a href="<%= request.getContextPath() %>/Home">Trang chủ</a></li>
                        <li><a href="<%= request.getContextPath() %>/shop">Sản phẩm</a>
                            <ul class="dropdown">
                                <c:forEach var="cat" items="${categories}">
                                    <c:if test="${cat.isActive}">
                                        <li><a href="<%= request.getContextPath() %>/shop?category=${cat.categoryID}">${cat.categoryName}</a></li>
                                    </c:if>
                                </c:forEach>
                            </ul>
                        </li>
                        <li><a href="<%= request.getContextPath() %>/blog">Blog</a></li>
                        <li><a href="<%= request.getContextPath() %>/about.jsp">Giới thiệu</a></li>
                        <li><a href="<%= request.getContextPath() %>/contact.jsp">Liên hệ</a></li>
                    </ul>
                </nav>
            </div>
            <div class="col-lg-3 col-md-3">
                <div class="header__nav__option">
                    <a href="#" class="search-switch"><img src="<%= request.getContextPath() %>/img/icon/search.png" alt=""></a>
                    <a href="<%= request.getContextPath() %>/wishlist"><img src="<%= request.getContextPath() %>/img/icon/heart.png" alt=""></a>
                    <a href="<%= request.getContextPath() %>/cart" class="cart-icon-link">
                        <img src="<%= request.getContextPath() %>/img/icon/cart.png" alt=""> 
                        <span class="cart-count"><%= cartCount %></span>
                    </a>
                    <div class="price cart-total">
                        <fmt:formatNumber value="<%= cartTotal %>" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                    </div>
                </div>
            </div>
        </div>
        <div class="canvas__open"><i class="fa fa-bars"></i></div>
    </div>
</header>
<!-- Header End -->

<!-- Cart Header Update Script -->
<script src="<%= request.getContextPath() %>/js/cart-header.js"></script>
