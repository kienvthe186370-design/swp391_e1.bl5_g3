<%-- 
    Document   : contact
    Created on : Dec 4, 2025, 2:20:22 PM
    Author     : xuand
    Modified   : Updated content for Pickleball Online Shop
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="description" content="Liên hệ Pickleball Shop Vietnam - Hỗ trợ tư vấn mua hàng">
    <meta name="keywords" content="Pickleball, liên hệ, hỗ trợ, tư vấn">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Liên Hệ | Pickleball Shop Vietnam</title>

    <!-- Google Font -->
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap"
        rel="stylesheet">

    <!-- Css Styles -->
    <link rel="stylesheet" href="css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="css/elegant-icons.css" type="text/css">
    <link rel="stylesheet" href="css/magnific-popup.css" type="text/css">
    <link rel="stylesheet" href="css/nice-select.css" type="text/css">
    <link rel="stylesheet" href="css/owl.carousel.min.css" type="text/css">
    <link rel="stylesheet" href="css/slicknav.min.css" type="text/css">
    <link rel="stylesheet" href="css/style.css" type="text/css">
    
    <!-- Custom CSS -->
    <style>
        .contact-info-box {
            background: #f5f5f5;
            padding: 30px;
            border-radius: 10px;
            text-align: center;
            margin-bottom: 20px;
            transition: all 0.3s ease;
            height: 100%;
        }
        .contact-info-box:hover {
            background: #e53637;
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(229, 54, 55, 0.3);
        }
        .contact-info-box:hover i,
        .contact-info-box:hover h5,
        .contact-info-box:hover p {
            color: #fff !important;
        }
        .contact-info-box i {
            font-size: 40px;
            color: #e53637;
            margin-bottom: 15px;
            transition: all 0.3s ease;
        }
        .contact-info-box h5 {
            font-size: 18px;
            font-weight: 700;
            margin-bottom: 10px;
            transition: all 0.3s ease;
        }
        .contact-info-box p {
            margin: 0;
            color: #666;
            transition: all 0.3s ease;
        }
        .quick-action-btn {
            display: inline-block;
            padding: 12px 30px;
            margin: 10px;
            border-radius: 25px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        .btn-zalo {
            background: #0068ff;
            color: #fff;
        }
        .btn-zalo:hover {
            background: #0052cc;
            color: #fff;
            transform: translateY(-3px);
        }
        .btn-messenger {
            background: #00b2ff;
            color: #fff;
        }
        .btn-messenger:hover {
            background: #0099e6;
            color: #fff;
            transform: translateY(-3px);
        }
        .btn-call {
            background: #28a745;
            color: #fff;
        }
        .btn-call:hover {
            background: #218838;
            color: #fff;
            transform: translateY(-3px);
        }
        .faq-section {
            background: #f9f9f9;
        }
        .faq-item {
            background: #fff;
            padding: 20px;
            margin-bottom: 15px;
            border-radius: 8px;
            border-left: 4px solid #e53637;
        }
        .faq-item h6 {
            font-weight: 700;
            margin-bottom: 10px;
            color: #111;
        }
        .faq-item p {
            margin: 0;
            color: #666;
        }
        .cta-section {
            background: linear-gradient(135deg, #e53637 0%, #ff6b6b 100%);
            padding: 60px 0;
        }
        .cta-section h3 {
            color: #fff;
            font-weight: 700;
            margin-bottom: 15px;
        }
        .cta-section p {
            color: rgba(255,255,255,0.9);
            margin-bottom: 25px;
        }
        .btn-cta {
            background: #fff;
            color: #e53637;
            padding: 15px 40px;
            border-radius: 30px;
            font-weight: 700;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s ease;
        }
        .btn-cta:hover {
            background: #111;
            color: #fff;
            transform: translateY(-3px);
        }
    </style>
</head>

<body>
    <%@include file="header.jsp"%>

    <!-- Breadcrumb Section Begin -->
    <section class="breadcrumb-option">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="breadcrumb__text">
                        <h4>Liên Hệ</h4>
                        <div class="breadcrumb__links">
                            <a href="index.jsp">Trang Chủ</a>
                            <span>Liên Hệ</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
    <!-- Breadcrumb Section End -->

    <!-- Quick Contact Info Begin -->
    <section class="spad">
        <div class="container">
            <div class="row">
                <div class="col-lg-3 col-md-6 col-sm-6">
                    <div class="contact-info-box">
                        <i class="fa fa-map-marker"></i>
                        <h5>Địa Chỉ</h5>
                        <p>Khu CNC Hòa Lạc, Thạch Thất, Hà Nội</p>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6 col-sm-6">
                    <div class="contact-info-box">
                        <i class="fa fa-phone"></i>
                        <h5>Hotline</h5>
                        <p>1900 1234</p>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6 col-sm-6">
                    <div class="contact-info-box">
                        <i class="fa fa-envelope"></i>
                        <h5>Email</h5>
                        <p>support@pickleballshop.vn</p>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6 col-sm-6">
                    <div class="contact-info-box">
                        <i class="fa fa-clock-o"></i>
                        <h5>Giờ Làm Việc</h5>
                        <p>T2 - T7: 8:00 - 18:00</p>
                    </div>
                </div>
            </div>
            
            <!-- Quick Action Buttons -->
            <div class="row mt-5">
                <div class="col-lg-12 text-center">
                    <h4 class="mb-4">Liên Hệ Nhanh</h4>
                    <a href="#" class="quick-action-btn btn-zalo">
                        <i class="fa fa-commenting"></i> Chat Zalo
                    </a>
                    <a href="#" class="quick-action-btn btn-messenger">
                        <i class="fa fa-facebook"></i> Messenger
                    </a>
                    <a href="tel:19001234" class="quick-action-btn btn-call">
                        <i class="fa fa-phone"></i> Gọi Ngay
                    </a>
                </div>
            </div>
        </div>
    </section>
    <!-- Quick Contact Info End -->

    <!-- Map Begin -->
    <div class="map">
        <iframe src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3724.096949675498!2d105.5248713!3d21.0124289!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x3135abc60e7d3f19%3A0x2be9d7d0b5abcbf4!2zxJDhuqFpIGjhu41jIEZQVCBIw6AgTuG7mWk!5e0!3m2!1svi!2s!4v1701234567890!5m2!1svi!2s" 
                height="450" style="border:0;" allowfullscreen="" aria-hidden="false" tabindex="0"></iframe>
    </div>
    <!-- Map End -->

    <!-- Contact Form Section Begin -->
    <section class="contact spad">
        <div class="container">
            <div class="row">
                <div class="col-lg-6 col-md-6">
                    <div class="contact__text">
                        <div class="section-title">
                            <span>Gửi Tin Nhắn</span>
                            <h2>Liên Hệ Với Chúng Tôi</h2>
                            <p>Bạn có câu hỏi về sản phẩm hoặc cần hỗ trợ? Hãy để lại tin nhắn, 
                               chúng tôi sẽ phản hồi trong vòng 24 giờ!</p>
                        </div>
                        <div class="contact__form">
                            <form action="#" method="post">
                                <div class="row">
                                    <div class="col-lg-6">
                                        <input type="text" name="name" placeholder="Họ và tên *" required>
                                    </div>
                                    <div class="col-lg-6">
                                        <input type="email" name="email" placeholder="Email *" required>
                                    </div>
                                    <div class="col-lg-6">
                                        <input type="tel" name="phone" placeholder="Số điện thoại">
                                    </div>
                                    <div class="col-lg-6">
                                        <select name="subject" class="form-control" style="height: 50px; margin-bottom: 20px;">
                                            <option value="">-- Chọn chủ đề --</option>
                                            <option value="product">Tư vấn sản phẩm</option>
                                            <option value="order">Hỏi về đơn hàng</option>
                                            <option value="warranty">Bảo hành / Đổi trả</option>
                                            <option value="wholesale">Hợp tác / Đại lý</option>
                                            <option value="other">Khác</option>
                                        </select>
                                    </div>
                                    <div class="col-lg-12">
                                        <textarea name="message" placeholder="Nội dung tin nhắn *" required></textarea>
                                        <button type="submit" class="site-btn">
                                            <i class="fa fa-paper-plane"></i> Gửi Tin Nhắn
                                        </button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6 col-md-6">
                    <div class="section-title">
                        <span>FAQ</span>
                        <h2>Câu Hỏi Thường Gặp</h2>
                    </div>
                    <div class="faq-item">
                        <h6><i class="fa fa-question-circle text-danger"></i> Sản phẩm có chính hãng không?</h6>
                        <p>100% sản phẩm tại shop đều là hàng chính hãng, nhập khẩu trực tiếp từ nhà sản xuất, 
                           có đầy đủ tem nhãn và bảo hành.</p>
                    </div>
                    <div class="faq-item">
                        <h6><i class="fa fa-question-circle text-danger"></i> Thời gian giao hàng bao lâu?</h6>
                        <p>Nội thành Hà Nội: 1-2 ngày. Các tỉnh thành khác: 2-5 ngày làm việc.</p>
                    </div>
                    <div class="faq-item">
                        <h6><i class="fa fa-question-circle text-danger"></i> Chính sách đổi trả như thế nào?</h6>
                        <p>Đổi trả miễn phí trong 7 ngày nếu sản phẩm lỗi từ nhà sản xuất. 
                           Hoàn tiền 100% nếu không đúng mô tả.</p>
                    </div>
                    <div class="faq-item">
                        <h6><i class="fa fa-question-circle text-danger"></i> Có hỗ trợ mua số lượng lớn không?</h6>
                        <p>Có! Chúng tôi có chính sách giá đặc biệt cho đại lý và khách mua sỉ. 
                           Liên hệ hotline để được tư vấn.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>
    <!-- Contact Form Section End -->

    <!-- CTA Section Begin -->
    <section class="cta-section text-center">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-8">
                    <h3>Bạn Muốn Trở Thành Đại Lý?</h3>
                    <p>Tham gia hệ thống đại lý của chúng tôi để nhận được mức giá ưu đãi nhất 
                       và nhiều chính sách hỗ trợ hấp dẫn!</p>
                    <a href="register.jsp" class="btn-cta">
                        <i class="fa fa-handshake-o"></i> Đăng Ký Ngay
                    </a>
                </div>
            </div>
        </div>
    </section>
    <!-- CTA Section End -->

    <%@include file="footer.jsp"%>

    <!-- Js Plugins -->
    <script src="js/jquery-3.3.1.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <script src="js/jquery.nice-select.min.js"></script>
    <script src="js/jquery.nicescroll.min.js"></script>
    <script src="js/jquery.magnific-popup.min.js"></script>
    <script src="js/jquery.countdown.min.js"></script>
    <script src="js/jquery.slicknav.js"></script>
    <script src="js/mixitup.min.js"></script>
    <script src="js/owl.carousel.min.js"></script>
    <script src="js/main.js"></script>
</body>

</html>
