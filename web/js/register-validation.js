$(document).ready(function() {
    let isEmailValid = false;
    let isEmailChecking = false;
    let emailCheckTimeout = null;
    
    const contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf("/",2));
    
    function validateEmailFormat(email) {
        const emailPattern = /^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
        return emailPattern.test(email);
    }
    
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
                    isEmailValid = true;
                    $('#emailError').text('');
                    $('#emailSuccess').text('✓ ' + response.message).css('color', '#28a745');
                } else if (response.exists) {
                    isEmailValid = false;
                    $('#emailError').text('✗ ' + response.message).css('color', '#dc3545');
                    $('#emailSuccess').text('');
                } else {
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
    
    $('#email').on('input', function() {
        const email = $(this).val().trim();
        
        if (emailCheckTimeout) {
            clearTimeout(emailCheckTimeout);
        }
        
        $('#emailError').text('');
        $('#emailSuccess').text('');
        isEmailValid = false;
        
        if (email === '') {
            return;
        }
        
        if (!validateEmailFormat(email)) {
            $('#emailError').text('✗ Email không đúng định dạng').css('color', '#dc3545');
            return;
        }
        
        emailCheckTimeout = setTimeout(function() {
            checkEmailExists(email);
        }, 500);
    });
    
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
    
    $('#password').on('input', function() {
        const password = $(this).val();
        
        if (password.length === 0) {
            $('#passwordError').text('');
        } else if (password.length < 6) {
            $('#passwordError').text('✗ Mật khẩu phải có ít nhất 6 ký tự').css('color', '#dc3545');
        } else {
            $('#passwordError').text('✓ Mật khẩu hợp lệ').css('color', '#28a745');
        }
        
        if ($('#confirmPassword').val().length > 0) {
            $('#confirmPassword').trigger('input');
        }
    });
    
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
    
    $('#registerForm').on('submit', function(e) {
        if (isEmailChecking) {
            e.preventDefault();
            alert('Vui lòng đợi kiểm tra email hoàn tất');
            return false;
        }
        
        if (!isEmailValid) {
            e.preventDefault();
            alert('Vui lòng nhập email hợp lệ và chưa được đăng ký');
            $('#email').focus();
            return false;
        }
        
        if ($('#password').val() !== $('#confirmPassword').val()) {
            e.preventDefault();
            alert('Mật khẩu xác nhận không khớp');
            $('#confirmPassword').focus();
            return false;
        }
        
        $('#submitBtn').prop('disabled', true).text('Đang xử lý...');
        
        return true;
    });
});
