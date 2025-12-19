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
            // Update cart count in header
            updateCartUI(data);
            
            // Update item total in the row
            const row = document.querySelector(`input[data-cart-item-id="${cartItemId}"]`).closest('tr');
            if (row) {
                const totalCell = row.querySelector('.cart__price');
                if (totalCell && data.itemTotal) {
                    totalCell.textContent = formatCurrency(data.itemTotal);
                }
            }
            
            // Update subtotal and total
            const subtotalElements = document.querySelectorAll('.cart-subtotal');
            subtotalElements.forEach(el => {
                el.textContent = formatCurrency(data.subtotal);
            });
            
            // Update total (assuming no discount for now)
            const totalElements = document.querySelectorAll('.cart__total ul li:last-child span');
            totalElements.forEach(el => {
                el.textContent = formatCurrency(data.subtotal);
            });
            
            showNotification('Đã cập nhật giỏ hàng', 'success');
        } else {
            showNotification(data.message || 'Cập nhật thất bại', 'error');
            
            // If exceeded stock, reset to max stock
            if (data.maxStock !== undefined) {
                const input = document.querySelector(`input[data-cart-item-id="${cartItemId}"]`);
                if (input) {
                    input.value = data.maxStock;
                    input.setAttribute('max', data.maxStock);
                }
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
        // Prevent non-numeric input (including 'e', '+', '-', '.')
        input.addEventListener('keydown', function(e) {
            // Allow: backspace, delete, tab, escape, enter
            if ([8, 9, 27, 13, 46].indexOf(e.keyCode) !== -1 ||
                // Allow: Ctrl+A, Ctrl+C, Ctrl+V, Ctrl+X
                (e.keyCode === 65 && e.ctrlKey === true) ||
                (e.keyCode === 67 && e.ctrlKey === true) ||
                (e.keyCode === 86 && e.ctrlKey === true) ||
                (e.keyCode === 88 && e.ctrlKey === true) ||
                // Allow: home, end, left, right
                (e.keyCode >= 35 && e.keyCode <= 39)) {
                return;
            }
            // Prevent: e, E, +, -, .
            if (e.key === 'e' || e.key === 'E' || e.key === '+' || e.key === '-' || e.key === '.') {
                e.preventDefault();
                return;
            }
            // Ensure that it is a number and stop the keypress if not
            if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
                e.preventDefault();
            }
        });
        
        // Prevent paste of non-numeric content
        input.addEventListener('paste', function(e) {
            const pastedData = e.clipboardData.getData('text');
            if (!/^\d+$/.test(pastedData)) {
                e.preventDefault();
                showNotification('Chỉ được nhập số', 'error');
            }
        });
        
        // Validate on input (real-time)
        input.addEventListener('input', function() {
            // Remove any non-digit characters
            this.value = this.value.replace(/[^\d]/g, '');
            
            const maxStock = parseInt(this.getAttribute('data-max'));
            const minStock = parseInt(this.getAttribute('data-min')) || 1;
            const currentValue = parseInt(this.value);
            const cartItemId = this.getAttribute('data-cart-item-id');
            
            // Check if exceeds stock
            if (currentValue > maxStock) {
                // Show warning below product
                showStockExceededWarning(cartItemId, maxStock);
                disableCheckoutButton(true);
            } else {
                // Hide warning
                hideStockExceededWarning(cartItemId);
                checkAndEnableCheckout();
            }
        });
        
        // Update cart on blur (when user finishes editing)
        input.addEventListener('blur', function() {
            const cartItemId = this.getAttribute('data-cart-item-id');
            const maxStock = parseInt(this.getAttribute('data-max'));
            const minStock = parseInt(this.getAttribute('data-min')) || 1;
            let quantity = parseInt(this.value);
            
            // Validate quantity
            if (isNaN(quantity) || this.value === '' || quantity < minStock) {
                this.value = minStock;
                quantity = minStock;
            }
            
            if (quantity > maxStock) {
                showNotification(`Chỉ còn ${maxStock} sản phẩm trong kho. Đã điều chỉnh số lượng.`, 'warning');
                this.value = maxStock;
                quantity = maxStock;
            }
            
            // Update cart
            updateCartQuantity(cartItemId, quantity);
        });
    });
}

