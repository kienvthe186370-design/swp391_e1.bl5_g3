<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>${product.productName} - Pickleball Shop</title>

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
        :root {
            --primary: #2D5A27;
            --primary-hover: #1E3D1A;
            --accent: #E85A4F;
            --accent-light: #FEF0EF;
            --text-dark: #1A1A1A;
            --text-muted: #6B7280;
            --border: #E5E7EB;
            --bg-light: #F9FAFB;
            --bg-white: #FFFFFF;
            --shadow-sm: 0 1px 2px rgba(0,0,0,0.05);
            --shadow-md: 0 4px 12px rgba(0,0,0,0.08);
            --shadow-lg: 0 8px 24px rgba(0,0,0,0.12);
            --radius-sm: 6px;
            --radius-md: 10px;
            --radius-lg: 16px;
        }

        * { box-sizing: border-box; }

        /* Breadcrumb */
        .breadcrumb-section {
            background: var(--bg-light);
            padding: 16px 0;
            border-bottom: 1px solid var(--border);
        }
        .breadcrumb-nav {
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 8px;
            font-size: 14px;
        }
        .breadcrumb-nav a {
            color: var(--text-muted);
            text-decoration: none;
            transition: color 0.2s;
        }
        .breadcrumb-nav a:hover { color: var(--primary); }
        .breadcrumb-nav span { color: var(--text-muted); }
        .breadcrumb-nav .current { color: var(--text-dark); font-weight: 500; }

        /* Product Section */
        .product-section {
            padding: 40px 0 60px;
            background: var(--bg-white);
        }
        .product-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 48px;
        }

        /* Product Gallery */
        .product-gallery { align-self: start; }
        .main-image-container {
            position: relative;
            background: var(--bg-light);
            border-radius: var(--radius-md);
            overflow: hidden;
            aspect-ratio: 1;
            margin-bottom: 16px;
        }
        .sale-badge {
            position: absolute;
            top: 16px;
            left: 16px;
            background: var(--accent);
            color: white;
            padding: 6px 14px;
            border-radius: var(--radius-sm);
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            z-index: 2;
        }
        .main-image {
            width: 100%;
            height: 100%;
            object-fit: contain;
            padding: 40px;
            transition: transform 0.3s ease;
        }
        .main-image-container:hover .main-image { transform: scale(1.05); }
        .zoom-btn {
            position: absolute;
            bottom: 16px;
            right: 16px;
            background: rgba(255,255,255,0.95);
            border: none;
            padding: 10px 16px;
            border-radius: var(--radius-sm);
            cursor: pointer;
            font-size: 13px;
            font-weight: 600;
            color: var(--text-dark);
            box-shadow: var(--shadow-sm);
            transition: all 0.2s;
            z-index: 2;
        }
        .zoom-btn:hover {
            background: var(--bg-white);
            box-shadow: var(--shadow-md);
        }
        .thumbnail-list {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }
        .thumbnail {
            width: 80px;
            height: 80px;
            border-radius: var(--radius-sm);
            border: 2px solid transparent;
            cursor: pointer;
            overflow: hidden;
            background: var(--bg-light);
            transition: border-color 0.2s;
            padding: 0;
        }
        .thumbnail:hover, .thumbnail.active { border-color: var(--primary); }
        .thumbnail img {
            width: 100%;
            height: 100%;
            object-fit: contain;
            padding: 8px;
        }

        /* Product Info */
        .product-info { padding: 0; }
        .brand-badge {
            display: inline-block;
            background: var(--primary);
            color: white;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 1px;
            padding: 5px 12px;
            border-radius: 4px;
            font-weight: 600;
            margin-bottom: 12px;
        }
        .product-sku {
            font-size: 13px;
            color: var(--text-muted);
            margin-bottom: 8px;
        }
        .product-title {
            font-size: 28px;
            font-weight: 800;
            color: var(--text-dark);
            line-height: 1.3;
            margin-bottom: 20px;
        }

        /* Price Section */
        .price-section {
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
            margin-bottom: 16px;
        }
        .original-price {
            font-size: 18px;
            color: var(--text-muted);
            text-decoration: line-through;
        }
        .current-price {
            font-size: 32px;
            font-weight: 800;
            color: var(--accent);
        }
        .discount-badge {
            background: var(--accent-light);
            color: var(--accent);
            padding: 4px 10px;
            border-radius: 4px;
            font-size: 14px;
            font-weight: 700;
        }

        /* Guarantee Badge */
        .guarantee-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: #E8F5E9;
            padding: 10px 16px;
            border-radius: var(--radius-sm);
            margin-bottom: 28px;
            font-size: 14px;
            color: var(--primary);
        }
        .guarantee-badge .highlight { font-weight: 700; }

        /* Variant Section */
        .variant-section { margin-bottom: 28px; }
        .variant-label {
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 8px;
            color: var(--text-dark);
        }
        .variant-selected {
            font-weight: 400;
            color: var(--text-muted);
        }
        .variant-options {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }
        .variant-btn {
            padding: 12px 20px;
            border: 2px solid var(--border);
            border-radius: var(--radius-sm);
            background: var(--bg-white);
            cursor: pointer;
            font-size: 14px;
            font-weight: 500;
            transition: all 0.2s;
            min-width: 100px;
            text-align: center;
            white-space: nowrap;
            color: var(--text-dark);
        }
        .variant-btn:hover { border-color: var(--text-muted); }
        .variant-btn.active {
            border-color: var(--primary);
            background: rgba(45, 90, 39, 0.05);
        }
        .variant-btn.disabled {
            opacity: 0.5;
            cursor: not-allowed;
            text-decoration: line-through;
        }
        .color-options {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
        }
        .color-btn {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            border: 3px solid transparent;
            cursor: pointer;
            position: relative;
            transition: all 0.2s;
            background: transparent;
            padding: 0;
        }
        .color-btn:hover { transform: scale(1.1); }
        .color-btn.active { border-color: var(--primary); }
        .color-btn::after {
            content: '';
            position: absolute;
            inset: 3px;
            border-radius: 50%;
            background: var(--color-value, #ccc);
        }

        /* Purchase Section */
        .purchase-section {
            display: flex;
            gap: 16px;
            margin-bottom: 16px;
        }
        .quantity-selector {
            display: flex;
            align-items: center;
            border: 2px solid var(--border);
            border-radius: var(--radius-sm);
            overflow: hidden;
        }
        .qty-btn {
            width: 48px;
            height: 48px;
            background: var(--bg-light);
            border: none;
            cursor: pointer;
            font-size: 20px;
            font-weight: 500;
            color: var(--text-dark);
            transition: background 0.2s;
        }
        .qty-btn:hover { background: var(--border); }
        .qty-input {
            width: 60px;
            height: 48px;
            border: none;
            text-align: center;
            font-size: 16px;
            font-weight: 600;
        }
        .qty-input:focus { outline: none; }
        .add-to-cart-btn {
            flex: 1;
            height: 52px;
            background: var(--primary);
            color: white;
            border: none;
            border-radius: var(--radius-sm);
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            transition: background 0.2s;
        }
        .add-to-cart-btn:hover { background: var(--primary-hover); }
        .buy-now-btn {
            width: 100%;
            height: 52px;
            background: var(--accent);
            color: white;
            border: none;
            border-radius: var(--radius-sm);
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            margin-bottom: 28px;
            transition: all 0.2s;
        }
        .buy-now-btn:hover {
            background: #D64A40;
            transform: translateY(-1px);
            box-shadow: var(--shadow-md);
        }

        /* Features List */
        .features-list {
            background: var(--bg-light);
            border-radius: var(--radius-md);
            padding: 20px 24px;
            border: 1px solid var(--border);
        }
        .feature-item {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 12px 0;
            border-bottom: 1px solid var(--border);
            font-size: 14px;
            color: var(--text-dark);
        }
        .feature-item:last-child { border-bottom: none; padding-bottom: 0; }
        .feature-item:first-child { padding-top: 0; }
        .feature-item i {
            color: var(--primary);
            font-size: 18px;
            width: 24px;
            text-align: center;
        }
        .feature-item .highlight {
            color: var(--primary);
            font-weight: 600;
        }
</style>
</head>
<body>
    <%@include file="header.jsp" %>

    <!-- Breadcrumb Section -->
    <section class="breadcrumb-section">
        <div class="container">
            <nav class="breadcrumb-nav">
                <a href="${pageContext.request.contextPath}/">Trang chủ</a>
                <span>/</span>
                <a href="${pageContext.request.contextPath}/shop">Vợt Pickleball</a>
                <span>/</span>
                <span class="current">${product.productName}</span>
            </nav>
        </div>
    </section>

    <!-- Product Section -->
    <section class="product-section">
        <div class="container">
            <div class="product-grid">
                <!-- Left Column: Product Gallery -->
                <div class="product-gallery">
                    <div class="main-image-container">
                        <c:if test="${not empty variants}">
                            <c:set var="hasDiscount" value="false"/>
                            <c:forEach var="variant" items="${variants}">
                                <c:if test="${not empty variant.compareAtPrice && variant.compareAtPrice > variant.sellingPrice}">
                                    <c:set var="hasDiscount" value="true"/>
                                </c:if>
                            </c:forEach>
                            <c:if test="${hasDiscount}">
                                <span class="sale-badge">SALE</span>
                            </c:if>
                        </c:if>
                        <c:choose>
                            <c:when test="${not empty images && images.size() > 0}">
                                <img id="mainImage" src="${pageContext.request.contextPath}${images[0].imageURL}" alt="${product.productName}" class="main-image">
                            </c:when>
                            <c:otherwise>
                                <img id="mainImage" src="${pageContext.request.contextPath}/img/product/default.jpg" alt="${product.productName}" class="main-image">
                            </c:otherwise>
                        </c:choose>
                        <button class="zoom-btn" onclick="openZoom()">
                            <i class="fa fa-search-plus"></i> ZOOM
                        </button>
                    </div>
                    
                    <c:if test="${not empty images && images.size() > 1}">
                        <div class="thumbnail-list">
                            <c:forEach var="img" items="${images}" varStatus="status">
                                <button class="thumbnail ${status.index == 0 ? 'active' : ''}" onclick="changeImage('${pageContext.request.contextPath}${img.imageURL}', this)">
                                    <img src="${pageContext.request.contextPath}${img.imageURL}" alt="Thumbnail ${status.index + 1}">
                                </button>
                            </c:forEach>
                        </div>
                    </c:if>
                </div>

                <!-- Right Column: Product Info -->
                <div class="product-info">
                    <c:if test="${not empty product.brandName}">
                        <span class="brand-badge">${product.brandName}</span>
                    </c:if>
                    <p class="product-sku">Mã SP: ${not empty product.sku ? product.sku : 'Đang cập nhật'}</p>
                    <h1 class="product-title">${product.productName}</h1>
                    
                    <!-- Price -->
                    <div class="price-section">
                        <!-- DEBUG: Show promotion status -->
                        <!-- hasPromotion: ${product.hasPromotion} -->
                        
                        <!-- Promotion Badge -->
                        <c:if test="${product.hasPromotion}">
                            <div class="promotion-banner" style="background: linear-gradient(135deg, #ff6b6b 0%, #ee5a6f 100%); color: white; padding: 12px 20px; border-radius: 8px; margin-bottom: 15px; display: flex; align-items: center; gap: 10px;">
                                <i class="fa fa-bolt" style="font-size: 20px;"></i>
                                <div>
                                    <strong style="font-size: 16px;">ĐANG GIẢM GIÁ ${product.discountPercent}%</strong>
                                    <div style="font-size: 13px; opacity: 0.9;">${product.promotionCampaign.campaignName}</div>
                                </div>
                            </div>
                        </c:if>
                        
                        <c:choose>
                            <c:when test="${not empty variants && variants.size() > 0}">
                                <!-- Calculate min/max prices (with promotion if available) -->
                                <c:set var="minPrice" value="${variants[0].hasPromotion ? variants[0].promotionPrice : variants[0].sellingPrice}"/>
                                <c:set var="maxPrice" value="${variants[0].hasPromotion ? variants[0].promotionPrice : variants[0].sellingPrice}"/>
                                <c:set var="minOriginalPrice" value="${variants[0].sellingPrice}"/>
                                <c:set var="maxOriginalPrice" value="${variants[0].sellingPrice}"/>
                                
                                <c:forEach var="variant" items="${variants}">
                                    <c:set var="currentPrice" value="${variant.hasPromotion ? variant.promotionPrice : variant.sellingPrice}"/>
                                    <c:if test="${currentPrice < minPrice}">
                                        <c:set var="minPrice" value="${currentPrice}"/>
                                    </c:if>
                                    <c:if test="${currentPrice > maxPrice}">
                                        <c:set var="maxPrice" value="${currentPrice}"/>
                                    </c:if>
                                    <c:if test="${variant.sellingPrice < minOriginalPrice}">
                                        <c:set var="minOriginalPrice" value="${variant.sellingPrice}"/>
                                    </c:if>
                                    <c:if test="${variant.sellingPrice > maxOriginalPrice}">
                                        <c:set var="maxOriginalPrice" value="${variant.sellingPrice}"/>
                                    </c:if>
                                </c:forEach>
                                
                                <!-- Show original price if has promotion -->
                                <c:if test="${product.hasPromotion}">
                                    <span class="original-price" style="text-decoration: line-through; color: #999; font-size: 18px; margin-right: 10px;">
                                        <c:choose>
                                            <c:when test="${minOriginalPrice == maxOriginalPrice}">
                                                <fmt:formatNumber value="${minOriginalPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                            </c:when>
                                            <c:otherwise>
                                                <fmt:formatNumber value="${minOriginalPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫ - 
                                                <fmt:formatNumber value="${maxOriginalPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                            </c:otherwise>
                                        </c:choose>
                                    </span>
                                </c:if>
                                
                                <!-- Current/Promotion Price -->
                                <c:choose>
                                    <c:when test="${minPrice != null && minPrice > 0}">
                                        <span class="current-price" style="${product.hasPromotion ? 'color: #ca1515; font-weight: 700;' : ''}">
                                            <c:choose>
                                                <c:when test="${minPrice == maxPrice}">
                                                    <fmt:formatNumber value="${minPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                                </c:when>
                                                <c:otherwise>
                                                    <fmt:formatNumber value="${minPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫ - 
                                                    <fmt:formatNumber value="${maxPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                                </c:otherwise>
                                            </c:choose>
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="current-price">Liên hệ</span>
                                    </c:otherwise>
                                </c:choose>
                            </c:when>
                            <c:otherwise>
                                <span class="current-price">Liên hệ</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    
                    <!-- Guarantee Badge -->
                    <div class="guarantee-badge">
                        <i class="fa fa-shield"></i>
                        <span>Cam kết <span class="highlight">Giá Tốt Nhất</span></span>
                    </div>
                    
                    <!-- Variant Selector by Attributes -->
                    <c:choose>
                        <c:when test="${not empty attributeGroups && attributeGroups.size() > 0}">
                            <!-- Hiển thị chọn theo từng thuộc tính -->
                            <c:forEach var="attrGroup" items="${attributeGroups}">
                                <div class="variant-section">
                                    <p class="variant-label">
                                        ${attrGroup.attributeName}: 
                                        <span class="variant-selected attr-selected-${attrGroup.attributeId}">Chọn ${attrGroup.attributeName}</span>
                                    </p>
                                    <div class="variant-options">
                                        <c:forEach var="value" items="${attrGroup.values}">
                                            <button class="variant-btn attr-btn" 
                                                    data-attribute-id="${attrGroup.attributeId}"
                                                    data-attribute-name="${attrGroup.attributeName}"
                                                    data-value-id="${value.valueId}"
                                                    data-value-name="${value.valueName}"
                                                    onclick="selectAttribute(this)">
                                                ${value.valueName}
                                            </button>
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:forEach>
                            
                            <!-- Hiển thị SKU đã chọn -->
                            <div class="variant-section" id="selectedVariantInfo" style="display:none;">
                                <p class="variant-label">
                                    Phiên bản: <span class="variant-selected" id="selectedVariantSku">-</span>
                                </p>
                                <p class="variant-label" id="stockInfo" style="margin-top: 8px;">
                                    Còn lại: <span class="variant-selected" id="stockQuantity" style="color: #28a745; font-weight: 600;">-</span>
                                </p>
                            </div>
                        </c:when>
                        <c:when test="${not empty variants && variants.size() > 1}">
                            <!-- Fallback: Hiển thị tất cả variants nếu không có attribute groups -->
                            <div class="variant-section">
                                <p class="variant-label">
                                    Phiên bản: 
                                    <span class="variant-selected" id="selectedVariant">${variants[0].sku}</span>
                                </p>
                                <div class="variant-options">
                                    <c:forEach var="variant" items="${variants}" varStatus="status">
                                        <button class="variant-btn ${status.index == 0 ? 'active' : ''} ${variant.stock <= 0 ? 'disabled' : ''}"
                                                data-variant-id="${variant.variantID}"
                                                data-variant-name="${variant.sku}"
                                                data-price="${variant.sellingPrice}"
                                                data-compare-price="${variant.compareAtPrice}"
                                                data-stock="${variant.stock}"
                                                ${variant.stock <= 0 ? 'disabled' : ''}
                                                onclick="selectVariantDirect(this)">
                                            ${variant.sku}
                                            <c:if test="${variant.stock <= 0}"> (Hết)</c:if>
                                        </button>
                                    </c:forEach>
                                </div>
                            </div>
                        </c:when>
                    </c:choose>
                    
                    <!-- Hidden inputs for form -->
                    <input type="hidden" id="productId" value="${product.productID}">
                    <c:choose>
                        <c:when test="${not empty attributeGroups && attributeGroups.size() > 0}">
                            <!-- Khi có attribute groups, không set sẵn variantId -->
                            <input type="hidden" id="selectedVariantId" value="">
                        </c:when>
                        <c:otherwise>
                            <input type="hidden" id="selectedVariantId" value="${not empty variants ? variants[0].variantID : ''}">
                        </c:otherwise>
                    </c:choose>
                    
                    <!-- Purchase Section -->
                    <div class="purchase-section">
                        <div class="quantity-selector">
                            <button class="qty-btn" onclick="updateQty(-1)">−</button>
                            <input type="number" class="qty-input" value="1" min="1" max="99" id="qtyInput">
                            <button class="qty-btn" onclick="updateQty(1)">+</button>
                        </div>
                        <button class="add-to-cart-btn" onclick="addToCart()">
                            <i class="fa fa-shopping-cart"></i>
                            BỎ VÀO GIỎ HÀNG
                        </button>
                    </div>
                    
                    <button class="buy-now-btn" onclick="buyNow()">MUA NGAY</button>
                    
                    <!-- Features List -->
                    <div class="features-list">
                        <div class="feature-item">
                            <i class="fa fa-truck"></i>
                            <span>Giao hàng toàn quốc - <span class="highlight">Miễn phí đơn từ 500K</span></span>
                        </div>
                        <div class="feature-item">
                            <i class="fa fa-check-circle"></i>
                            <span>Tích điểm tất cả sản phẩm</span>
                        </div>
                        <div class="feature-item">
                            <i class="fa fa-percent"></i>
                            <span>Giảm <span class="highlight">5%</span> khi thanh toán online</span>
                        </div>
                        <div class="feature-item">
                            <i class="fa fa-undo"></i>
                            <span>Đổi trả trong <span class="highlight">7 ngày</span></span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Product Tabs Section -->
            <div class="product-tabs-section" style="margin-top: 60px;">
                <style>
                    .product-tabs-section .nav-tabs { border-bottom: 2px solid var(--border); margin-bottom: 0; }
                    .product-tabs-section .nav-link {
                        border: none;
                        border-bottom: 3px solid transparent;
                        color: var(--text-muted);
                        font-weight: 600;
                        padding: 16px 24px;
                        margin-bottom: -2px;
                        transition: all 0.2s;
                    }
                    .product-tabs-section .nav-link:hover { color: var(--primary); }
                    .product-tabs-section .nav-link.active {
                        color: var(--primary);
                        border-bottom-color: var(--primary);
                        background: transparent;
                    }
                    .tab-content-inner {
                        padding: 32px;
                        background: var(--bg-white);
                        border: 1px solid var(--border);
                        border-top: none;
                        border-radius: 0 0 var(--radius-md) var(--radius-md);
                        line-height: 1.8;
                        color: var(--text-dark);
                    }
                    .tab-content-inner h3 { font-size: 18px; font-weight: 700; margin: 24px 0 12px; color: var(--text-dark); }
                    .tab-content-inner h3:first-child { margin-top: 0; }
                    .tab-content-inner ul { padding-left: 20px; margin: 12px 0; }
                    .tab-content-inner li { margin-bottom: 8px; }
                    .specs-table { width: 100%; border-collapse: collapse; }
                    .specs-table tr:nth-child(even) { background: var(--bg-light); }
                    .specs-table td { padding: 14px 16px; border-bottom: 1px solid var(--border); }
                    .specs-table td:first-child { font-weight: 600; width: 35%; color: var(--text-muted); }
                    .shipping-info { display: grid; gap: 20px; }
                    .shipping-card {
                        background: var(--bg-light);
                        border-radius: var(--radius-sm);
                        padding: 20px;
                        border-left: 4px solid var(--primary);
                    }
                    .shipping-card h4 { font-size: 16px; font-weight: 700; margin-bottom: 12px; color: var(--text-dark); }
                    .shipping-card p { margin: 0; color: var(--text-muted); font-size: 14px; line-height: 1.7; }
                    
                    /* Related Products */
                    .related-section { padding: 60px 0; background: var(--bg-light); }
                    .section-title { font-size: 24px; font-weight: 800; margin-bottom: 32px; color: var(--text-dark); }
                    .related-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 24px; }
                    .product-card {
                        background: var(--bg-white);
                        border-radius: var(--radius-md);
                        overflow: hidden;
                        box-shadow: var(--shadow-sm);
                        transition: all 0.3s;
                    }
                    .product-card:hover { transform: translateY(-4px); box-shadow: var(--shadow-md); }
                    .product-card-img {
                        aspect-ratio: 1;
                        background: var(--bg-light);
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        overflow: hidden;
                    }
                    .product-card-img img { width: 100%; height: 100%; object-fit: contain; padding: 16px; transition: transform 0.3s; }
                    .product-card:hover .product-card-img img { transform: scale(1.05); }
                    .product-card-body { padding: 16px; }
                    .product-card-brand { font-size: 11px; text-transform: uppercase; color: var(--primary); font-weight: 600; margin-bottom: 6px; }
                    .product-card-title {
                        font-size: 14px;
                        font-weight: 600;
                        color: var(--text-dark);
                        margin-bottom: 10px;
                        display: -webkit-box;
                        -webkit-line-clamp: 2;
                        line-clamp: 2;
                        -webkit-box-orient: vertical;
                        overflow: hidden;
                        line-height: 1.4;
                        height: 40px;
                    }
                    .product-card-title a { color: inherit; text-decoration: none; }
                    .product-card-title a:hover { color: var(--primary); }
                    .product-card-price { font-size: 16px; font-weight: 700; color: var(--accent); }
                    
                    /* Responsive */
                    @media (max-width: 992px) {
                        .product-grid { grid-template-columns: 1fr; gap: 32px; }
                        .related-grid { grid-template-columns: repeat(2, 1fr); }
                    }
                    @media (max-width: 576px) {
                        .related-grid { grid-template-columns: 1fr; }
                        .product-title { font-size: 22px; }
                        .current-price { font-size: 26px; }
                    }
                </style>
                
                <ul class="nav nav-tabs product-tabs" role="tablist">
                    <li class="nav-item">
                        <a class="nav-link active" data-toggle="tab" href="#tab-description" role="tab">Mô tả sản phẩm</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" data-toggle="tab" href="#tab-specs" role="tab">Thông số kỹ thuật</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" data-toggle="tab" href="#tab-shipping" role="tab">Vận chuyển & Đổi trả</a>
                    </li>
                </ul>
                <div class="tab-content">
                    <div class="tab-pane fade show active" id="tab-description" role="tabpanel">
                        <div class="tab-content-inner">
                            <c:choose>
                                <c:when test="${not empty product.description}">
                                    <div>${product.description}</div>
                                </c:when>
                                <c:otherwise>
                                    <p>Thông tin chi tiết về sản phẩm đang được cập nhật.</p>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="tab-pane fade" id="tab-specs" role="tabpanel">
                        <div class="tab-content-inner">
                            <c:choose>
                                <c:when test="${not empty product.specifications}">
                                    <div>${product.specifications}</div>
                                </c:when>
                                <c:otherwise>
                                    <table class="specs-table">
                                        <tr><td>Thương hiệu</td><td>${not empty product.brandName ? product.brandName : 'Đang cập nhật'}</td></tr>
                                        <tr><td>Danh mục</td><td>${not empty product.categoryName ? product.categoryName : 'Đang cập nhật'}</td></tr>
                                        <tr><td>Mã sản phẩm</td><td>${product.productID}</td></tr>
                                        <tr><td>Tình trạng</td><td>${product.totalStock > 0 ? 'Còn hàng' : 'Hết hàng'}</td></tr>
                                    </table>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="tab-pane fade" id="tab-shipping" role="tabpanel">
                        <div class="tab-content-inner">
                            <div class="shipping-info">
                                <div class="shipping-card">
                                    <h4><i class="fa fa-truck"></i> Chính sách vận chuyển</h4>
                                    <p>• Giao hàng toàn quốc qua các đơn vị vận chuyển uy tín<br>
                                       • Miễn phí vận chuyển cho đơn hàng từ 500.000₫<br>
                                       • Thời gian giao hàng: 2-5 ngày tùy khu vực<br>
                                       • Hỗ trợ ship COD (thanh toán khi nhận hàng)</p>
                                </div>
                                <div class="shipping-card">
                                    <h4><i class="fa fa-undo"></i> Chính sách đổi trả</h4>
                                    <p>• Đổi trả miễn phí trong vòng 7 ngày kể từ ngày nhận hàng<br>
                                       • Sản phẩm còn nguyên tem, nhãn mác, chưa qua sử dụng<br>
                                       • Hoàn tiền 100% nếu sản phẩm lỗi do nhà sản xuất<br>
                                       • Liên hệ hotline để được hỗ trợ đổi trả nhanh chóng</p>
                                </div>
                                <div class="shipping-card">
                                    <h4><i class="fa fa-shield"></i> Chính sách bảo hành</h4>
                                    <p>• Bảo hành chính hãng theo quy định của nhà sản xuất<br>
                                       • Hỗ trợ kỹ thuật và tư vấn sử dụng sản phẩm<br>
                                       • Cam kết 100% sản phẩm chính hãng</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Reviews Section -->
            <div class="reviews-section" style="margin-top: 60px;">
                <style>
                    .reviews-section { background: var(--bg-white); }
                    .reviews-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 32px; flex-wrap: wrap; gap: 20px; }
                    .reviews-title { font-size: 24px; font-weight: 800; color: var(--text-dark); margin: 0; }
                    .reviews-summary { display: flex; gap: 40px; padding: 24px; background: var(--bg-light); border-radius: var(--radius-md); margin-bottom: 24px; flex-wrap: wrap; }
                    .reviews-avg { text-align: center; min-width: 140px; }
                    .reviews-avg-score { font-size: 48px; font-weight: 800; color: var(--primary); line-height: 1; }
                    .reviews-avg-stars { color: #FBBF24; font-size: 20px; margin: 8px 0; }
                    .reviews-avg-count { color: var(--text-muted); font-size: 14px; }
                    .reviews-bars { flex: 1; min-width: 200px; }
                    .review-bar-row { display: flex; align-items: center; gap: 12px; margin-bottom: 8px; }
                    .review-bar-label { font-size: 14px; color: var(--text-dark); min-width: 50px; }
                    .review-bar-track { flex: 1; height: 8px; background: #E5E7EB; border-radius: 4px; overflow: hidden; }
                    .review-bar-fill { height: 100%; background: #FBBF24; border-radius: 4px; transition: width 0.3s; }
                    .review-bar-count { font-size: 13px; color: var(--text-muted); min-width: 30px; text-align: right; }
                    .reviews-filter { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 24px; }
                    .filter-btn { padding: 8px 16px; border: 2px solid var(--border); border-radius: 20px; background: var(--bg-white); color: var(--text-muted); font-size: 14px; font-weight: 600; cursor: pointer; transition: all 0.2s; text-decoration: none; }
                    .filter-btn:hover { border-color: var(--primary); color: var(--primary); text-decoration: none; }
                    .filter-btn.active { background: var(--primary); border-color: var(--primary); color: white; }
                    .review-item { padding: 24px 0; border-bottom: 1px solid var(--border); }
                    .review-item:last-child { border-bottom: none; }
                    .review-item.hidden-review { opacity: 0.5; background: #fff5f5; padding: 24px; margin: 0 -24px; border-radius: var(--radius-sm); }
                    .review-header-row { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 12px; }
                    .review-author { display: flex; align-items: center; gap: 12px; }
                    .review-avatar { width: 44px; height: 44px; border-radius: 50%; background: var(--primary); color: white; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 18px; }
                    .review-author-info h4 { font-size: 15px; font-weight: 700; color: var(--text-dark); margin: 0 0 4px; }
                    .review-stars { color: #FBBF24; font-size: 14px; }
                    .review-stars .empty { color: #D1D5DB; }
                    .review-date { font-size: 13px; color: var(--text-muted); }
                    .review-title-text { font-size: 16px; font-weight: 700; color: var(--text-dark); margin-bottom: 8px; }
                    .review-content-text { color: #555; line-height: 1.7; margin-bottom: 12px; }
                    .review-reply { background: #f0f7f0; border-left: 4px solid var(--primary); padding: 16px; margin-top: 16px; border-radius: 0 8px 8px 0; }
                    .review-reply-header { font-weight: 700; color: var(--primary); margin-bottom: 8px; font-size: 14px; }
                    .review-reply-content { color: #555; font-size: 14px; line-height: 1.6; }
                    .hidden-badge { background: #dc3545; color: white; padding: 4px 10px; border-radius: 4px; font-size: 12px; font-weight: 600; }
                    .reviews-empty { text-align: center; padding: 60px 20px; color: var(--text-muted); }
                    .reviews-empty i { font-size: 48px; margin-bottom: 16px; color: #ddd; }
                    .reviews-pagination { display: flex; justify-content: center; gap: 8px; margin-top: 24px; }
                    .reviews-pagination a, .reviews-pagination span { padding: 8px 14px; border: 1px solid var(--border); border-radius: 6px; color: var(--text-dark); text-decoration: none; font-size: 14px; }
                    .reviews-pagination a:hover { border-color: var(--primary); color: var(--primary); }
                    .reviews-pagination .active { background: var(--primary); border-color: var(--primary); color: white; }
                </style>
                
                <div class="reviews-header">
                    <h2 class="reviews-title"><i class="fa fa-star" style="color: #FBBF24; margin-right: 10px;"></i>Đánh giá sản phẩm</h2>
                </div>
                
                <!-- Reviews Summary -->
                <div class="reviews-summary">
                    <div class="reviews-avg">
                        <div class="reviews-avg-score">${reviewStats.avgRating}</div>
                        <div class="reviews-avg-stars">
                            <c:forEach begin="1" end="5" var="i">
                                <i class="fa fa-star ${i <= reviewStats.avgRating ? '' : (i - 1 < reviewStats.avgRating ? 'fa-star-half-o' : 'empty')}" style="${i > reviewStats.avgRating ? 'color: #D1D5DB;' : ''}"></i>
                            </c:forEach>
                        </div>
                        <div class="reviews-avg-count">${reviewStats.totalReviews} đánh giá</div>
                    </div>
                    <div class="reviews-bars">
                        <c:set var="total" value="${reviewStats.totalReviews > 0 ? reviewStats.totalReviews : 1}"/>
                        <c:forEach begin="1" end="5" var="i">
                            <c:set var="starCount" value="${reviewStats['count'.concat(6-i).concat('Star')]}"/>
                            <c:set var="percent" value="${(starCount / total) * 100}"/>
                            <div class="review-bar-row">
                                <span class="review-bar-label">${6-i} <i class="fa fa-star" style="color: #FBBF24;"></i></span>
                                <div class="review-bar-track">
                                    <div class="review-bar-fill" style="width: ${percent}%;"></div>
                                </div>
                                <span class="review-bar-count">${starCount}</span>
                            </div>
                        </c:forEach>
                    </div>
                </div>
                
                <!-- Filter Tabs -->
                <div class="reviews-filter">
                    <a href="${pageContext.request.contextPath}/product-detail?id=${product.productID}" class="filter-btn ${empty filterRating ? 'active' : ''}">Tất cả</a>
                    <c:forEach begin="1" end="5" var="i">
                        <a href="${pageContext.request.contextPath}/product-detail?id=${product.productID}&filterRating=${6-i}" class="filter-btn ${filterRating == (6-i) ? 'active' : ''}">${6-i} <i class="fa fa-star" style="color: #FBBF24;"></i></a>
                    </c:forEach>
                </div>
                
                <!-- Reviews List -->
                <c:choose>
                    <c:when test="${empty reviews}">
                        <div class="reviews-empty">
                            <i class="fa fa-comment-o"></i>
                            <h4>Chưa có đánh giá nào</h4>
                            <p>Hãy là người đầu tiên đánh giá sản phẩm này!</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="review" items="${reviews}">
                            <div class="review-item ${review.hidden && review.customerId == currentCustomerId ? 'hidden-review' : ''}">
                                <c:if test="${review.hidden && review.customerId == currentCustomerId}">
                                    <div style="margin-bottom: 12px;">
                                        <span class="hidden-badge"><i class="fa fa-eye-slash"></i> Đánh giá của bạn đã bị ẩn</span>
                                    </div>
                                </c:if>
                                <div class="review-header-row">
                                    <div class="review-author">
                                        <div class="review-avatar">${review.customerName.substring(0,1).toUpperCase()}</div>
                                        <div class="review-author-info">
                                            <h4>${review.customerName}</h4>
                                            <div class="review-stars">
                                                <c:forEach begin="1" end="5" var="i">
                                                    <i class="fa fa-star ${i <= review.rating ? '' : 'empty'}"></i>
                                                </c:forEach>
                                            </div>
                                            <c:if test="${not empty review.variantSku}">
                                                <div style="font-size: 12px; color: #888; margin-top: 4px;">
                                                    <i class="fa fa-tag"></i> Phân loại: ${review.variantSku}
                                                </div>
                                            </c:if>
                                        </div>
                                    </div>
                                    <div class="review-date">
                                        <i class="fa fa-clock-o"></i> ${review.reviewDate.toLocalDate()}
                                    </div>
                                </div>
                                
                                <c:if test="${not empty review.reviewTitle}">
                                    <div class="review-title-text">${review.reviewTitle}</div>
                                </c:if>
                                
                                <c:if test="${not empty review.reviewContent}">
                                    <div class="review-content-text">${review.reviewContent}</div>
                                </c:if>
                                

                                
                                <c:if test="${review.hasReply()}">
                                    <div class="review-reply">
                                        <div class="review-reply-header">
                                            <i class="fa fa-reply"></i> Phản hồi từ Pickleball Shop
                                        </div>
                                        <div class="review-reply-content">${review.replyContent}</div>
                                    </div>
                                </c:if>
                            </div>
                        </c:forEach>
                        
                        <!-- Pagination -->
                        <c:if test="${totalReviewPages > 1}">
                            <div class="reviews-pagination">
                                <c:if test="${reviewPage > 1}">
                                    <a href="${pageContext.request.contextPath}/product-detail?id=${product.productID}${not empty filterRating ? '&filterRating='.concat(filterRating) : ''}&reviewPage=${reviewPage - 1}">«</a>
                                </c:if>
                                <c:forEach begin="1" end="${totalReviewPages}" var="i">
                                    <c:if test="${i >= reviewPage - 2 && i <= reviewPage + 2}">
                                        <c:choose>
                                            <c:when test="${i == reviewPage}">
                                                <span class="active">${i}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <a href="${pageContext.request.contextPath}/product-detail?id=${product.productID}${not empty filterRating ? '&filterRating='.concat(filterRating) : ''}&reviewPage=${i}">${i}</a>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:if>
                                </c:forEach>
                                <c:if test="${reviewPage < totalReviewPages}">
                                    <a href="${pageContext.request.contextPath}/product-detail?id=${product.productID}${not empty filterRating ? '&filterRating='.concat(filterRating) : ''}&reviewPage=${reviewPage + 1}">»</a>
                                </c:if>
                            </div>
                        </c:if>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </section>
    
    <!-- Review Image Modal -->
    <div id="reviewImageModal" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.9); z-index:9999; cursor:zoom-out;" onclick="closeReviewImage()">
        <button style="position:absolute; top:20px; right:20px; background:white; border:none; width:40px; height:40px; border-radius:50%; font-size:20px; cursor:pointer;">&times;</button>
        <img id="reviewModalImage" src="" style="position:absolute; top:50%; left:50%; transform:translate(-50%,-50%); max-width:90%; max-height:90%; object-fit:contain; border-radius: 8px;">
    </div>

    <!-- Related Products Section -->
    <c:if test="${not empty relatedProducts && relatedProducts.size() > 0}">
        <section class="related-section">
            <div class="container">
                <h2 class="section-title">Sản phẩm liên quan</h2>
                <div class="related-grid">
                    <c:forEach var="rp" items="${relatedProducts}" end="3">
                        <div class="product-card">
                            <a href="${pageContext.request.contextPath}/product-detail?id=${rp.productID}">
                                <div class="product-card-img">
                                    <c:choose>
                                        <c:when test="${not empty rp.mainImageUrl}">
                                            <img src="${pageContext.request.contextPath}${rp.mainImageUrl}" alt="${rp.productName}">
                                        </c:when>
                                        <c:otherwise>
                                            <img src="${pageContext.request.contextPath}/img/product/default.jpg" alt="${rp.productName}">
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </a>
                            <div class="product-card-body">
                                <c:if test="${not empty rp.brandName}">
                                    <div class="product-card-brand">${rp.brandName}</div>
                                </c:if>
                                <h3 class="product-card-title">
                                    <a href="${pageContext.request.contextPath}/product-detail?id=${rp.productID}">${rp.productName}</a>
                                </h3>
                                <div class="product-card-price">
                                    <c:choose>
                                        <c:when test="${not empty rp.minPrice}">
                                            <c:choose>
                                                <c:when test="${rp.hasPromotion}">
                                                    <span style="text-decoration: line-through; color: #999; font-size: 14px; margin-right: 8px;">
                                                        <fmt:formatNumber value="${rp.minPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                                    </span>
                                                    <span style="color: #ca1515; font-weight: 700;">
                                                        <fmt:formatNumber value="${rp.finalPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                                    </span>
                                                    <span style="background: #ca1515; color: white; padding: 2px 6px; border-radius: 3px; font-size: 11px; margin-left: 5px;">
                                                        -${rp.discountPercent}%
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <fmt:formatNumber value="${rp.minPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫
                                                </c:otherwise>
                                            </c:choose>
                                        </c:when>
                                        <c:otherwise>Liên hệ</c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </section>
    </c:if>

    <%@include file="footer.jsp" %>

    <!-- Zoom Modal -->
    <div id="zoomModal" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.9); z-index:9999; cursor:zoom-out;" onclick="closeZoom()">
        <button style="position:absolute; top:20px; right:20px; background:white; border:none; width:40px; height:40px; border-radius:50%; font-size:20px; cursor:pointer;">&times;</button>
        <img id="zoomImage" src="" style="position:absolute; top:50%; left:50%; transform:translate(-50%,-50%); max-width:90%; max-height:90%; object-fit:contain;">
    </div>

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
        // Change main image
        function changeImage(src, btn) {
            document.getElementById('mainImage').src = src;
            document.querySelectorAll('.thumbnail').forEach(t => t.classList.remove('active'));
            btn.classList.add('active');
        }
        
        // Zoom functionality
        function openZoom() {
            var mainImg = document.getElementById('mainImage');
            document.getElementById('zoomImage').src = mainImg.src;
            document.getElementById('zoomModal').style.display = 'block';
            document.body.style.overflow = 'hidden';
        }
        
        function closeZoom() {
            document.getElementById('zoomModal').style.display = 'none';
            document.body.style.overflow = '';
        }
        
        // Quantity update
        function updateQty(delta) {
            var input = document.getElementById('qtyInput');
            var val = parseInt(input.value) || 1;
            val = Math.max(1, Math.min(99, val + delta));
            input.value = val;
        }
        
        // Lưu trữ các thuộc tính đã chọn
        var selectedAttributes = {};
        var totalAttributeGroups = <c:out value="${not empty attributeGroups ? attributeGroups.size() : 0}" default="0"/>;
        
        // Chọn thuộc tính (Màu sắc, Size, ...)
        function selectAttribute(btn) {
            var attrId = btn.dataset.attributeId;
            var attrName = btn.dataset.attributeName;
            var valueId = btn.dataset.valueId;
            var valueName = btn.dataset.valueName;
            
            // Bỏ active các button cùng nhóm thuộc tính
            document.querySelectorAll('.attr-btn[data-attribute-id="' + attrId + '"]').forEach(b => {
                b.classList.remove('active');
            });
            btn.classList.add('active');
            
            // Lưu lựa chọn
            selectedAttributes[attrId] = {
                valueId: valueId,
                valueName: valueName
            };
            
            // Cập nhật label hiển thị
            var labelEl = document.querySelector('.attr-selected-' + attrId);
            if (labelEl) {
                labelEl.textContent = valueName;
            }
            
            // Kiểm tra đã chọn đủ thuộc tính chưa
            var selectedCount = Object.keys(selectedAttributes).length;
            if (selectedCount === totalAttributeGroups && totalAttributeGroups > 0) {
                // Đã chọn đủ, gọi API tìm variant
                lookupVariant();
            } else {
                // Chưa chọn đủ, reset variant
                document.getElementById('selectedVariantId').value = '';
                document.getElementById('selectedVariantInfo').style.display = 'none';
            }
        }
        
        // Gọi API tìm variant theo tổ hợp thuộc tính
        function lookupVariant() {
            var productId = document.getElementById('productId').value;
            var valueIds = Object.values(selectedAttributes).map(a => a.valueId).join(',');
            
            $.ajax({
                url: '${pageContext.request.contextPath}/api/variant-lookup',
                type: 'GET',
                data: {
                    productId: productId,
                    valueIds: valueIds
                },
                success: function(response) {
                    if (response.success && response.variant) {
                        var variant = response.variant;
                        
                        // Cập nhật variantId
                        document.getElementById('selectedVariantId').value = variant.variantId;
                        
                        // Hiển thị SKU
                        document.getElementById('selectedVariantSku').textContent = variant.sku;
                        document.getElementById('selectedVariantInfo').style.display = 'block';
                        
                        // Cập nhật giá
                        updatePriceDisplay(variant.sellingPrice, variant.compareAtPrice);
                        
                        // Cập nhật trạng thái còn hàng
                        updateStockStatus(variant.stock);
                    } else {
                        // Không tìm thấy variant
                        document.getElementById('selectedVariantId').value = '';
                        document.getElementById('selectedVariantSku').textContent = 'Không có sẵn';
                        document.getElementById('selectedVariantInfo').style.display = 'block';
                        
                        // Hiển thị thông báo
                        updatePriceDisplay(0, 0);
                        updateStockStatus(0);
                    }
                },
                error: function() {
                    console.error('Lỗi khi tìm variant');
                }
            });
        }
        
        // Cập nhật hiển thị giá
        function updatePriceDisplay(price, comparePrice) {
            var priceHtml = '';
            if (price > 0) {
                if (comparePrice && comparePrice > price) {
                    priceHtml += '<span class="original-price">' + formatPrice(comparePrice) + '₫</span> ';
                }
                priceHtml += '<span class="current-price">' + formatPrice(price) + '₫</span>';
                if (comparePrice && comparePrice > price) {
                    var discount = Math.round((comparePrice - price) / comparePrice * 100);
                    priceHtml += ' <span class="discount-badge">-' + discount + '%</span>';
                }
            } else {
                priceHtml = '<span class="current-price" style="color: #999;">Không có sẵn</span>';
            }
            document.querySelector('.price-section').innerHTML = priceHtml;
        }
        
        // Cập nhật trạng thái tồn kho
        function updateStockStatus(stock) {
            var addToCartBtn = document.querySelector('.add-to-cart-btn');
            var buyNowBtn = document.querySelector('.buy-now-btn');
            var stockQuantityEl = document.getElementById('stockQuantity');
            var stockInfoEl = document.getElementById('stockInfo');
            
            // Hiển thị số lượng stock
            if (stockQuantityEl) {
                if (stock <= 0) {
                    stockQuantityEl.textContent = 'Hết hàng';
                    stockQuantityEl.style.color = '#dc3545';
                } else if (stock <= 10) {
                    stockQuantityEl.textContent = stock + ' sản phẩm (Sắp hết)';
                    stockQuantityEl.style.color = '#fd7e14';
                } else {
                    stockQuantityEl.textContent = stock + ' sản phẩm';
                    stockQuantityEl.style.color = '#28a745';
                }
            }
            if (stockInfoEl) {
                stockInfoEl.style.display = 'block';
            }
            
            if (stock <= 0) {
                addToCartBtn.disabled = true;
                addToCartBtn.style.opacity = '0.5';
                addToCartBtn.style.cursor = 'not-allowed';
                buyNowBtn.disabled = true;
                buyNowBtn.style.opacity = '0.5';
                buyNowBtn.style.cursor = 'not-allowed';
                buyNowBtn.textContent = 'HẾT HÀNG';
            } else {
                addToCartBtn.disabled = false;
                addToCartBtn.style.opacity = '1';
                addToCartBtn.style.cursor = 'pointer';
                buyNowBtn.disabled = false;
                buyNowBtn.style.opacity = '1';
                buyNowBtn.style.cursor = 'pointer';
                buyNowBtn.textContent = 'MUA NGAY';
            }
        }
        
        // Fallback: Chọn variant trực tiếp (khi không có attribute groups)
        function selectVariantDirect(btn) {
            if (btn.disabled) return;
            
            document.querySelectorAll('.variant-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            
            var variantId = btn.dataset.variantId;
            var variantName = btn.dataset.variantName;
            var price = parseFloat(btn.dataset.price);
            var comparePrice = parseFloat(btn.dataset.comparePrice) || 0;
            var stock = parseInt(btn.dataset.stock) || 0;
            
            document.getElementById('selectedVariantId').value = variantId;
            var selectedVariantEl = document.getElementById('selectedVariant');
            if (selectedVariantEl) {
                selectedVariantEl.textContent = variantName;
            }
            
            updatePriceDisplay(price, comparePrice);
            updateStockStatus(stock);
        }
        
        // Legacy function for backward compatibility
        function selectVariant(btn) {
            selectVariantDirect(btn);
        }
        
        function formatPrice(num) {
            return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        }
        
        // Add to cart
        function addToCart() {
            var productId = document.getElementById('productId').value;
            var variantId = document.getElementById('selectedVariantId').value;
            var quantity = document.getElementById('qtyInput').value;
            
            if (!variantId) {
                // Kiểm tra xem có attribute groups không
                if (totalAttributeGroups > 0) {
                    var selectedCount = Object.keys(selectedAttributes).length;
                    if (selectedCount < totalAttributeGroups) {
                        alert('Vui lòng chọn đầy đủ các thuộc tính (đã chọn ' + selectedCount + '/' + totalAttributeGroups + ')');
                    } else {
                        alert('Không tìm thấy phiên bản với tổ hợp này. Vui lòng chọn lại.');
                    }
                } else {
                    alert('Vui lòng chọn phiên bản sản phẩm');
                }
                return;
            }
            
            // AJAX call to add to cart
            $.ajax({
                url: '${pageContext.request.contextPath}/cart',
                type: 'POST',
                dataType: 'json',
                data: {
                    action: 'add',
                    productId: productId,
                    variantId: variantId,
                    quantity: quantity
                },
                success: function(response) {
                    if (response.success) {
                        alert('Đã thêm sản phẩm vào giỏ hàng!');
                        // Update cart count and total in header
                        if (response.cartCount !== undefined) {
                            $('.cart-count').text(response.cartCount);
                        }
                        if (response.cartTotal !== undefined) {
                            $('.cart-total').text(formatPrice(response.cartTotal) + '₫');
                        }
                    } else {
                        if (response.redirect) {
                            window.location.href = response.redirect;
                        } else {
                            alert(response.message || 'Có lỗi xảy ra, vui lòng thử lại');
                        }
                    }
                },
                error: function(xhr, status, error) {
                    console.error('Add to cart error:', status, error);
                    // Fallback: redirect to cart page
                    window.location.href = '${pageContext.request.contextPath}/cart?action=add&productId=' + productId + '&variantId=' + variantId + '&quantity=' + quantity;
                }
            });
        }
        
        // Buy now - Chuyển thẳng đến checkout với sản phẩm đã chọn
        function buyNow() {
            var productId = document.getElementById('productId').value;
            var variantId = document.getElementById('selectedVariantId').value;
            var quantity = document.getElementById('qtyInput').value;
            
            if (!variantId) {
                // Kiểm tra xem có attribute groups không
                if (totalAttributeGroups > 0) {
                    var selectedCount = Object.keys(selectedAttributes).length;
                    if (selectedCount < totalAttributeGroups) {
                        alert('Vui lòng chọn đầy đủ các thuộc tính (đã chọn ' + selectedCount + '/' + totalAttributeGroups + ')');
                    } else {
                        alert('Không tìm thấy phiên bản với tổ hợp này. Vui lòng chọn lại.');
                    }
                } else {
                    alert('Vui lòng chọn phiên bản sản phẩm');
                }
                return;
            }
            
            // Redirect đến trang buy-now để checkout trực tiếp
            window.location.href = '${pageContext.request.contextPath}/buy-now?productId=' + productId + '&variantId=' + variantId + '&quantity=' + quantity;
        }
        
        // Keyboard support for zoom
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                closeZoom();
                closeReviewImage();
            }
        });
        
        // Review image modal
        function openReviewImage(src) {
            document.getElementById('reviewModalImage').src = src;
            document.getElementById('reviewImageModal').style.display = 'block';
            document.body.style.overflow = 'hidden';
        }
        
        function closeReviewImage() {
            document.getElementById('reviewImageModal').style.display = 'none';
            document.body.style.overflow = '';
        }
    </script>
</body>
</html>
           