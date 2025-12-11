<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Xác thực OTP - Pickleball Shop</title>
        <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="css/bootstrap.min.css" type="text/css">
        <link rel="stylesheet" href="css/font-awesome.min.css" type="text/css">
        <link rel="stylesheet" href="css/style.css" type="text/css">
        <style>
            .otp-section {
                padding: 80px 0;
                min-height: 600px;
            }
            .otp-form {
                max-width: 500px;
                margin: 0 auto;
                background: #fff;
                padding: 50px;
                border-radius: 5px;
                box-shadow: 0 0 20px rgba(0,0,0,0.05);
            }
            .otp-form h3 {
                text-align: center;
                margin-bottom: 10px;
                font-weight: 700;
                color: #111;
            }
            .otp-form p {
                text-align: center;
                color: #666;
                margin-bottom: 30px;
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
            .resend-link {
                text-align: center;
                margin-top: 20px;
            }
            .resend-link a {
                color: #ca1515;
                cursor: pointer;
                text-decoration: none;
            }
            .resend-link a:hover {
                text-decoration: underline;
            }
            .resend-link a.disabled {
                color: #999;
                pointer-events: none;
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
            .alert-success {
                background-color: #d4edda;
                border: 1px solid #c3e6cb;
                color: #155724;
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
                            <h4>Xác Thực OTP</h4>
                            <div class="breadcrumb__links">
                                <a href="./index.jsp">Trang chủ</a>
                                <span>Xác thực OTP</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>


        <section class="otp-section">
            <div class="container">
                <div class="row">
                    <div class="col-lg-12">
                        <div class="otp-form">
                            <h3>Xác Thực OTP</h3>
                            <p>Nhập mã 6 số đã được gửi đến<br><strong><%= request.getAttribute("email") %></strong></p>

                            <% if (request.getAttribute("error") != null) { %>
                            <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
                            <% } %>

                            <div class="timer" id="timer">
                                Mã hết hạn sau: <span id="countdown"><%= request.getAttribute("remainingSeconds") != null ? request.getAttribute("remainingSeconds") : 0 %></span> giây
                            </div>

                            <form action="verify-otp" method="post" id="otpForm">
                                <div class="otp-input">
                                    <input type="text" maxlength="1" class="otp-digit" data-index="0" autofocus>
                                    <input type="text" maxlength="1" class="otp-digit" data-index="1">
                                    <input type="text" maxlength="1" class="otp-digit" data-index="2">
                                    <input type="text" maxlength="1" class="otp-digit" data-index="3">
                                    <input type="text" maxlength="1" class="otp-digit" data-index="4">
                                    <input type="text" maxlength="1" class="otp-digit" data-index="5">
                                </div>
                                <input type="hidden" name="otp" id="otpValue">
                                <button type="submit" class="site-btn">Xác Nhận</button>
                            </form>

                            <div class="resend-link">
                                <span>Không nhận được mã? </span>
                                <a href="javascript:void(0)" id="resendBtn" onclick="resendOTP()">Gửi lại</a>
                            </div>
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
                                            updateOTPValue();
                                        });
                                        input.addEventListener('keydown', (e) => {
                                            if (e.key === 'Backspace' && !e.target.value && index > 0) {
                                                otpInputs[index - 1].focus();
                                            }
                                        });
                                        input.addEventListener('paste', (e) => {
                                            e.preventDefault();
                                            const pastedData = e.clipboardData.getData('text').replace(/[^0-9]/g, '').slice(0, 6);
                                            pastedData.split('').forEach((char, i) => {
                                                if (otpInputs[i])
                                                    otpInputs[i].value = char;
                                            });
                                            updateOTPValue();
                                            if (pastedData.length > 0)
                                                otpInputs[Math.min(pastedData.length, 5)].focus();
                                        });
                                    });

                                    function updateOTPValue() {
                                        let otp = '';
                                        otpInputs.forEach(input => otp += input.value);
                                        document.getElementById('otpValue').value = otp;
                                    }

                                    // Countdown timer
                                    let seconds = parseInt('<%= request.getAttribute("remainingSeconds") != null ? request.getAttribute("remainingSeconds") : 0 %>');
                                    const timerEl = document.getElementById('timer');
                                    const countdownEl = document.getElementById('countdown');

                                    if (seconds > 0) {
                                        const countdown = setInterval(() => {
                                            seconds--;
                                            if (seconds <= 0) {
                                                clearInterval(countdown);
                                                timerEl.classList.add('expired');
                                                timerEl.innerHTML = 'Mã OTP đã hết hạn. Vui lòng <a href="javascript:void(0)" onclick="resendOTP()">gửi lại</a>.';
                                            } else {
                                                countdownEl.textContent = seconds;
                                            }
                                        }, 1000);
                                    }

                                    // Resend OTP
                                    function resendOTP() {
                                        const btn = document.getElementById('resendBtn');
                                        if (btn) {
                                            btn.classList.add('disabled');
                                            btn.textContent = 'Đang gửi...';
                                        }

                                        fetch('resend-otp', {method: 'POST'})
                                                .then(res => res.json())
                                                .then(data => {
                                                    if (data.success) {
                                                        alert('Mã OTP mới đã được gửi!');
                                                        location.reload();
                                                    } else {
                                                        alert(data.message);
                                                        if (btn) {
                                                            btn.classList.remove('disabled');
                                                            btn.textContent = 'Gửi lại';
                                                        }
                                                    }
                                                })
                                                .catch(err => {
                                                    alert('Có lỗi xảy ra. Vui lòng thử lại.');
                                                    if (btn) {
                                                        btn.classList.remove('disabled');
                                                        btn.textContent = 'Gửi lại';
                                                    }
                                                });
                                    }
        </script>
    </body>
</html>
