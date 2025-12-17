/**
 * Product Duplicate Check - Realtime validation
 * Kiểm tra trùng lặp sản phẩm và biến thể khi người dùng nhập liệu
 */

var ProductDuplicateCheck = (function() {
    var debounceTimer = null;
    var contextPath = '';
    
    /**
     * Khởi tạo module
     * @param {string} path - Context path của ứng dụng
     */
    function init(path) {
        contextPath = path || '';
    }
    
    /**
     * Kiểm tra tên sản phẩm trùng lặp
     * @param {string} productName - Tên sản phẩm cần kiểm tra
     * @param {number|null} excludeId - ID sản phẩm cần loại trừ (khi edit)
     * @param {function} callback - Callback function(result)
     */
    function checkProductName(productName, excludeId, callback) {
        if (!productName || productName.trim() === '') {
            callback({ duplicate: false });
            return;
        }
        
        clearTimeout(debounceTimer);
        debounceTimer = setTimeout(function() {
            var url = contextPath + '/admin/api/check-duplicate?type=product-name&name=' + 
                      encodeURIComponent(productName.trim());
            
            if (excludeId) {
                url += '&excludeId=' + excludeId;
            }
            
            fetch(url)
                .then(function(response) { return response.json(); })
                .then(function(data) { callback(data); })
                .catch(function(error) { 
                    console.error('Error checking product name:', error);
                    callback({ duplicate: false, error: error.message });
                });
        }, 500); // Debounce 500ms
    }
    
    /**
     * Kiểm tra SKU trùng lặp
     * @param {string} sku - SKU cần kiểm tra
     * @param {number|null} excludeVariantId - ID variant cần loại trừ (khi edit)
     * @param {function} callback - Callback function(result)
     */
    function checkSku(sku, excludeVariantId, callback) {
        if (!sku || sku.trim() === '') {
            callback({ duplicate: false });
            return;
        }
        
        clearTimeout(debounceTimer);
        debounceTimer = setTimeout(function() {
            var url = contextPath + '/admin/api/check-duplicate?type=sku&sku=' + 
                      encodeURIComponent(sku.trim());
            
            if (excludeVariantId) {
                url += '&excludeVariantId=' + excludeVariantId;
            }
            
            fetch(url)
                .then(function(response) { return response.json(); })
                .then(function(data) { callback(data); })
                .catch(function(error) { 
                    console.error('Error checking SKU:', error);
                    callback({ duplicate: false, error: error.message });
                });
        }, 500);
    }
    
    /**
     * Kiểm tra variant trùng lặp (cùng tổ hợp attribute values)
     * @param {number} productId - ID sản phẩm
     * @param {Array<number>} valueIds - Danh sách ValueID
     * @param {number|null} excludeVariantId - ID variant cần loại trừ
     * @param {function} callback - Callback function(result)
     */
    function checkVariant(productId, valueIds, excludeVariantId, callback) {
        if (!productId || !valueIds || valueIds.length === 0) {
            callback({ duplicate: false });
            return;
        }
        
        var url = contextPath + '/admin/api/check-duplicate?type=variant&productId=' + productId +
                  '&valueIds=' + valueIds.join(',');
        
        if (excludeVariantId) {
            url += '&excludeVariantId=' + excludeVariantId;
        }
        
        fetch(url)
            .then(function(response) { return response.json(); })
            .then(function(data) { callback(data); })
            .catch(function(error) { 
                console.error('Error checking variant:', error);
                callback({ duplicate: false, error: error.message });
            });
    }
    
    /**
     * Hiển thị cảnh báo trùng lặp sản phẩm
     * @param {HTMLElement} inputElement - Input element
     * @param {Object} result - Kết quả kiểm tra
     */
    function showProductDuplicateWarning(inputElement, result) {
        // Xóa warning cũ nếu có
        var existingWarning = inputElement.parentElement.querySelector('.duplicate-warning');
        if (existingWarning) {
            existingWarning.remove();
        }
        
        if (result.duplicate) {
            inputElement.classList.add('is-invalid');
            
            var warning = document.createElement('div');
            warning.className = 'duplicate-warning text-warning mt-1';
            warning.innerHTML = '<i class="fas fa-exclamation-triangle"></i> ' +
                'Sản phẩm "<strong>' + escapeHtml(result.productName) + '</strong>" đã tồn tại. ' +
                '<a href="' + contextPath + '/admin/product-edit?id=' + result.productId + 
                '" class="text-primary" target="_blank">Xem sản phẩm</a>';
            
            inputElement.parentElement.appendChild(warning);
        } else {
            inputElement.classList.remove('is-invalid');
        }
    }
    
    /**
     * Hiển thị cảnh báo trùng lặp SKU
     * @param {HTMLElement} inputElement - Input element
     * @param {Object} result - Kết quả kiểm tra
     */
    function showSkuDuplicateWarning(inputElement, result) {
        var existingWarning = inputElement.parentElement.querySelector('.duplicate-warning');
        if (existingWarning) {
            existingWarning.remove();
        }
        
        if (result.duplicate) {
            inputElement.classList.add('is-invalid');
            
            var warning = document.createElement('div');
            warning.className = 'duplicate-warning text-warning mt-1';
            warning.innerHTML = '<i class="fas fa-exclamation-triangle"></i> ' +
                'SKU "<strong>' + escapeHtml(result.sku) + '</strong>" đã tồn tại trong sản phẩm "' + 
                escapeHtml(result.productName) + '". ' +
                '<a href="' + contextPath + '/admin/product-edit?id=' + result.productId + 
                '" class="text-primary" target="_blank">Xem sản phẩm</a>';
            
            inputElement.parentElement.appendChild(warning);
        } else {
            inputElement.classList.remove('is-invalid');
        }
    }
    
    /**
     * Hiển thị cảnh báo trùng lặp variant
     * @param {HTMLElement} container - Container element
     * @param {Object} result - Kết quả kiểm tra
     */
    function showVariantDuplicateWarning(container, result) {
        var existingWarning = container.querySelector('.variant-duplicate-warning');
        if (existingWarning) {
            existingWarning.remove();
        }
        
        if (result.duplicate) {
            var attrText = '';
            if (result.attributes && result.attributes.length > 0) {
                attrText = result.attributes.map(function(a) {
                    return a.attributeName + ': ' + a.valueName;
                }).join(', ');
            }
            
            var warning = document.createElement('div');
            warning.className = 'variant-duplicate-warning alert alert-warning mt-2';
            warning.innerHTML = '<i class="fas fa-exclamation-triangle"></i> ' +
                'Biến thể với tổ hợp thuộc tính này đã tồn tại! ' +
                '<br><strong>SKU:</strong> ' + escapeHtml(result.sku) +
                (attrText ? '<br><strong>Thuộc tính:</strong> ' + escapeHtml(attrText) : '') +
                '<br><em>Vui lòng chọn tổ hợp thuộc tính khác hoặc chỉnh sửa biến thể đã có.</em>';
            
            container.appendChild(warning);
        }
    }
    
    /**
     * Escape HTML để tránh XSS
     */
    function escapeHtml(text) {
        if (!text) return '';
        var div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
    
    /**
     * Attach validation vào input tên sản phẩm
     * @param {string} selector - CSS selector của input
     * @param {number|null} excludeId - ID sản phẩm cần loại trừ
     */
    function attachProductNameValidation(selector, excludeId) {
        var input = document.querySelector(selector);
        if (!input) return;
        
        input.addEventListener('blur', function() {
            checkProductName(this.value, excludeId, function(result) {
                showProductDuplicateWarning(input, result);
            });
        });
        
        input.addEventListener('input', function() {
            // Xóa warning khi user đang nhập
            var warning = this.parentElement.querySelector('.duplicate-warning');
            if (warning) warning.remove();
            this.classList.remove('is-invalid');
        });
    }
    
    /**
     * Attach validation vào input SKU
     * @param {string} selector - CSS selector của input
     * @param {number|null} excludeVariantId - ID variant cần loại trừ
     */
    function attachSkuValidation(selector, excludeVariantId) {
        var input = document.querySelector(selector);
        if (!input) return;
        
        input.addEventListener('blur', function() {
            checkSku(this.value, excludeVariantId, function(result) {
                showSkuDuplicateWarning(input, result);
            });
        });
        
        input.addEventListener('input', function() {
            var warning = this.parentElement.querySelector('.duplicate-warning');
            if (warning) warning.remove();
            this.classList.remove('is-invalid');
        });
    }
    
    // Public API
    return {
        init: init,
        checkProductName: checkProductName,
        checkSku: checkSku,
        checkVariant: checkVariant,
        showProductDuplicateWarning: showProductDuplicateWarning,
        showSkuDuplicateWarning: showSkuDuplicateWarning,
        showVariantDuplicateWarning: showVariantDuplicateWarning,
        attachProductNameValidation: attachProductNameValidation,
        attachSkuValidation: attachSkuValidation
    };
})();
