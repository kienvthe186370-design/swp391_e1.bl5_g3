<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
    .stat-box { background: #f8f9fa; border-radius: 8px; padding: 15px; text-align: center; border-left: 4px solid #007bff; }
    .stat-box.stock { border-left-color: #17a2b8; }
    .stat-box.cost { border-left-color: #ffc107; }
    .stat-box.price { border-left-color: #28a745; }
    .stat-box.profit { border-left-color: #6f42c1; }
    .stat-box .label { font-size: 0.85rem; color: #6c757d; margin-bottom: 5px; }
    .stat-box .value { font-size: 1.4rem; font-weight: 700; }
    .preview-box { background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%); border: 2px dashed #ced4da; border-radius: 8px; padding: 20px; text-align: center; }
    .preview-box .preview-label { font-size: 0.85rem; color: #6c757d; margin-bottom: 5px; }
    .preview-box .preview-value { font-size: 1.5rem; font-weight: 700; color: #28a745; }
    .product-image { width: 100px; height: 100px; object-fit: cover; border-radius: 8px; border: 2px solid #e9ecef; }
</style>

<!-- Content Header -->
<div class="content-header">
    <div class="container-fluid">
        <div class="row mb-2">
            <div class="col-sm-6">
                <h1 class="m-0"><i class="fas fa-boxes mr-2"></i>Nhập kho sản phẩm</h1>
            </div>
            <div class="col-sm-6">
                <ol class="breadcrumb float-sm-right">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a></li>
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/stock">Quản lý kho</a></li>
                    <li class="breadcrumb-item active">Nhập kho</li>
                </ol>
            </div>
        </div>
    </div>
</div>

<!-- Main content -->
<section class="content">
    <div class="container-fluid">
        <!-- Success/Error Messages -->
        <c:if test="${not empty successMessage}">
            <div class="alert alert-success alert-dismissible fade show">
                <button type="button" class="close" data-dismiss="alert">&times;</button>
                <i class="fas fa-check-circle mr-2"></i>${successMessage}
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show">
                <button type="button" class="close" data-dismiss="alert">&times;</button>
                <i class="fas fa-exclamation-circle mr-2"></i>${errorMessage}
            </div>
        </c:if>

        <div class="row">
            <!-- Left Column -->
            <div class="col-lg-8">
                <!-- Product Info Card -->
                <div class="card card-info">
                    <div class="card-header">
                        <h3 class="card-title"><i class="fas fa-info-circle mr-2"></i>Thông tin sản phẩm</h3>
                    </div>
                    <div class="card-body">
                        <div class="d-flex">
                            <c:choose>
                                <c:when test="${not empty stockDetail.mainImage}">
                                    <img src="${stockDetail.mainImage}" alt="Product" class="product-image mr-3">
                                </c:when>
                                <c:otherwise>
                                    <img src="${pageContext.request.contextPath}/img/product/product-1.jpg" alt="No image" class="product-image mr-3">
                                </c:otherwise>
                            </c:choose>
                            <div>
                                <h4 class="mb-2">${stockDetail.productName}</h4>
                                <p class="text-muted mb-0">
                                    <i class="fas fa-barcode mr-1"></i> SKU: <code>${stockDetail.sku}</code>
                                    <span class="ml-3"><i class="fas fa-hashtag mr-1"></i> Variant ID: <strong>#${variantId}</strong></span>
                                </p>
                            </div>
                        </div>
                        
                        <!-- Stats -->
                        <div class="row mt-4">
                            <div class="col-md-3 col-6 mb-3">
                                <div class="stat-box stock">
                                    <div class="label"><i class="fas fa-cubes mr-1"></i>Tồn kho</div>
                                    <div class="value text-info" id="currentStockDisplay">${stockDetail.currentStock}</div>
                                </div>
                            </div>
                            <div class="col-md-3 col-6 mb-3">
                                <div class="stat-box cost">
                                    <div class="label"><i class="fas fa-coins mr-1"></i>Giá vốn TB</div>
                                    <div class="value text-warning">
                                        <fmt:formatNumber value="${stockDetail.avgCostPrice}" type="number" maxFractionDigits="0"/>đ
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3 col-6 mb-3">
                                <div class="stat-box price">
                                    <div class="label"><i class="fas fa-tag mr-1"></i>Giá bán</div>
                                    <div class="value text-success">
                                        <fmt:formatNumber value="${stockDetail.sellingPrice}" type="number" maxFractionDigits="0"/>đ
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3 col-6 mb-3">
                                <div class="stat-box profit">
                                    <div class="label"><i class="fas fa-chart-line mr-1"></i>Lợi nhuận</div>
                                    <div class="value text-purple">
                                        <fmt:formatNumber value="${stockDetail.profitPercent}" type="number" maxFractionDigits="1"/>%
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Stock History Card -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title"><i class="fas fa-history mr-2"></i>Lịch sử nhập kho</h3>
                    </div>
                    <div class="card-body table-responsive p-0">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Ngày nhập</th>
                                    <th class="text-center">Số lượng</th>
                                    <th class="text-right">Giá nhập/đơn vị</th>
                                    <th class="text-right">Thành tiền</th>
                                    <th>Người nhập</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty receiptHistory}">
                                        <c:forEach var="receipt" items="${receiptHistory}">
                                            <tr>
                                                <td><span class="badge badge-secondary">#${receipt.receiptId}</span></td>
                                                <td><fmt:formatDate value="${receipt.receiptDate}" pattern="dd/MM/yyyy HH:mm"/></td>
                                                <td class="text-center"><strong>${receipt.quantity}</strong></td>
                                                <td class="text-right"><fmt:formatNumber value="${receipt.unitCost}" type="number" maxFractionDigits="0"/>đ</td>
                                                <td class="text-right"><strong><fmt:formatNumber value="${receipt.totalCost}" type="number" maxFractionDigits="0"/>đ</strong></td>
                                                <td><i class="fas fa-user-circle mr-1"></i>${not empty receipt.createdByName ? receipt.createdByName : 'N/A'}</td>
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
                                <tfoot class="bg-light">
                                    <tr>
                                        <td colspan="2"><strong>Tổng cộng</strong></td>
                                        <td class="text-center"><strong class="text-primary">${receiptSummary.totalQuantity}</strong></td>
                                        <td class="text-right">-</td>
                                        <td class="text-right"><strong class="text-primary"><fmt:formatNumber value="${receiptSummary.totalAmount}" type="number" maxFractionDigits="0"/>đ</strong></td>
                                        <td></td>
                                    </tr>
                                </tfoot>
                            </c:if>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Right Column - Import Form -->
            <div class="col-lg-4">
                <div class="card card-success">
                    <div class="card-header">
                        <h3 class="card-title"><i class="fas fa-plus-circle mr-2"></i>Nhập kho mới</h3>
                    </div>
                    <div class="card-body">
                        <form method="post" action="${pageContext.request.contextPath}/admin/stock/detail" id="stockForm">
                            <input type="hidden" name="variantId" value="${variantId}">
                            
                            <div class="form-group">
                                <label><i class="fas fa-sort-numeric-up mr-1"></i>Số lượng nhập <span class="text-danger">*</span></label>
                                <input type="number" class="form-control" id="quantity" name="quantity" placeholder="Nhập số lượng..." min="1" required>
                                <small class="form-text text-muted">Số lượng phải lớn hơn 0</small>
                            </div>

                            <div class="form-group">
                                <label><i class="fas fa-money-bill mr-1"></i>Giá nhập/đơn vị <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <input type="number" class="form-control" id="unitCost" name="unitCost" placeholder="Nhập giá..." min="1000" required>
                                    <div class="input-group-append">
                                        <span class="input-group-text">đ</span>
                                    </div>
                                </div>
                                <small class="form-text text-muted">Giá nhập từ nhà cung cấp</small>
                            </div>

                            <div class="preview-box mb-3">
                                <div class="preview-label">Thành tiền</div>
                                <div class="preview-value" id="totalPreview">0đ</div>
                            </div>

                            <div class="alert alert-info">
                                <i class="fas fa-info-circle mr-1"></i>
                                <small>Sau khi nhập kho, hệ thống sẽ tự động cập nhật <strong>Tồn kho</strong> và <strong>Giá vốn TB</strong>.</small>
                            </div>

                            <button type="submit" class="btn btn-success btn-block btn-lg">
                                <i class="fas fa-check mr-2"></i>Xác nhận nhập kho
                            </button>
                            <a href="${pageContext.request.contextPath}/admin/stock" class="btn btn-secondary btn-block">
                                <i class="fas fa-arrow-left mr-2"></i>Quay lại danh sách
                            </a>
                        </form>
                    </div>
                </div>

                <!-- Preview Card -->
                <div class="card card-warning">
                    <div class="card-header">
                        <h3 class="card-title"><i class="fas fa-calculator mr-2"></i>Dự tính sau nhập</h3>
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
</section>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const currentStock = parseInt('${stockDetail.currentStock}') || 0;
    const currentTotalCost = parseFloat('${receiptSummary.totalAmount}') || 0;
    const currentTotalQty = parseInt('${receiptSummary.totalQuantity}') || 0;
    const sellingPrice = parseFloat('${stockDetail.sellingPrice}') || 0;
    const currentAvgCost = parseFloat('${stockDetail.avgCostPrice}') || 0;

    const quantityInput = document.getElementById('quantity');
    const unitCostInput = document.getElementById('unitCost');

    function formatCurrency(num) {
        return Math.round(num).toLocaleString('vi-VN') + 'đ';
    }

    function updatePreview() {
        const qty = parseInt(quantityInput.value) || 0;
        const cost = parseInt(unitCostInput.value) || 0;
        const total = qty * cost;
        
        document.getElementById('totalPreview').textContent = formatCurrency(total);
        
        const newStock = currentStock + qty;
        document.getElementById('newStockPreview').textContent = newStock;
        
        const stockChange = document.getElementById('stockChangePreview');
        if (qty > 0) {
            stockChange.innerHTML = '<i class="fas fa-arrow-up"></i> +' + qty;
            stockChange.className = 'text-success';
        } else {
            stockChange.textContent = '';
        }
        
        if (qty > 0 && cost > 0) {
            const newTotalCost = currentTotalCost + total;
            const newTotalQty = currentTotalQty + qty;
            const newAvgCost = newTotalQty > 0 ? newTotalCost / newTotalQty : 0;
            
            document.getElementById('newAvgCostPreview').textContent = formatCurrency(newAvgCost);
            
            const costDiff = newAvgCost - currentAvgCost;
            const costChange = document.getElementById('costChangePreview');
            if (costDiff > 0) {
                costChange.innerHTML = '<i class="fas fa-arrow-up"></i> +' + formatCurrency(costDiff);
                costChange.className = 'text-danger';
            } else if (costDiff < 0) {
                costChange.innerHTML = '<i class="fas fa-arrow-down"></i> ' + formatCurrency(costDiff);
                costChange.className = 'text-success';
            } else {
                costChange.textContent = '';
            }
            
            if (sellingPrice > 0 && newAvgCost > 0) {
                const newProfitAmount = sellingPrice - newAvgCost;
                const newProfitPercent = (newProfitAmount / newAvgCost) * 100;
                document.getElementById('newProfitPreview').textContent = newProfitPercent.toFixed(1) + '%';
                document.getElementById('profitAmountPreview').textContent = '(' + formatCurrency(newProfitAmount) + ' / sản phẩm)';
            }
        }
    }

    quantityInput.addEventListener('input', updatePreview);
    unitCostInput.addEventListener('input', updatePreview);

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
});
</script>
