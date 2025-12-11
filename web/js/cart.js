/**
 * Shopping Cart JavaScript
 * Handles AJAX operations for cart management
 */

// Get context path
const contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf("/", 2));

/**
 * Update cart item quantity
 * @param {number} cartItemId - Cart item ID
 * @param {number} quantity - New quantity
 */
function updateCartQuantity(cartItemId, quantity) {
    // Validate quantity
    if (quantity < 0) {
        showNotification('Số lượng không hợp lệ', 'error');
        return;
    }
    
    // Show loading
    showLoading(true);
    
    // Send AJAX request
    fetch(contextPath + '/cart/update', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: `cartItemId=${cartItemId}&quantity=${quantity}`
    })
    .then(response => response.json())
    .then(data => {
        showLoading(false);
        
        if (data.success) {
            // Update UI
            updateCartUI(data);
            showNotification('Đã cập nhật giỏ hàng', 'success');
            
            // Reload page to update totals
            setTimeout(() => {
                location.reload();
            }, 500);
        } else {
            showNotification(data.message || 'Cập nhật thất bại', 'error');
        }
    })
    .catch(error => {
        showLoading(false);
        console.error('Error:', error);
        showNotification('Có lỗi xảy ra', 'error');
    });
}

/**
 * Remove item from cart
 * @param {number} cartItemId - Cart item ID
 */
function removeCartItem(cartItemId) {
    if (!confirm('Bạn có chắc muốn xóa sản phẩm này khỏi giỏ hàng?')) {
        return;
    }
    
    showLoading(true);
    
    // Redirect to remove URL
    window.location.href = contextPath + '/cart/remove?cartItemId=' + cartItemId;
}

/**
 * Clear entire cart
 */
function clearCart() {
    if (!confirm('Bạn có chắc muốn xóa toàn bộ giỏ hàng?')) {
        return;
    }
    
    showLoading(true);
    
    // Send POST request
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = contextPath + '/cart/clear';
    document.body.appendChild(form);
    form.submit();
}

/**
 * Add product to cart
 * @param {number} productId - Product ID
 * @param {number|null} variantId - Variant ID (optional)
 * @param {number} quantity - Quantity
 * @param {string} source - Source page (for redirect)
 */
function addToCart(productId, variantId, quantity, source) {
    // Validate
    if (!productId || quantity <= 0) {
        showNotification('Thông tin không hợp lệ', 'error');
        return;
    }
    
    showLoading(true);
    
    // Build URL
    let url = contextPath + '/cart/add?productId=' + productId + '&quantity=' + quantity;
    if (variantId) {
        url += '&variantId=' + variantId;
    }
    if (source) {
        url += '&source=' + source;
    }
    
    // Redirect to add URL
    window.location.href = url;
}

/**
 * Quick add to cart (AJAX - no page reload)
 * @param {number} productId - Product ID
 * @param {number} quantity - Quantity
 */
function quickAddToCart(productId, quantity = 1) {
    showLoading(true);
    
    fetch(contextPath + '/cart/add?productId=' + productId + '&quantity=' + quantity, {
        method: 'GET'
    })
    .then(response => {
        showLoading(false);
        
        if (response.redirected) {
            // Check if redirected to error page
            if (response.url.includes('error=')) {
                showNotification('Không thể thêm vào giỏ hàng', 'error');
            } else {
                showNotification('Đã thêm vào giỏ hàng', 'success');
                // Update cart count
                updateCartCount();
            }
        }
    })
    .catch(error => {
        showLoading(false);
        console.error('Error:', error);
        showNotification('Có lỗi xảy ra', 'error');
    });
}

/**
 * Update cart count in header
 */
function updateCartCount() {
    fetch(contextPath + '/cart/count')
    .then(response => response.json())
    .then(data => {
        // Update cart badge
        const badges = document.querySelectorAll('.cart-count, .header__nav__option span');
        badges.forEach(badge => {
            badge.textContent = data.count;
        });
    })
    .catch(error => {
        console.error('Error updating cart count:', error);
    });
}

/**
 * Update cart UI after changes
 * @param {object} data - Response data
 */
function updateCartUI(data) {
    // Update cart count
    if (data.itemCount !== undefined) {
        const badges = document.querySelectorAll('.cart-count, .header__nav__option span');
        badges.forEach(badge => {
            badge.textContent = data.itemCount;
        });
    }
    
    // Update subtotal
    if (data.subtotal !== undefined) {
        const subtotalElements = document.querySelectorAll('.cart-subtotal, .cart__total ul li:first-child span');
        subtotalElements.forEach(el => {
            el.textContent = formatCurrency(data.subtotal);
        });
    }
}

