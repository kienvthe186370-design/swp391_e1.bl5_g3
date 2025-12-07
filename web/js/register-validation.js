/**
 * register-validation.js
 * Real-time validation cho form đăng ký
 * 
 * Chức năng:
 * 1. Validate email format
 * 2. Check email đã tồn tại (AJAX)
 * 3. Validate phone number
 * 4. Validate password strength
 * 5. Check password match
 * 6. Prevent double submit
 */

$(document).ready(function() {
    // ============================================
    // BIẾN GLOBAL
    // ============================================
    let isEmailValid = false;
    let isEmailChecking = false;
    let emailCheckTimeout = null;
    
    // Lấy context path từ URL
    const contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf("/",2));
    
    // ============================================
    // VALIDATE EMAIL FORMAT (Client-side)
    // ============================================
    function validateEmailFormat(email) {
        // Regex pattern cho email
        const emailPattern = /^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
        return emailPattern.test(email);
    }
    
    // ============================================
    // CHECK EMAIL TỒN TẠI (AJAX)
    // ============================================
    function checkEmailExists(email) {
        isEmailChecking = true;
        $('#emailError').text('Đang kiểm tra...').css('color', '#999');
        $('#emailSuccess').text('');
        
        $.ajax({
            url: contextPath + '/check-email',
            type: 'GET',
            data: { email: email },
            dataType: 'json',
            success: function(response) {
                isEmailChecking = false;
                
                if (response.valid && !response.exists) {
                    // Email hợp lệ và chưa tồn tại
                    isEmailValid = true;
                    $('#emailError').text('');
                    $('#emailSuccess').text('✓ ' + response.message).css('color', '#28a745');
                } else if (response.exists) {
                    // Email đã tồn tại
                    isEmailValid = false;
                    $('#emailError').text('✗ ' + response.message).css('color', '#dc3545');
                    $('#emailSuccess').text('');
                } else {
                    // Email không hợp lệ
                    isEmailValid = false;
                    $('#emailError').text('✗ ' + response.message).css('color', '#dc3545');
                    $('#emailSuccess').text('');
                }
            },
            error: function() {
                isEmailChecking = false;
                $('#emailError').text('Lỗi kiểm tra email').css('color', '#dc3545');
                $('#emailSuccess').text('');
            }
        });
    }
    
    // ============================================
    // EMAIL INPUT - Real-time validation
    // ============================================
    $('#email').on('input', function() {
        const email = $(this).val().trim();
        
        // Clear timeout cũ
        if (emailCheckTimeout) {
            clearTimeout(emailCheckTimeout);
        }
        
        // Reset messages
        $('#emailError').text('');
        $('#emailSuccess').text('');
        isEmailValid = false;
        
        // Kiểm tra empty
        if (email === '') {
            return;
        }
        
        // Kiểm tra format trước
        if (!validateEmailFormat(email)) {
            $('#emailError').text('✗ Email không đúng định dạng').css('color', '#dc3545');
            return;
        }
        
        // Delay 500ms trước khi gọi AJAX (tránh gọi quá nhiều)
        emailCheckTimeout = setTimeout(function() {
            checkEmailExists(email);
        }, 500);
    });
    
    // ============================================
    // FULL NAME VALIDATION
    // ============================================
    $('#fullName').on('blur', function() {
        const name = $(this).val().trim();
        
        if (name === '') {
            $('#fullNameError').text('✗ Tên không được để trống').css('color', '#dc3545');
        } else if (name.length < 2) {
            $('#fullNameError').text('✗ Tên phải có ít nhất 2 ký tự').css('color', '#dc3545');
        } else if (!/^[\p{L}\s]+$/u.test(name)) {
            $('#fullNameError').text('✗ Tên chỉ được chứa chữ cái').css('color', '#dc3545');
        } else {
            $('#fullNameError').text('');
        }
    });
    
    // ============================================
    // PHONE VALIDATION
    // ============================================
    $('#phone').on('blur', function() {
        const phone = $(this).val().trim();
        const phonePattern = /^(0|\+84)[0-9]{9,10}$/;
        
        if (phone === '') {
            $('#phoneError').text('✗ Số điện thoại không được để trống').css('color', '#dc3545');
        } else if (!phonePattern.test(phone.replace(/[\s-]/g, ''))) {
            $('#phoneError').text('✗ Số điện thoại không hợp lệ (10 số, bắt đầu bằng 0)').css('color', '#dc3545');
        } else {
            $('#phoneError').text('');
        }
    });
    
    // ============================================
    // PASSWORD VALIDATION
    // ============================================
    $('#password').on('input', function() {
        const password = $(this).val();
        
        if (password.length === 0) {
            $('#passwordError').text('');
        } else if (password.length < 6) {
            $('#passwordError').text('✗ Mật khẩu phải có ít nhất 6 ký tự').css('color', '#dc3545');
        } else {
            $('#passwordError').text('✓ Mật khẩu hợp lệ').css('color', '#28a745');
        }
        
        // Kiểm tra confirm password nếu đã nhập
        if ($('#confirmPassword').val().length > 0) {
            $('#confirmPassword').trigger('input');
        }
    });
    
    // ============================================
    // CONFIRM PASSWORD VALIDATION
    // ============================================
    $('#confirmPassword').on('input', function() {
        const password = $('#password').val();
        const confirmPassword = $(this).val();
        
        if (confirmPassword.length === 0) {
            $('#confirmPasswordError').text('');
        } else if (password !== confirmPassword) {
            $('#confirmPasswordError').text('✗ Mật khẩu không khớp').css('color', '#dc3545');
        } else {
            $('#confirmPasswordError').text('✓ Mật khẩu khớp').css('color', '#28a745');
        }
    });
    
    // ============================================
    // FORM SUBMIT VALIDATION
    // ============================================
    $('#registerForm').on('submit', function(e) {
        // Nếu đang check email, chặn submit
        if (isEmailChecking) {
            e.preventDefault();
            alert('Vui lòng đợi kiểm tra email hoàn tất');
            return false;
        }
        
        // Nếu email không hợp lệ, chặn submit
        if (!isEmailValid) {
            e.preventDefault();
            alert('Vui lòng nhập email hợp lệ và chưa được đăng ký');
            $('#email').focus();
            return false;
        }
        
        // Kiểm tra password khớp
        if ($('#password').val() !== $('#confirmPassword').val()) {
            e.preventDefault();
            alert('Mật khẩu xác nhận không khớp');
            $('#confirmPassword').focus();
            return false;
        }
        
        // Disable submit button để tránh double submit
        $('#submitBtn').prop('disabled', true).text('Đang xử lý...');
        
        return true;
    });
});