/**
 * Show stock exceeded warning for a specific cart item
 */
function showStockExceededWarning(cartItemId, maxStock) {
    // Check if warning already exists
    let warning = document.querySelector(`.stock-exceeded-warning[data-cart-item-id="${cartItemId}"]`);
    
    if (!warning) {
        // Find the product text div
        const input = document.querySelector(`input[data-cart-item-id="${cartItemId}"]`);
        const productTextDiv = input.closest('tr').querySelector('.product__cart__item__text');
        
        // Create warning
        warning = document.createElement('div');
        warning.className = 'alert alert-danger p-2 mt-2 stock-exceeded-warning';
        warning.style.fontSize = '13px';
        warning.setAttribute('data-cart-item-id', cartItemId);
        warning.innerHTML = `
            <i class="fa fa-exclamation-triangle"></i> <strong>Vượt quá tồn kho!</strong><br>
            <small>Chỉ còn ${maxStock} sản phẩm. Vui lòng giảm số lượng.</small>
        `;
        
        productTextDiv.appendChild(warning);
    } else {
        // Update existing warning
        warning.innerHTML = `
            <i class="fa fa-exclamation-triangle"></i> <strong>Vượt quá tồn kho!</strong><br>
            <small>Chỉ còn ${maxStock} sản phẩm. Vui lòng giảm số lượng.</small>
        `;
    }
}

/**
 * Hide stock exceeded warning for a specific cart item
 */
function hideStockExceededWarning(cartItemId) {
    const warning = document.querySelector(`.stock-exceeded-warning[data-cart-item-id="${cartItemId}"]`);
    if (warning) {
        warning.remove();
    }
}

/**
 * Disable/enable checkout button
 */
function disableCheckoutButton(disable) {
    const checkoutBtn = document.querySelector('.primary-btn.checkout-btn-enabled, .primary-btn.checkout-btn-disabled');
    const checkoutWarning = document.querySelector('.stock-exceeded-checkout-warning');
    
    if (checkoutBtn) {
        if (disable) {
            checkoutBtn.classList.remove('checkout-btn-enabled');
            checkoutBtn.classList.add('checkout-btn-disabled');
            checkoutBtn.style.backgroundColor = '#ccc';
            checkoutBtn.style.cursor = 'not-allowed';
            checkoutBtn.style.pointerEvents = 'none';
            checkoutBtn.onclick = function() { return false; };
            
            // Show warning if not exists
            if (!checkoutWarning) {
                const cartTotal = document.querySelector('.cart__total ul');
                const warning = document.createElement('div');
                warning.className = 'alert alert-danger mb-3 stock-exceeded-checkout-warning';
                warning.style.fontSize = '14px';
                warning.innerHTML = `
                    <i class="fa fa-exclamation-triangle"></i> 
                    <strong>Không thể thanh toán</strong><br>
                    Có sản phẩm vượt quá số lượng tồn kho. Vui lòng điều chỉnh số lượng.
                `;
                cartTotal.parentNode.insertBefore(warning, cartTotal.nextSibling);
            }
        } else {
            checkoutBtn.classList.remove('checkout-btn-disabled');
            checkoutBtn.classList.add('checkout-btn-enabled');
            checkoutBtn.style.backgroundColor = '';
            checkoutBtn.style.cursor = '';
            checkoutBtn.style.pointerEvents = '';
            checkoutBtn.onclick = null;
            
            // Hide warning
            if (checkoutWarning) {
                checkoutWarning.remove();
            }
        }
    }
}

/**
 * Check if any item exceeds stock and enable/disable checkout accordingly
 */
function checkAndEnableCheckout() {
    const allInputs = document.querySelectorAll('.cart-quantity-input');
    let hasExceeded = false;
    
    allInputs.forEach(input => {
        const currentValue = parseInt(input.value);
        const maxStock = parseInt(input.getAttribute('data-max'));
        
        if (currentValue > maxStock) {
            hasExceeded = true;
        }
    });
    
    if (!hasExceeded) {
        disableCheckoutButton(false);
    }
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