/**
 * Format currency (VND)
 * @param {number} amount - Amount in VND
 * @returns {string} Formatted string
 */
function formatCurrency(amount) {
    return new Intl.NumberFormat('vi-VN', {
        style: 'currency',
        currency: 'VND'
    }).format(amount);
}

/**
 * Show notification toast
 * @param {string} message - Message to show
 * @param {string} type - Type: success, error, info
 */
function showNotification(message, type = 'info') {
    // Check if toast container exists
    let container = document.getElementById('toast-container');
    if (!container) {
        container = document.createElement('div');
        container.id = 'toast-container';
        container.style.cssText = 'position: fixed; top: 20px; right: 20px; z-index: 9999;';
        document.body.appendChild(container);
    }
    
    // Create toast
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.style.cssText = `
        background: ${type === 'success' ? '#28a745' : type === 'error' ? '#dc3545' : '#17a2b8'};
        color: white;
        padding: 15px 20px;
        margin-bottom: 10px;
        border-radius: 5px;
        box-shadow: 0 2px 5px rgba(0,0,0,0.2);
        animation: slideIn 0.3s ease-out;
    `;
    toast.textContent = message;
    
    container.appendChild(toast);
    
    // Auto remove after 3 seconds
    setTimeout(() => {
        toast.style.animation = 'slideOut 0.3s ease-out';
        setTimeout(() => {
            container.removeChild(toast);
        }, 300);
    }, 3000);
}

/**
 * Show/hide loading overlay
 * @param {boolean} show - Show or hide
 */
function showLoading(show) {
    let overlay = document.getElementById('loading-overlay');
    
    if (show) {
        if (!overlay) {
            overlay = document.createElement('div');
            overlay.id = 'loading-overlay';
            overlay.style.cssText = `
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0,0,0,0.5);
                display: flex;
                align-items: center;
                justify-content: center;
                z-index: 9998;
            `;
            overlay.innerHTML = '<div class="spinner-border text-light" role="status"><span class="sr-only">Loading...</span></div>';
            document.body.appendChild(overlay);
        }
        overlay.style.display = 'flex';
    } else {
        if (overlay) {
            overlay.style.display = 'none';
        }
    }
}

/**
 * Handle quantity input change
 */
function setupQuantityInputs() {
    const quantityInputs = document.querySelectorAll('.cart-quantity-input');
    
    quantityInputs.forEach(input => {
        input.addEventListener('change', function() {
            const cartItemId = this.getAttribute('data-cart-item-id');
            const quantity = parseInt(this.value);
            const maxStock = parseInt(this.getAttribute('max'));
            
            if (quantity > maxStock) {
                showNotification('Số lượng vượt quá tồn kho', 'error');
                this.value = maxStock;
                return;
            }
            
            if (quantity < 1) {
                if (confirm('Xóa sản phẩm này khỏi giỏ hàng?')) {
                    removeCartItem(cartItemId);
                } else {
                    this.value = 1;
                }
                return;
            }
            
            updateCartQuantity(cartItemId, quantity);
        });
    });
}

/**
 * Handle quantity +/- buttons
 */
function setupQuantityButtons() {
    // Plus buttons
    document.querySelectorAll('.qty-btn-plus').forEach(btn => {
        btn.addEventListener('click', function() {
            const input = this.parentElement.querySelector('input');
            const max = parseInt(input.getAttribute('max'));
            let value = parseInt(input.value);
            
            if (value < max) {
                input.value = value + 1;
                input.dispatchEvent(new Event('change'));
            } else {
                showNotification('Đã đạt số lượng tối đa', 'info');
            }
        });
    });
    
    // Minus buttons
    document.querySelectorAll('.qty-btn-minus').forEach(btn => {
        btn.addEventListener('click', function() {
            const input = this.parentElement.querySelector('input');
            let value = parseInt(input.value);
            
            if (value > 1) {
                input.value = value - 1;
                input.dispatchEvent(new Event('change'));
            }
        });
    });
}

/**
 * Initialize cart page
 */
function initCartPage() {
    setupQuantityInputs();
    setupQuantityButtons();
    
    // Update cart count on page load
    updateCartCount();
}

// Auto-initialize when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initCartPage);
} else {
    initCartPage();
}

// Add CSS animations
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes slideOut {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(100%);
            opacity: 0;
        }
    }
`;
document.head.appendChild(style);
