<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Cửa hàng - Pickleball Shop</title>

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
        .shop__sidebar {
            background: #f8f9fa;
            padding: 30px;
            border-radius: 8px;
        }
        
        .shop__sidebar__title {
            font-size: 18px;
            font-weight: 700;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #e1e1e1;
        }
        
        .shop__sidebar__filter {
            margin-bottom: 30px;
        }
        
        .shop__sidebar__filter label {
            display: block;
            margin-bottom: 10px;
            cursor: pointer;
            font-size: 14px;
            color: #666;
        }
        
        .shop__sidebar__filter input[type="checkbox"] {
            margin-right: 8px;
        }
        
        .shop__sidebar__filter input[type="checkbox"]:checked + span {
            color: #ca1515;
            font-weight: 600;
        }
        
        .shop__product__option {
            margin-bottom: 30px;
        }
        
        .shop__product__option__right {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 15px;
        }
        
        .shop__product__option__right p {
            margin: 0;
            color: #666;
            font-size: 14px;
        }
        
        .shop__product__option__right select {
            padding: 8px 15px;
            border: 1px solid #e1e1e1;
            border-radius: 4px;
            font-size: 14px;
        }
        
        .product__discount__percent {
            position: absolute;
            top: 10px;
            right: 10px;
            background: #ca1515;
            color: white;
            padding: 5px 10px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 600;
        }
        
        .product__price__old {
            text-decoration: line-through;
            color: #999;
            font-size: 14px;
            margin-right: 10px;
        }
        
        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 5px;
            margin-top: 40px;
        }
        
        .pagination a,
        .pagination span {
            display: inline-block;
            padding: 8px 15px;
            border: 1px solid #e1e1e1;
            border-radius: 4px;
            color: #666;
            text-decoration: none;
            transition: all 0.3s;
        }
        
        .pagination a:hover {
            background: #ca1515;
            color: white;
            border-color: #ca1515;
        }
        
        .pagination .active {
            background: #ca1515;
            color: white;
            border-color: #ca1515;
        }
        
        .pagination .disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
        
        .search-box {
            margin-bottom: 20px;
        }
        
        .search-box input {
            width: 100%;
            padding: 10px 15px;
            border: 1px solid #e1e1e1;
            border-radius: 4px;
            font-size: 14px;
        }
        
        .search-box button {
            width: 100%;
            margin-top: 10px;
            padding: 10px;
            background: #ca1515;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 600;
        }
        
        .search-box button:hover {
            background: #a01010;
        }
        
        .filter-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-bottom: 20px;
        }
        
        .filter-tag {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 6px 12px;
            background: #f0f0f0;
            border-radius: 20px;
            font-size: 13px;
            color: #666;
        }
        
        .filter-tag .remove {
            cursor: pointer;
            color: #ca1515;
            font-weight: bold;
        }
        
        .clear-filters {
            color: #ca1515;
            cursor: pointer;
            font-size: 13px;
            text-decoration: underline;
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
                        <h4>Cửa hàng</h4>
                        <div class="breadcrumb__links">
                            <a href="${pageContext.request.contextPath}/">Trang chủ</a>
                            <span>Cửa hàng</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
    <!-- Breadcrumb Section End -->

    <!-- Success Message -->
    <c:if test="${param.success == 'added_to_cart'}">
        <div class="container mt-3">
            <div class="alert alert-success alert-dismissible fade show">
                <button type="button" class="close" data-dismiss="alert">&times;</button>
                <i class="fa fa-check-circle"></i> Đã thêm sản phẩm vào giỏ hàng! 
                <a href="${pageContext.request.contextPath}/cart" class="alert-link">Xem giỏ hàng</a>
            </div>
        </div>
    </c:if>

    <!-- Shop Section Begin -->
    <section class="shop spad">
        <div class="container">
            <div class="row">
                <!-- Sidebar Filter -->
                <div class="col-lg-3">
                    <div class="shop__sidebar">
                        <!-- Search Box -->
                        <div class="search-box">
                            <form action="${pageContext.request.contextPath}/shop" method="get">
                                <input type="text" name="search" placeholder="Tìm kiếm sản phẩm..." value="${search}">
                                <input type="hidden" name="categoryId" value="${categoryId}">
                                <input type="hidden" name="brandId" value="${brandId}">
                                <input type="hidden" name="minPrice" value="${minPrice}">
                                <input type="hidden" name="maxPrice" value="${maxPrice}">
                                <input type="hidden" name="sortBy" value="${sortBy}">
                                <input type="hidden" name="sortOrder" value="${sortOrder}">
                                <button type="submit">
                                    <i class="fa fa-search"></i> Tìm kiếm
                                </button>
                            </form>
                        </div>
                        
                        <!-- Active Filters -->
                        <c:if test="${not empty search || not empty categoryId || not empty brandId || not empty minPrice || not empty maxPrice}">
                            <div class="filter-tags">
                                <c:if test="${not empty search}">
                                    <div class="filter-tag">
                                        <span>Tìm: "${search}"</span>
                                        <a href="${pageContext.request.contextPath}/shop?categoryId=${categoryId}&brandId=${brandId}&minPrice=${minPrice}&maxPrice=${maxPrice}&sortBy=${sortBy}&sortOrder=${sortOrder}" class="remove">×</a>
                                    </div>
                                </c:if>
                                <c:if test="${not empty minPrice || not empty maxPrice}">
                                    <div class="filter-tag">
                                        <span>Giá: 
                                            <c:choose>
                                                <c:when test="${not empty minPrice && not empty maxPrice}">
                                                    <fmt:formatNumber value="${minPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫ - <fmt:formatNumber value="${maxPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                                </c:when>
                                                <c:when test="${not empty minPrice}">
                                                    Trên <fmt:formatNumber value="${minPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                                </c:when>
                                                <c:otherwise>
                                                    Dưới <fmt:formatNumber value="${maxPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                                </c:otherwise>
                                            </c:choose>
                                        </span>
                                        <a href="${pageContext.request.contextPath}/shop?search=${search}&categoryId=${categoryId}&brandId=${brandId}&sortBy=${sortBy}&sortOrder=${sortOrder}" class="remove">×</a>
                                    </div>
                                </c:if>
                                <a href="${pageContext.request.contextPath}/shop" class="clear-filters">Xóa tất cả bộ lọc</a>
                            </div>
                        </c:if>
                        
                        <!-- Category Filter -->
                        <div class="shop__sidebar__filter">
                            <h5 class="shop__sidebar__title">DANH MỤC</h5>
                            <c:forEach var="cat" items="${categoriesForFilter}">
                                <label>
                                    <input type="checkbox" 
                                           onchange="filterByCategory(${cat.categoryID})"
                                           ${categoryId == cat.categoryID ? 'checked' : ''}>
                                    <span>${cat.categoryName}</span>
                                </label>
                            </c:forEach>
                        </div>
                        
                        <!-- Brand Filter -->
                        <div class="shop__sidebar__filter">
                            <h5 class="shop__sidebar__title">THƯƠNG HIỆU</h5>
                            <c:forEach var="brand" items="${brands}">
                                <label>
                                    <input type="checkbox" 
                                           onchange="filterByBrand(${brand.brandID})"
                                           ${brandId == brand.brandID ? 'checked' : ''}>
                                    <span>${brand.brandName}</span>
                                </label>
                            </c:forEach>
                        </div>
                        
                        <!-- Price Filter -->
                        <div class="shop__sidebar__filter">
                            <h5 class="shop__sidebar__title">KHOẢNG GIÁ</h5>
                            <label>
                                <input type="radio" name="priceRange" value="" 
                                       onchange="filterByPrice('', '')"
                                       ${empty minPrice && empty maxPrice ? 'checked' : ''}>
                                <span>Tất cả</span>
                            </label>
                            <label>
                                <input type="radio" name="priceRange" value="0-500000" 
                                       onchange="filterByPrice(0, 500000)"
                                       ${minPrice == '0' && maxPrice == '500000' ? 'checked' : ''}>
                                <span>Dưới 500.000₫</span>
                            </label>
                            <label>
                                <input type="radio" name="priceRange" value="500000-1000000" 
                                       onchange="filterByPrice(500000, 1000000)"
                                       ${minPrice == '500000' && maxPrice == '1000000' ? 'checked' : ''}>
                                <span>500.000₫ - 1.000.000₫</span>
                            </label>
                            <label>
                                <input type="radio" name="priceRange" value="1000000-2000000" 
                                       onchange="filterByPrice(1000000, 2000000)"
                                       ${minPrice == '1000000' && maxPrice == '2000000' ? 'checked' : ''}>
                                <span>1.000.000₫ - 2.000.000₫</span>
                            </label>
                            <label>
                                <input type="radio" name="priceRange" value="2000000-5000000" 
                                       onchange="filterByPrice(2000000, 5000000)"
                                       ${minPrice == '2000000' && maxPrice == '5000000' ? 'checked' : ''}>
                                <span>2.000.000₫ - 5.000.000₫</span>
                            </label>
                            <label>
                                <input type="radio" name="priceRange" value="5000000-" 
                                       onchange="filterByPrice(5000000, '')"
                                       ${minPrice == '5000000' && empty maxPrice ? 'checked' : ''}>
                                <span>Trên 5.000.000₫</span>
                            </label>
                        </div>
                    </div>
                </div>

                <!-- Products Grid -->
                <div class="col-lg-9">
                    <!-- Sort and Display Options -->
                    <div class="shop__product__option">
                        <div class="row">
                            <div class="col-lg-6 col-md-6 col-sm-6">
                                <p>Hiển thị ${(currentPage - 1) * pageSize + 1}–${currentPage * pageSize > totalProducts ? totalProducts : currentPage * pageSize} trong tổng số ${totalProducts} sản phẩm</p>
                            </div>
                            <div class="col-lg-6 col-md-6 col-sm-6">
                                <div class="shop__product__option__right">
                                    <p>Sắp xếp:</p>
                                    <select onchange="sortProducts(this.value)">
                                        <option value="date-desc" ${sortBy == 'date' && sortOrder == 'desc' ? 'selected' : ''}>Mới nhất</option>
                                        <option value="date-asc" ${sortBy == 'date' && sortOrder == 'asc' ? 'selected' : ''}>Cũ nhất</option>
                                        <option value="name-asc" ${sortBy == 'name' && sortOrder == 'asc' ? 'selected' : ''}>Tên A → Z</option>
                                        <option value="name-desc" ${sortBy == 'name' && sortOrder == 'desc' ? 'selected' : ''}>Tên Z → A</option>
                                        <option value="price-asc" ${sortBy == 'price' && sortOrder == 'asc' ? 'selected' : ''}>Giá thấp → cao</option>
                                        <option value="price-desc" ${sortBy == 'price' && sortOrder == 'desc' ? 'selected' : ''}>Giá cao → thấp</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Products -->
                    <div class="row">
                        <c:forEach var="product" items="${products}">
                            <div class="col-lg-4 col-md-6 col-sm-6">
                                <div class="product__item" style="cursor: pointer;" onclick="window.location.href='${pageContext.request.contextPath}/product-detail?id=${product.productID}'">
                                    <div class="product__item__pic set-bg" data-setbg="${not empty product.mainImageUrl ? pageContext.request.contextPath.concat(product.mainImageUrl) : pageContext.request.contextPath.concat('/img/product/default.jpg')}">
                                        <!-- Promotion Badge -->
                                        <c:if test="${product.hasPromotion}">
                                            <div class="product__discount__percent">
                                                -${product.discountPercent}%
                                            </div>
                                        </c:if>
                                        
                                        <!-- Stock Status Label -->
                                        <c:choose>
                                            <c:when test="${product.variantCount == 0}">
                                                <span class="label" style="background: #ffc107; color: #111;">Sắp ra mắt</span>
                                            </c:when>
                                            <c:when test="${product.totalStock == 0}">
                                                <span class="label" style="background: #dc3545; color: #fff;">Hết hàng</span>
                                            </c:when>
                                            <c:when test="${product.totalStock <= 10}">
                                                <span class="label" style="background: #fd7e14; color: #fff;">Sắp hết</span>
                                            </c:when>
                                            <c:when test="${!product.hasPromotion}">
                                                <span class="label">New</span>
                                            </c:when>
                                        </c:choose>
                                        
                                        <ul class="product__hover">
                                            <li><a href="javascript:void(0)" onclick="event.stopPropagation(); toggleWishlist(${product.productID}, this)" class="wishlist-btn" data-product-id="${product.productID}"><img src="${pageContext.request.contextPath}/img/icon/heart.png" alt="Wishlist"></a></li>
                                            <li><a href="${pageContext.request.contextPath}/product-detail?id=${product.productID}" onclick="event.stopPropagation()"><img src="${pageContext.request.contextPath}/img/icon/search.png" alt="View"></a></li>
                                        </ul>
                                    </div>
                                    <div class="product__item__text">
                                        <c:if test="${not empty product.brandName}">
                                            <span class="product__brand">${product.brandName}</span>
                                        </c:if>
                                        <h6><a href="${pageContext.request.contextPath}/product-detail?id=${product.productID}">${product.productName}</a></h6>
                                        <a href="${pageContext.request.contextPath}/cart/add?productId=${product.productID}&source=shop" class="add-cart">+ Add To Cart</a>
                                        
                                        <!-- Price with Promotion -->
                                        <h5>
                                            <c:choose>
                                                <c:when test="${product.minPrice != null}">
                                                    <c:choose>
                                                        <c:when test="${product.hasPromotion}">
                                                            <span class="product__price__old">
                                                                <fmt:formatNumber value="${product.minPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                                            </span>
                                                            <span style="color: #ca1515; font-weight: 700;">
                                                                <fmt:formatNumber value="${product.finalPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <fmt:formatNumber value="${product.minPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:when>
                                                <c:otherwise>
                                                    Liên hệ
                                                </c:otherwise>
                                            </c:choose>
                                        </h5>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                        
                        <!-- No products message -->
                        <c:if test="${empty products}">
                            <div class="col-12 text-center py-5">
                                <i class="fa fa-inbox" style="font-size: 48px; color: #ccc; margin-bottom: 20px;"></i>
                                <p class="text-muted">Không tìm thấy sản phẩm nào phù hợp với bộ lọc của bạn.</p>
                                <a href="${pageContext.request.contextPath}/shop" class="primary-btn">Xóa bộ lọc</a>
                            </div>
                        </c:if>
                    </div>

                    <!-- Pagination -->
                    <div class="pagination">
                        <!-- Previous -->
                        <c:choose>
                            <c:when test="${currentPage > 1}">
                                <a href="?page=${currentPage - 1}&search=${search}&categoryId=${categoryId}&brandId=${brandId}&minPrice=${minPrice}&maxPrice=${maxPrice}&sortBy=${sortBy}&sortOrder=${sortOrder}">
                                    <i class="fa fa-chevron-left"></i>
                                </a>
                            </c:when>
                            <c:otherwise>
                                <span class="disabled"><i class="fa fa-chevron-left"></i></span>
                            </c:otherwise>
                        </c:choose>
                        
                        <!-- Page numbers -->
                        <c:forEach begin="1" end="${totalPages > 0 ? totalPages : 1}" var="i">
                            <c:choose>
                                <c:when test="${i == currentPage || (currentPage == null && i == 1)}">
                                    <span class="active">${i}</span>
                                </c:when>
                                <c:when test="${i == 1 || i == totalPages || (i >= currentPage - 2 && i <= currentPage + 2)}">
                                    <a href="?page=${i}&search=${search}&categoryId=${categoryId}&brandId=${brandId}&minPrice=${minPrice}&maxPrice=${maxPrice}&sortBy=${sortBy}&sortOrder=${sortOrder}">${i}</a>
                                </c:when>
                                <c:when test="${i == 2 && currentPage > 4}">
                                    <span>...</span>
                                </c:when>
                                <c:when test="${i == totalPages - 1 && currentPage < totalPages - 3}">
                                    <span>...</span>
                                </c:when>
                            </c:choose>
                        </c:forEach>
                        
                        <!-- Next -->
                        <c:choose>
                            <c:when test="${currentPage < totalPages}">
                                <a href="?page=${currentPage + 1}&search=${search}&categoryId=${categoryId}&brandId=${brandId}&minPrice=${minPrice}&maxPrice=${maxPrice}&sortBy=${sortBy}&sortOrder=${sortOrder}">
                                    <i class="fa fa-chevron-right"></i>
                                </a>
                            </c:when>
                            <c:otherwise>
                                <span class="disabled"><i class="fa fa-chevron-right"></i></span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>
    </section>
    <!-- Shop Section End -->

    <%@include file="footer.jsp" %>

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
        // Filter by category
        function filterByCategory(categoryId) {
            const currentParams = new URLSearchParams(window.location.search);
            const currentCategoryId = currentParams.get('categoryId');
            
            if (currentCategoryId == categoryId) {
                // Uncheck - remove filter
                currentParams.delete('categoryId');
            } else {
                // Check - add filter
                currentParams.set('categoryId', categoryId);
            }
            
            currentParams.set('page', '1'); // Reset to page 1
            window.location.href = '${pageContext.request.contextPath}/shop?' + currentParams.toString();
        }
        
        // Filter by brand
        function filterByBrand(brandId) {
            const currentParams = new URLSearchParams(window.location.search);
            const currentBrandId = currentParams.get('brandId');
            
            if (currentBrandId == brandId) {
                // Uncheck - remove filter
                currentParams.delete('brandId');
            } else {
                // Check - add filter
                currentParams.set('brandId', brandId);
            }
            
            currentParams.set('page', '1'); // Reset to page 1
            window.location.href = '${pageContext.request.contextPath}/shop?' + currentParams.toString();
        }
        
        // Sort products
        function sortProducts(value) {
            const [sortBy, sortOrder] = value.split('-');
            const currentParams = new URLSearchParams(window.location.search);
            
            currentParams.set('sortBy', sortBy);
            currentParams.set('sortOrder', sortOrder);
            currentParams.set('page', '1'); // Reset to page 1
            
            window.location.href = '${pageContext.request.contextPath}/shop?' + currentParams.toString();
        }
        
        // Filter by price range
        function filterByPrice(minPrice, maxPrice) {
            const currentParams = new URLSearchParams(window.location.search);
            
            if (minPrice === '' && maxPrice === '') {
                currentParams.delete('minPrice');
                currentParams.delete('maxPrice');
            } else {
                if (minPrice !== '') {
                    currentParams.set('minPrice', minPrice);
                } else {
                    currentParams.delete('minPrice');
                }
                if (maxPrice !== '') {
                    currentParams.set('maxPrice', maxPrice);
                } else {
                    currentParams.delete('maxPrice');
                }
            }
            
            currentParams.set('page', '1'); // Reset to page 1
            window.location.href = '${pageContext.request.contextPath}/shop?' + currentParams.toString();
        }
    </script>
    
    <!-- Auto-hide success message and update cart count -->
    <script>
        // Auto-hide alert after 5 seconds
        setTimeout(function() {
            $('.alert').fadeOut('slow');
        }, 5000);
        
        // Update cart count in header when product added
        <c:if test="${param.success == 'added_to_cart'}">
            if (typeof window.updateCartHeader === 'function') {
                window.updateCartHeader();
            }
        </c:if>
        
        // Wishlist toggle function
        function toggleWishlist(productId, element) {
            $.ajax({
                url: '${pageContext.request.contextPath}/wishlist',
                type: 'POST',
                data: { action: 'toggle', productId: productId },
                dataType: 'json',
                success: function(res) {
                    if (res.login) {
                        window.location.href = '${pageContext.request.contextPath}/login?redirect=shop';
                        return;
                    }
                    if (res.success) {
                        if (res.added) {
                            $(element).addClass('wishlisted');
                            showToast('Đã thêm vào yêu thích', 'success');
                        } else {
                            $(element).removeClass('wishlisted');
                            showToast('Đã xóa khỏi yêu thích', 'info');
                        }
                    } else {
                        showToast(res.message || 'Có lỗi xảy ra', 'error');
                    }
                },
                error: function() {
                    showToast('Có lỗi xảy ra, vui lòng thử lại', 'error');
                }
            });
        }
        
        function showToast(message, type) {
            var toast = $('<div class="toast-notification"></div>');
            toast.css({
                'position': 'fixed', 'top': '20px', 'right': '20px',
                'padding': '15px 25px', 'border-radius': '8px', 'color': '#fff',
                'font-weight': '500', 'z-index': '9999', 'animation': 'slideIn 0.3s ease'
            });
            toast.css('background', type === 'success' ? '#28a745' : type === 'error' ? '#dc3545' : '#17a2b8');
            toast.text(message);
            $('body').append(toast);
            setTimeout(function() { toast.fadeOut(function() { $(this).remove(); }); }, 3000);
        }
    </script>
    <style>
        @keyframes slideIn { from { transform: translateX(100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
        .wishlist-btn.wishlisted { background: #ca1515 !important; border-radius: 50%; }
        .wishlist-btn.wishlisted img { filter: brightness(0) invert(1); }
    </style>
</body>
</html>
