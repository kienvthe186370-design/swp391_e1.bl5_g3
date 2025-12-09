/**
 * ImageValidator - Utility class để validate ảnh upload
 * Sử dụng: ImageValidator.validate(file, options) hoặc ImageValidator.attach(selector, options)
 * 
 * @author Auto-generated from spec
 * @version 1.0
 */
const ImageValidator = {
    // Cấu hình mặc định
    defaultOptions: {
        allowedTypes: ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'],
        allowedExtensions: ['.jpg', '.jpeg', '.png', '.gif'],
        maxSize: 2 * 1024 * 1024, // 2MB in bytes
        maxSizeLabel: '2MB'
    },

    /**
     * Validate file ảnh
     * @param {File} file - File object từ input
     * @param {Object} options - Tùy chọn (optional)
     * @returns {Object} - { valid: boolean, error: string|null }
     */
    validate: function(file, options) {
        options = options || {};
        var config = Object.assign({}, this.defaultOptions, options);

        // Kiểm tra file có tồn tại không
        if (!file) {
            return { valid: false, error: 'Vui lòng chọn file ảnh.' };
        }

        // Kiểm tra định dạng file (MIME type)
        var fileType = file.type ? file.type.toLowerCase() : '';
        if (!config.allowedTypes.includes(fileType)) {
            return { 
                valid: false, 
                error: 'Định dạng không hợp lệ. Chỉ chấp nhận: ' + config.allowedExtensions.join(', ').toUpperCase()
            };
        }

        // Kiểm tra extension (phòng trường hợp MIME type bị giả mạo)
        var fileName = file.name ? file.name.toLowerCase() : '';
        var hasValidExtension = config.allowedExtensions.some(function(ext) {
            return fileName.endsWith(ext);
        });
        if (!hasValidExtension) {
            return { 
                valid: false, 
                error: 'Định dạng không hợp lệ. Chỉ chấp nhận: ' + config.allowedExtensions.join(', ').toUpperCase()
            };
        }

        // Kiểm tra kích thước file
        if (file.size > config.maxSize) {
            var fileSizeMB = (file.size / (1024 * 1024)).toFixed(2);
            return { 
                valid: false, 
                error: 'Kích thước file (' + fileSizeMB + 'MB) vượt quá giới hạn ' + config.maxSizeLabel + '.'
            };
        }

        return { valid: true, error: null };
    },

    /**
     * Validate nhiều files cùng lúc
     * @param {FileList} files - FileList từ input multiple
     * @param {Object} options - Tùy chọn (optional)
     * @returns {Object} - { valid: boolean, errors: string[] }
     */
    validateMultiple: function(files, options) {
        var errors = [];
        var self = this;
        
        if (!files || files.length === 0) {
            return { valid: false, errors: ['Vui lòng chọn ít nhất 1 file ảnh.'] };
        }

        for (var i = 0; i < files.length; i++) {
            var result = self.validate(files[i], options);
            if (!result.valid) {
                errors.push('File "' + files[i].name + '": ' + result.error);
            }
        }

        return { 
            valid: errors.length === 0, 
            errors: errors 
        };
    },

    /**
     * Hiển thị thông báo lỗi
     * @param {HTMLElement} inputElement - Input file element
     * @param {string} message - Thông báo lỗi
     */
    showError: function(inputElement, message) {
        // Xóa thông báo cũ nếu có
        this.clearError(inputElement);

        // Thêm class invalid
        inputElement.classList.add('is-invalid');

        // Tạo element hiển thị lỗi
        var errorDiv = document.createElement('div');
        errorDiv.className = 'invalid-feedback image-validator-error';
        errorDiv.style.display = 'block';
        errorDiv.textContent = message;

        // Tìm parent container phù hợp để chèn error
        var parent = inputElement.parentNode;
        
        // Nếu input nằm trong custom-file div, chèn sau custom-file div
        if (parent && parent.classList && parent.classList.contains('custom-file')) {
            parent.parentNode.insertBefore(errorDiv, parent.nextSibling);
        } else {
            parent.insertBefore(errorDiv, inputElement.nextSibling);
        }
    },

    /**
     * Xóa thông báo lỗi
     * @param {HTMLElement} inputElement - Input file element
     */
    clearError: function(inputElement) {
        inputElement.classList.remove('is-invalid');
        inputElement.classList.remove('is-valid');
        
        // Tìm và xóa error message
        var parent = inputElement.parentNode;
        
        // Kiểm tra trong custom-file container
        if (parent && parent.classList && parent.classList.contains('custom-file')) {
            var existingError = parent.parentNode.querySelector('.image-validator-error');
            if (existingError) {
                existingError.remove();
            }
        } else {
            var existingError = parent.querySelector('.image-validator-error');
            if (existingError) {
                existingError.remove();
            }
        }
    },

    /**
     * Hiển thị thông báo thành công
     * @param {HTMLElement} inputElement - Input file element
     */
    showSuccess: function(inputElement) {
        this.clearError(inputElement);
        inputElement.classList.add('is-valid');
    },

    /**
     * Attach validation vào input file
     * @param {string|HTMLElement} selector - Selector hoặc element
     * @param {Object} options - Tùy chọn (optional)
     */
    attach: function(selector, options) {
        var self = this;
        options = options || {};
        
        var input = typeof selector === 'string' 
            ? document.querySelector(selector) 
            : selector;

        if (!input) {
            console.error('ImageValidator: Input element not found');
            return;
        }

        input.addEventListener('change', function(e) {
            var files = e.target.files;
            
            if (files.length === 0) {
                self.clearError(input);
                return;
            }

            // Validate single hoặc multiple
            if (input.multiple) {
                var result = self.validateMultiple(files, options);
                if (!result.valid) {
                    self.showError(input, result.errors.join(' | '));
                    input.value = ''; // Clear input
                    
                    // Reset label nếu có
                    var label = input.nextElementSibling;
                    if (label && label.classList && label.classList.contains('custom-file-label')) {
                        label.textContent = label.getAttribute('data-default-text') || 'Chọn file';
                    }
                } else {
                    self.showSuccess(input);
                }
            } else {
                var result = self.validate(files[0], options);
                if (!result.valid) {
                    self.showError(input, result.error);
                    input.value = ''; // Clear input
                    
                    // Reset label nếu có
                    var label = input.nextElementSibling;
                    if (label && label.classList && label.classList.contains('custom-file-label')) {
                        label.textContent = label.getAttribute('data-default-text') || 'Chọn file';
                    }
                } else {
                    self.showSuccess(input);
                }
            }
        });
    }
};

// Export for module systems (if available)
if (typeof module !== 'undefined' && module.exports) {
    module.exports = ImageValidator;
}
