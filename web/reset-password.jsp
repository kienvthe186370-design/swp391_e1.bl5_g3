<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Đặt Lại Mật Khẩu - Pickleball Shop</title>
        <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="css/bootstrap.min.css" type="text/css">
        <link rel="stylesheet" href="css/font-awesome.min.css" type="text/css">
        <link rel="stylesheet" href="css/style.css" type="text/css">
        <style>
            .reset-section {
                padding: 80px 0;
                min-height: 600px;
            }
            .reset-form {
                max-width: 500px;
                margin: 0 auto;
                background: #fff;
                padding: 50px;
                border-radius: 5px;
                box-shadow: 0 0 20px rgba(0,0,0,0.05);
            }
            .reset-form h3 {
                text-align: center;
                margin-bottom: 10px;
                font-weight: 700;
                color: #111;
            }
            .reset-form p {
                text-align: center;
                color: #666;
                margin-bottom: 30px;
            }
            .form-group {
                margin-bottom: 25px;
            }
            .form-group label {
                font-weight: 600;
                color: #111;
                margin-bottom: 10px;
                display: block;
            }
            .form-group input {
                width: 100%;
                height: 50px;
                border: 1px solid #e1e1e1;
                padding: 0 20px;
                font-size: 14px;
                border-radius: 4px;
            }
            .form-group input:focus {
                border-color: #ca1515;
                outline: none;
            }
            .form-group small {
                color: #666;
                font-size: 12px;
                margin-top: 5px;
                display: block;
            }
            .otp-input {
                display: flex;
                justify-content: center;
                gap: 10px;
                margin-bottom: 20px;
            }
            .otp-input input {
                width: 50px;
                height: 60px;
                text-align: center;
                font-size: 24px;
                border: 2px solid #e1e1e1;
                border-radius: 8px;
            }
            .otp-input input:focus {
                border-color: #ca1515;
                outline: none;
            }
            .timer {
                text-align: center;
                color: #666;
                margin-bottom: 20px;
                font-size: 14px;
            }
            .timer.expired {
                color: #dc3545;
            }
            .site-btn {
                width: 100%;
                height: 50px;
                background: #ca1515;
                border: none;
                color: #fff;
                font-weight: 700;
                cursor: pointer;
                border-radius: 4px;
                text-transform: uppercase;
                letter-spacing: 2px;
            }
            .site-btn:hover {
                background: #111;
            }
            .alert {
                padding: 15px;
                margin-bottom: 20px;
                border-radius: 4px;
            }
            .alert-danger {
                background-color: #f8d7da;
                border: 1px solid #f5c6cb;
                color: #721c24;
            }
            .resend-link {
                text-align: center;
                margin-top: 20px;
            }
            .resend-link a {
                color: #ca1515;
                cursor: pointer;
                text-decoration: none;
            }
        </style>
    </head>
    <body>
        <%@include file="header.jsp" %>

        <section class="breadcrumb-option">
            <div class="container">
                <div class="row">
                    <div class="col-lg-12">
                        <div class="breadcrumb__text">
                            <h4>Đặt lại mật khẩu</h4>
                            <div class="breadcrumb__links">
                                <a href="./index.jsp">Trang chủ</a>
                                <span>Đặt lại mật khẩu</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>


        <section class="reset-section">
            <div class="container">
                <div class="row">
                    <div class="col-lg-12">
                        <div class="reset-form">
                            <h3>Đặt lại mật khẩu</h3>

                            <% Boolean otpVerified = (Boolean) request.getAttribute("otpVerified"); %>

                            <% if (otpVerified == null || !otpVerified) { %>
                            <!-- Buoc 1: Nhap OTP -->
                            <p>Nhập mã OTP đã được gửi đến: <br><strong><%= request.getAttribute("email") %></strong></p>

                            <% if (request.getAttribute("error") != null) { %>
                            <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
                            <% } %>

                            <div class="timer" id="timer">
                                Mã hết hạn sau: <span id="countdown"><%= request.getAttribute("remainingSeconds") != null ? request.getAttribute("remainingSeconds") : 0 %></span> giay
                            </div>

                            <form action="reset-password" method="post">
                                <div class="otp-input">
                                    <input type="text" maxlength="1" class="otp-digit" autofocus>
                                    <input type="text" maxlength="1" class="otp-digit">
                                    <input type="text" maxlength="1" class="otp-digit">
                                    <input type="text" maxlength="1" class="otp-digit">
                                    <input type="text" maxlength="1" class="otp-digit">
                                    <input type="text" maxlength="1" class="otp-digit">
                                </div>
                                <input type="hidden" name="otp" id="otpValue">
                                <button type="submit" class="site-btn">Xác Nhận OTP</button>
                            </form>

                            <div class="resend-link">
                                <span>Không nhận được mã? </span>
                                <a href="javascript:void(0)" onclick="resendOTP()">Gui lai</a>
                            </div>
                            <% } else { %>
                            <!-- Buoc 2: Nhập mật khẩu mới -->
                            <p>Nhập mật khẩu mới cho tài khoản của bạn</p>

                            <% if (request.getAttribute("error") != null) { %>
                            <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
                            <% } %>

                            <form action="reset-password" method="post">
                                <div class="form-group">
                                    <label>Mật khẩu mới</label>
                                    <input type="password" name="newPassword" placeholder="Nhap mat khau moi" required>
                                    <small>Tối thiểu 8 ký tự, bao gồm cả chữ hoa, chữ thường và số</small>
                                </div>
                                <div class="form-group">
                                    <label>Xác nhận mật khẩu</label>
                                    <input type="password" name="confirmPassword" placeholder="Nhap lai mat khau" required>
                                </div>
                                <button type="submit" class="site-btn">Đổi mật khẩu</button>
                            </form>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <%@include file="footer.jsp" %>

        <script src="js/jquery-3.3.1.min.js"></script>
        <script src="js/bootstrap.min.js"></script>
        <script src="js/main.js"></script>
        <script>
                                    const otpInputs = document.querySelectorAll('.otp-digit');
                                    otpInputs.forEach((input, index) => {
                                        input.addEventListener('input', (e) => {
                                            const value = e.target.value.replace(/[^0-9]/g, '');
                                            e.target.value = value;
                                            if (value.length === 1 && index < 5) {
                                                otpInputs[index + 1].focus();
                                            }
                                            let otp = '';
                                            otpInputs.forEach(inp => otp += inp.value);
                                            document.getElementById('otpValue').value = otp;
                                        });
                                        input.addEventListener('keydown', (e) => {
                                            if (e.key === 'Backspace' && !e.target.value && index > 0) {
                                                otpInputs[index - 1].focus();
                                            }
                                        });
                                    });

                                    let seconds = parseInt('<%= request.getAttribute("remainingSeconds") != null ? request.getAttribute("remainingSeconds") : 0 %>');
                                    if (seconds > 0) {
                                        const timerEl = document.getElementById('timer');
                                        const countdownEl = document.getElementById('countdown');
                                        const countdown = setInterval(() => {
                                            seconds--;
                                            if (countdownEl)
                                                countdownEl.textContent = seconds;
                                            if (seconds <= 0) {
                                                clearInterval(countdown);
                                                if (timerEl) {
                                                    timerEl.classList.add('expired');
                                                    timerEl.innerHTML = 'Ma OTP da het han. Vui long <a href="forgot-password">yeu cau ma moi</a>.';
                                                }
                                            }
                                        }, 1000);
                                    }

                                    function resendOTP() {
                                        fetch('resend-otp', {method: 'POST'})
                                                .then(res => res.json())
                                                .then(data => {
                                                    alert(data.message);
                                                    if (data.success)
                                                        location.reload();
                                                });
                                    }
        </script>
    </body>
</html>
