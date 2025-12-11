<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nhập kho sản phẩm - Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Source+Sans+Pro:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        :root {
            --primary: #007bff;
            --success: #28a745;
            --warning: #ffc107;
            --danger: #dc3545;
            --info: #17a2b8;
            --light-bg: #f4f6f9;
            --card-shadow: 0 0 1px rgba(0,0,0,.125), 0 1px 3px rgba(0,0,0,.2);
        }
        * { font-family: 'Source Sans Pro', -apple-system, BlinkMacSystemFont, sans-serif; }
        body { background-color: var(--light-bg); color: #333; }
        .content-wrapper { max-width: 1200px; margin: 0 auto; padding: 20px; }
        .content-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; flex-wrap: wrap; gap: 10px; }
        .content-header h1 { font-size: 1.8rem; font-weight: 600; color: #333; margin: 0; }
        .breadcrumb { background: transparent; margin: 0; padding: 0; font-size: 0.9rem; }
        .breadcrumb a { color: var(--primary); text-decoration: none; }
        .card { background: #fff; border-radius: 8px; box-shadow: var(--card-shadow); margin-bottom: 20px; border: none; }
        .card-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: #fff; padding: 15px 20px; border-radius: 8px 8px 0 0 !important; border: none; }
        .card-header.bg-info { background: linear-gradient(135deg, #17a2b8 0%, #138496 100%) !important; }
        .card-header.bg-success { background: linear-gradient(135deg, #28a745 0%, #1e7e34 100%) !important; }
        .card-header.bg-warning { background: linear-gradient(135deg, #ffc107 0%, #e0a800 100%) !important; color: #333 !important; }
        .card-header h3 { margin: 0; font-size: 1.1rem; font-weight: 600; }
        .card-body { padding: 20px; }
        .product-info { display: flex; gap: 20px; align-items: flex-start; }
        .product-image { width: 120px; height: 120px; border-radius: 8px; object-fit: cover; border: 2px solid #e9ecef; }
        .product-details h4 { font-size: 1.3rem; font-weight: 600; margin-bottom: 8px; color: #333; }
        .product-sku { color: #6c757d; font-size: 0.95rem; margin-bottom: 15px; }
        .product-sku code { background: #e9ecef; padding: 3px 8px; border-radius: 4px; font-weight: 600; }
        .stats-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 15px; margin-top: 20px; }
        .stat-box { background: #f8f9fa; border-radius: 8px; padding: 15px; text-align: center; border-left: 4px solid var(--primary); }
        .stat-box.stock { border-left-color: var(--info); }
        .stat-box.cost { border-left-color: var(--warning); }
        .stat-box.price { border-left-color: var(--success); }
        .stat-box.profit { border-left-color: #6f42c1; }
        .stat-box .label { font-size: 0.85rem; color: #6c757d; margin-bottom: 5px; }
        .stat-box .value { font-size: 1.4rem; font-weight: 700; color: #333; }
        .stat-box .value.text-info { color: var(--info) !important; }
        .stat-box .value.text-warning { color: #d39e00 !important; }
        .stat-box .value.text-success { color: var(--success) !important; }
        .stat-box .value.text-purple { color: #6f42c1 !important; }
        .form-label { font-weight: 600; color: #495057; margin-bottom: 8px; }
        .form-control { border: 1px solid #ced4da; border-radius: 6px; padding: 10px 15px; font-size: 1rem; transition: border-color 0.2s, box-shadow 0.2s; }
        .form-control:focus { border-color: var(--primary); box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.15); }
        .input-group-text { background: #e9ecef; border: 1px solid #ced4da; font-weight: 600; }
        .form-text { color: #6c757d; font-size: 0.85rem; }
        .btn-primary { background: linear-gradient(135deg, #007bff 0%, #0056b3 100%); border: none; padding: 10px 25px; font-weight: 600; border-radius: 6px; transition: transform 0.2s, box-shadow 0.2s; }
        .btn-primary:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(0, 123, 255, 0.35); }
        .btn-secondary { background: #6c757d; border: none; padding: 10px 25px; font-weight: 600; border-radius: 6px; }
        .table { margin-bottom: 0; }
        .table thead th { background: #f8f9fa; border-bottom: 2px solid #dee2e6; font-weight: 600; color: #495057; padding: 12px 15px; font-size: 0.9rem; }
        .table tbody td { padding: 12px 15px; vertical-align: middle; }
        .table tbody tr:hover { background: #f8f9fa; }
        .badge { font-weight: 600; padding: 5px 10px; border-radius: 4px; }
        .alert-info { background: #e7f3ff; border: 1px solid #b6d4fe; color: #084298; border-radius: 8px; }
        .alert-info i { margin-right: 8px; }
        .preview-box { background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%); border: 2px dashed #ced4da; border-radius: 8px; padding: 20px; text-align: center; }
        .preview-box .preview-label { font-size: 0.85rem; color: #6c757d; margin-bottom: 5px; }
        .preview-box .preview-value { font-size: 1.5rem; font-weight: 700; color: var(--success); }
        @media (max-width: 768px) {
            .stats-row { grid-template-columns: repeat(2, 1fr); }
            .product-info { flex-direction: column; align-items: center; text-align: center; }
        }
    </style>
</head>
<body>
    <div class="content-wrapper">
        <!-- Header -->
        <div class="content-header">
            <h1><i class="fas fa-boxes me-2"></i>Nhập kho sản phẩm</h1>
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a></li>
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/products">Sản phẩm</a></li>
                    <li class="breadcrumb-item active">Nhập kho</li>
                </ol>
            </nav>
        </div>

        <!-- Success/Error Messages -->
        <c:if test="${not empty successMessage}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle me-2"></i>${successMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle me-2"></i>${errorMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <div class="row">
            <!-- Left Column -->
            <div class="col-lg-8">
                <!-- Product Info Card -->
                <div class="card">
                    <div class="card-header bg-info">
                        <h3><i class="fas fa-info-circle me-2"></i>Thông tin sản phẩm</h3>
                    </div>
                    <div class="card-body">
                        <div class="product-info">
                            <c:choose>
                                <c:when test="${not empty stockDetail.mainImage}">
                                    <img src="${pageContext.request.contextPath}${stockDetail.mainImage}" alt="Product" class="product-image">
                                </c:when>
                                <c:otherwise>
                                    <img src="${pageContext.request.contextPath}/img/product/product-1.jpg" alt="No image" class="product-image">
                                </c:otherwise>
                            </c:choose>
                            <div class="product-details">
                                <h4>${stockDetail.productName}</h4>
                                <p class="product-sku">
                                    <i class="fas fa-barcode me-1"></i> SKU: <code>${stockDetail.sku}</code>
                                    <c:if test="${not empty stockDetail.variantName}">
                                        <span class="ms-3"><i class="fas fa-layer-group me-1"></i> Variant: ${stockDetail.variantName}</span>
                                    </c:if>
                                </p>
                            </div>
                        </div>
                        
                        <!-- Stats -->
                        <div class="stats-row">
                            <div class="stat-box stock">
                                <div class="label"><i class="fas fa-cubes me-1"></i>Tồn kho hiện tại</div>
                                <div class="value text-info" id="currentStockDisplay">${stockDetail.currentStock}</div>
                            </div>
                            <div class="stat-box cost">
                                <div class="label"><i class="fas fa-coins me-1"></i>Giá vốn TB</div>
                                <div class="value text-warning" id="avgCostDisplay">
                                    <fmt:formatNumber value="${stockDetail.avgCostPrice}" type="number" maxFractionDigits="0"/>đ
                                </div>
                            </div>
                            <div class="stat-box price">
                                <div class="label"><i class="fas fa-tag me-1"></i>Giá bán</div>
                                <div class="value text-success">
                                    <fmt:formatNumber value="${stockDetail.sellingPrice}" type="number" maxFractionDigits="0"/>đ
                                </div>
                            </div>
                            <div class="stat-box profit">
                                <div class="label"><i class="fas fa-chart-line me-1"></i>Lợi nhuận</div>
                                <div class="value text-purple" id="profitPercentDisplay">
                                    <fmt:formatNumber value="${stockDetail.profitPercent}" type="number" maxFractionDigits="1"/>%
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Stock History Card -->
                <div class="card">
                    <div class="card-header">
                        <h3><i class="fas fa-history me-2"></i>Lịch sử nhập kho</h3>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead>
                                    <tr>
                                        <th>#</th>
                                        <th>Ngày nhập</th>
                                        <th class="text-center">Số lượng</th>
                                        <th class="text-end">Giá nhập/đơn vị</th>
                                        <th class="text-end">Thành tiền</th>
                                        <th>Người nhập</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty receiptHistory}">
                                            <c:forEach var="receipt" items="${receiptHistory}" varStatus="status">
                                                <tr>
                                                    <td><span class="badge bg-secondary">#${receipt.receiptId}</span></td>
                                                    <td><fmt:formatDate value="${receipt.receiptDate}" pattern="dd/MM/yyyy HH:mm"/></td>
                                                    <td class="text-center"><strong>${receipt.quantity}</strong></td>
                                                    <td class="text-end"><fmt:formatNumber value="${receipt.unitCost}" type="number" maxFractionDigits="0"/>đ</td>
                                                    <td class="text-end"><strong><fmt:formatNumber value="${receipt.totalCost}" type="number" maxFractionDigits="0"/>đ</strong></td>
                                                    <td>
                                                        <i class="fas fa-user-circle me-1"></i>
                                                        ${not empty receipt.createdByName ? receipt.createdByName : 'N/A'}
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="6" class="text-center py-4 text-muted">
                                                    <i class="fas fa-inbox fa-2x mb-2 d-block"></i>
                                                    Chưa có lịch sử nhập kho
                                                </td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                                <c:if test="${not empty receiptHistory}">
                                    <tfoot style="background: #f8f9fa;">
                                        <tr>
                                            <td colspan="2"><strong>Tổng cộng</strong></td>
                                            <td class="text-center"><strong class="text-primary">${receiptSummary.totalQuantity}</strong></td>
                                            <td class="text-end">-</td>
                                            <td class="text-end"><strong class="text-primary"><fmt:formatNumber value="${receiptSummary.totalAmount}" type="number" maxFractionDigits="0"/>đ</strong></td>
                                            <td></td>
                                        </tr>
                                    </tfoot>
                                </c:if>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Right Column - Import Form -->
            <div class="col-lg-4">
                <div class="card">
                    <div class="card-header bg-success">
                        <h3><i class="fas fa-plus-circle me-2"></i>Nhập kho mới</h3>
                    </div>
                    <div class="card-body">
                        <form method="post" action="${pageContext.request.contextPath}/admin/stock/detail" id="stockForm">
                            <input type="hidden" name="variantId" value="${variantId}">
                            
                            <!-- Quantity -->
                            <div class="mb-3">
                                <label class="form-label">
                                    <i class="fas fa-sort-numeric-up me-1"></i>Số lượng nhập <span class="text-danger">*</span>
                                </label>
                                <input type="number" class="form-control" id="quantity" name="quantity" 
                                       placeholder="Nhập số lượng..." min="1" required>
                                <div class="form-text">Số lượng phải lớn hơn 0</div>
                            </div>

                            <!-- Unit Cost -->
                            <div class="mb-3">
                                <label class="form-label">
                                    <i class="fas fa-money-bill me-1"></i>Giá nhập/đơn vị <span class="text-danger">*</span>
                                </label>
                                <div class="input-group">
                                    <input type="number" class="form-control" id="unitCost" name="unitCost" 
                                           placeholder="Nhập giá..." min="1000" required>
                                    <span class="input-group-text">đ</span>
                                </div>
                                <div class="form-text">Giá nhập từ nhà cung cấp</div>
                            </div>

                            <!-- Preview -->
                            <div class="preview-box mb-4">
                                <div class="preview-label">Thành tiền</div>
                                <div class="preview-value" id="totalPreview">0đ</div>
                            </div>

                            <!-- Alert -->
                            <div class="alert alert-info mb-4">
                                <i class="fas fa-info-circle"></i>
                                <small>Sau khi nhập kho, hệ thống sẽ tự động cập nhật <strong>Tồn kho</strong> và <strong>Giá vốn trung bình</strong>.</small>
                            </div>

                            <!-- Buttons -->
                            <div class="d-grid gap-2">
                                <button type="submit" class="btn btn-primary btn-lg">
                                    <i class="fas fa-check me-2"></i>Xác nhận nhập kho
                                </button>
                                <a href="${pageContext.request.contextPath}/admin/products" class="btn btn-secondary">
                                    <i class="fas fa-arrow-left me-2"></i>Quay lại
                                </a>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- New Average Cost Preview -->
                <div class="card">
                    <div class="card-header bg-warning">
                        <h3><i class="fas fa-calculator me-2"></i>Dự tính sau nhập</h3>
                    </div>
                    <div class="card-body">
                        <div class="row text-center">
                            <div class="col-6">
                                <div class="text-muted small mb-1">Tồn kho mới</div>
                                <div class="h4 text-info mb-0" id="newStockPreview">${stockDetail.currentStock}</div>
                                <small class="text-success" id="stockChangePreview"></small>
                            </div>
                            <div class="col-6">
                                <div class="text-muted small mb-1">Giá vốn TB mới</div>
                                <div class="h4 text-warning mb-0" id="newAvgCostPreview">
                                    <fmt:formatNumber value="${stockDetail.avgCostPrice}" type="number" maxFractionDigits="0"/>đ
                                </div>
                                <small id="costChangePreview"></small>
                            </div>
                        </div>
                        <hr>
                        <div class="text-center">
                            <div class="text-muted small mb-1">Lợi nhuận mới</div>
                            <div class="h4 text-success mb-0" id="newProfitPreview">
                                <fmt:formatNumber value="${stockDetail.profitPercent}" type="number" maxFractionDigits="1"/>%
                            </div>
                            <small class="text-muted" id="profitAmountPreview">
                                (<fmt:formatNumber value="${stockDetail.profitAmount}" type="number" maxFractionDigits="0"/>đ / sản phẩm)
                            </small>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Current values from server
        const currentStock = parseInt('<c:out value="${stockDetail.currentStock}" default="0"/>');
        const currentTotalCost = parseFloat('<c:out value="${receiptSummary.totalAmount}" default="0"/>');
        const currentTotalQty = parseInt('<c:out value="${receiptSummary.totalQuantity}" default="0"/>');
        const sellingPrice = parseFloat('<c:out value="${stockDetail.sellingPrice}" default="0"/>');
        const currentAvgCost = parseFloat('<c:out value="${stockDetail.avgCostPrice}" default="0"/>');

        const quantityInput = document.getElementById('quantity');
        const unitCostInput = document.getElementById('unitCost');
        const totalPreview = document.getElementById('totalPreview');
        const newStockPreview = document.getElementById('newStockPreview');
        const stockChangePreview = document.getElementById('stockChangePreview');
        const newAvgCostPreview = document.getElementById('newAvgCostPreview');
        const costChangePreview = document.getElementById('costChangePreview');
        const newProfitPreview = document.getElementById('newProfitPreview');
        const profitAmountPreview = document.getElementById('profitAmountPreview');

        function formatCurrency(num) {
            return Math.round(num).toLocaleString('vi-VN') + 'đ';
        }

        function updatePreview() {
            const qty = parseInt(quantityInput.value) || 0;
            const cost = parseInt(unitCostInput.value) || 0;
            const total = qty * cost;
            
            // Update total preview
            totalPreview.textContent = formatCurrency(total);
            
            // Calculate new stock
            const newStock = currentStock + qty;
            newStockPreview.textContent = newStock;
            if (qty > 0) {
                stockChangePreview.innerHTML = '<i class="fas fa-arrow-up"></i> +' + qty;
                stockChangePreview.className = 'text-success';
            } else {
                stockChangePreview.textContent = '';
            }
            
            // Calculate new average cost
            if (qty > 0 && cost > 0) {
                const newTotalCost = currentTotalCost + total;
                const newTotalQty = currentTotalQty + qty;
                const newAvgCost = newTotalQty > 0 ? newTotalCost / newTotalQty : 0;
                
                newAvgCostPreview.textContent = formatCurrency(newAvgCost);
                
                const costDiff = newAvgCost - currentAvgCost;
                if (costDiff > 0) {
                    costChangePreview.innerHTML = '<i class="fas fa-arrow-up"></i> +' + formatCurrency(costDiff);
                    costChangePreview.className = 'text-danger';
                } else if (costDiff < 0) {
                    costChangePreview.innerHTML = '<i class="fas fa-arrow-down"></i> ' + formatCurrency(costDiff);
                    costChangePreview.className = 'text-success';
                } else {
                    costChangePreview.textContent = '';
                }
                
                // Calculate new profit
                if (sellingPrice > 0 && newAvgCost > 0) {
                    const newProfitAmount = sellingPrice - newAvgCost;
                    const newProfitPercent = (newProfitAmount / newAvgCost) * 100;
                    newProfitPreview.textContent = newProfitPercent.toFixed(1) + '%';
                    profitAmountPreview.textContent = '(' + formatCurrency(newProfitAmount) + ' / sản phẩm)';
                }
            } else {
                newAvgCostPreview.textContent = formatCurrency(currentAvgCost);
                costChangePreview.textContent = '';
            }
        }

        quantityInput.addEventListener('input', updatePreview);
        unitCostInput.addEventListener('input', updatePreview);

        // Form validation
        document.getElementById('stockForm').addEventListener('submit', function(e) {
            const qty = parseInt(quantityInput.value);
            const cost = parseInt(unitCostInput.value);
            
            if (!qty || qty <= 0) {
                e.preventDefault();
                alert('Vui lòng nhập số lượng hợp lệ (> 0)');
                quantityInput.focus();
                return;
            }
            
            if (!cost || cost <= 0) {
                e.preventDefault();
                alert('Vui lòng nhập giá nhập hợp lệ (> 0)');
                unitCostInput.focus();
                return;
            }
        });
    </script>
</body>
</html>
