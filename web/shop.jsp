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
            flex-wrap: wrap;
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
        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 5px;
            margin-top: 40px;
        }
        .pagination a, .pagination span {
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
        /* Hide hover effect that shows product name */
        .product__item .product__hover {
            display: none !important;
            visibility: hidden !important;
            opacity: 0 !important;
        }
        .product__item:hover .product__hover {
            display: none !important;
            visibility: hidden !important;
            opacity: 0 !important;
        }
        .product__item:hover .product__item__pic:before,
        .product__item:hover .product__item__pic:after {
            display: none !important;
            opacity: 0 !important;
            background: transparent !important;
        }
        .product__item__pic:before,
        .product__item__pic:after {
            display: none !important;
        }
        /* Product name styling - FORCE VISIBLE */
        .product__item__text h6 {
            display: block !important;
            visibility: visible !important;
            opacity: 1 !important;
            margin-bottom: 8px !important;
            min-height: 40px;
            position: relative !important;
        }
        .product__item:hover .product__item__text h6 {
            display: block !important;
            visibility: visible !important;
            opacity: 1 !important;
        }
        .product__item__text h6 a {
            color: #111 !important;
            font-size: 14px !important;
            line-height: 1.4;
            font-weight: 600;
            display: inline !important;
            visibility: visible !important;
            opacity: 1 !important;
        }
        .product__item__text h6 a:hover {
            color: #ca1515 !important;
        }
        /* Price styling */
        .product-price {
            color: #ca1515 !important;
            font-weight: 600 !important;
            font-size: 14px !important;
            margin-bottom: 5px !important;
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
                                <input type="hidden" name="sortBy" value="${sortBy}">
                                <input type="hidden" name="sortOrder" value="${sortOrder}">
                                <button type="submit">
                                    <i class="fa fa-search"></i> Tìm kiếm
                                </button>
                            </form>
                        </div>
                        
                        <!-- Active Filters -->
                        <c:if test="${not empty search || not empty categoryId || not empty brandId}">
                            <div class="filter-tags">
                                <c:if test="${not empty search}">
                                    <div class="filter-tag">
                                        <span>Tìm: "${search}"</span>
                                        <a href="${pageContext.request.contextPath}/shop?categoryId=${categoryId}&brandId=${brandId}&sortBy=${sortBy}&sortOrder=${sortOrder}" class="remove">×</a>
                                    </div>
                                </c:if>
                                <a href="${pageContext.request.contextPath}/shop" class="clear-filters">Xóa tất cả bộ lọc</a>
                            </div>
                        </c:if>
                        
                        <!-- Category Filter -->
                        <div class="shop__sidebar__filter">
                            <h5 class="shop__sidebar__title">DANH MỤC</h5>
                            <c:forEach var="cat" items="${categories}">
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
                    </div>
                </div>

                <!-- Products Grid -->
                <div class="col-lg-9">
                    <!-- Sort and Display Options -->
                    <div class="shop__product__option">
                        <div class="row">
                            <div class="col-lg-4 col-md-4 col-sm-12">
                                <p>Hiển thị ${(currentPage - 1) * pageSize + 1}–${currentPage * pageSize > totalProducts ? totalProducts : currentPage * pageSize} / ${totalProducts} sản phẩm</p>
                            </div>
                            <div class="col-lg-8 col-md-8 col-sm-12">
                                <div class="shop__product__option__right">
                                    <p>Khoảng giá:</p>
                                    <select onchange="filterByPriceRange(this.value)">
                                        <option value="" ${empty minPrice && empty maxPrice ? 'selected' : ''}>Tất cả</option>
                                        <option value="0-500000" ${minPrice == '0' && maxPrice == '500000' ? 'selected' : ''}>Dưới 500K</option>
                                        <option value="500000-1000000" ${minPrice == '500000' && maxPrice == '1000000' ? 'selected' : ''}>500K - 1 triệu</option>
                                        <option value="1000000-2000000" ${minPrice == '1000000' && maxPrice == '2000000' ? 'selected' : ''}>1 - 2 triệu</option>
                                        <option value="2000000-5000000" ${minPrice == '2000000' && maxPrice == '5000000' ? 'selected' : ''}>2 - 5 triệu</option>
                                        <option value="5000000-" ${minPrice == '5000000' && empty maxPrice ? 'selected' : ''}>Trên 5 triệu</option>
                                    </select>
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
                                        <c:if test="${not empty product.createdDate}">
                                            <jsp:useBean id="now" class="java.util.Date"/>
                                            <c:set var="daysDiff" value="${(now.time - product.createdDate.time) / (1000 * 60 * 60 * 24)}"/>
                                            <c:if test="${daysDiff <= 30}">
                                                <span class="label">New</span>
                                            </c:if>
                                        </c:if>
                                        <c:choose>
                                            <c:when test="${product.variantCount == 0}">
                                                <span class="label" style="background: #17a2b8;">Coming Soon</span>
                                            </c:when>
                                            <c:when test="${product.totalStock == 0}">
                                                <span class="label" style="background: #dc3545;">Hết hàng</span>
                                            </c:when>
                                        </c:choose>
                                    </div>
                                    <div class="product__item__text">
                                        <h6 style="margin-bottom: 8px; min-height: 40px;"><a href="${pageContext.request.contextPath}/product-detail?id=${product.productID}" onclick="event.stopPropagation();">${product.productName}</a></h6>
                                        <c:choose>
                                            <c:when test="${product.minPrice != null && product.maxPrice != null}">
                                                <c:choose>
                                                    <c:when test="${product.minPrice.compareTo(product.maxPrice) == 0}">
                                                        <p class="product-price" style="color: #ca1515; font-weight: 600; font-size: 14px; margin-bottom: 5px;"><fmt:formatNumber value="${product.minPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</p>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <p class="product-price" style="color: #ca1515; font-weight: 600; font-size: 14px; margin-bottom: 5px;"><fmt:formatNumber value="${product.minPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫ - <fmt:formatNumber value="${product.maxPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</p>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:when>
                                            <c:otherwise>
                                                <p class="product-price" style="color: #ca1515; font-weight: 600; font-size: 14px; margin-bottom: 5px;">Liên hệ</p>
                                            </c:otherwise>
                                        </c:choose>
                                        <c:if test="${not empty product.brandName}">
                                            <small style="color: #999; font-size: 11px;">${product.brandName}</small>
                                        </c:if>
                                        <c:if test="${product.totalStock > 0 && product.totalStock <= 10}">
                                            <div style="margin-top: 5px;">
                                                <small style="color: #ff6b6b; font-size: 11px;">
                                                    <i class="fa fa-exclamation-circle"></i> Còn ${product.totalStock} sp
                                                </small>
                                            </div>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                        
                        <c:if test="${empty products}">
                            <div class="col-12 text-center py-5">
                                <i class="fa fa-inbox" style="font-size: 48px; color: #ccc; margin-bottom: 20px;"></i>
                                <p class="text-muted">Không tìm thấy sản phẩm nào phù hợp với bộ lọc của bạn.</p>
                                <a href="${pageContext.request.contextPath}/shop" class="primary-btn">Xóa bộ lọc</a>
                            </div>
                        </c:if>
                    </div>

                    <!-- Pagination -->
                    <c:if test="${totalPages >= 1}">
                        <div class="pagination">
                            <c:choose>
                                <c:when test="${currentPage > 1}">
                                    <a href="?page=${currentPage - 1}&search=${search}&categoryId=${categoryId}&brandId=${brandId}&minPrice=${minPrice}&maxPrice=${maxPrice}&sortBy=${sortBy}&sortOrder=${sortOrder}" style="min-width: 80px; text-align: center;">Trước</a>
                                </c:when>
                                <c:otherwise>
                                    <span class="disabled" style="min-width: 80px; text-align: center;">Trước</span>
                                </c:otherwise>
                            </c:choose>
                            
                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <c:choose>
                                    <c:when test="${i == currentPage}">
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
                            
                            <c:choose>
                                <c:when test="${currentPage < totalPages}">
                                    <a href="?page=${currentPage + 1}&search=${search}&categoryId=${categoryId}&brandId=${brandId}&minPrice=${minPrice}&maxPrice=${maxPrice}&sortBy=${sortBy}&sortOrder=${sortOrder}" style="min-width: 80px; text-align: center;">Sau</a>
                                </c:when>
                                <c:otherwise>
                                    <span class="disabled" style="min-width: 80px; text-align: center;">Sau</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>
    </section>

    <%@include file="footer.jsp" %>

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
        function filterByCategory(categoryId) {
            const currentParams = new URLSearchParams(window.location.search);
            const currentCategoryId = currentParams.get('categoryId');
            if (currentCategoryId == categoryId) {
                currentParams.delete('categoryId');
            } else {
                currentParams.set('categoryId', categoryId);
            }
            currentParams.set('page', '1');
            window.location.href = '${pageContext.request.contextPath}/shop?' + currentParams.toString();
        }
        
        function filterByBrand(brandId) {
            const currentParams = new URLSearchParams(window.location.search);
            const currentBrandId = currentParams.get('brandId');
            if (currentBrandId == brandId) {
                currentParams.delete('brandId');
            } else {
                currentParams.set('brandId', brandId);
            }
            currentParams.set('page', '1');
            window.location.href = '${pageContext.request.contextPath}/shop?' + currentParams.toString();
        }
        
        function filterByPriceRange(value) {
            const currentParams = new URLSearchParams(window.location.search);
            currentParams.delete('minPrice');
            currentParams.delete('maxPrice');
            if (value) {
                const [min, max] = value.split('-');
                if (min) currentParams.set('minPrice', min);
                if (max) currentParams.set('maxPrice', max);
            }
            currentParams.set('page', '1');
            window.location.href = '${pageContext.request.contextPath}/shop?' + currentParams.toString();
        }
        
        function sortProducts(value) {
            const [sortBy, sortOrder] = value.split('-');
            const currentParams = new URLSearchParams(window.location.search);
            currentParams.set('sortBy', sortBy);
            currentParams.set('sortOrder', sortOrder);
            currentParams.set('page', '1');
            window.location.href = '${pageContext.request.contextPath}/shop?' + currentParams.toString();
        }
    </script>
</body>
</html>
