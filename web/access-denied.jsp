<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Truy cập bị từ chối</title>

    <!-- Google Font -->
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">

    <!-- Css Styles -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css" type="text/css">
    
    <style>
        .access-denied-section {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .access-denied-box {
            background: white;
            padding: 60px;
            border-radius: 10px;
            box-shadow: 0 0 50px rgba(0,0,0,0.2);
            text-align: center;
            max-width: 600px;
        }
        .access-denied-icon {
            font-size: 100px;
            color: #ca1515;
            margin-bottom: 30px;
        }
        .access-denied-box h1 {
            font-size: 36px;
            font-weight: 700;
            color: #111;
            margin-bottom: 20px;
        }
        .access-denied-box p {
            font-size: 18px;
            color: #666;
            margin-bottom: 30px;
        }
        .btn-home {
            background: #667eea;
            color: white;
            padding: 15px 40px;
            border-radius: 5px;
            text-decoration: none;
            display: inline-block;
            font-weight: 600;
            transition: all 0.3s;
        }
        .btn-home:hover {
            background: #764ba2;
            color: white;
            text-decoration: none;
        }
    </style>
</head>

<body>
    <section class="access-denied-section">
        <div class="access-denied-box">
            <i class="fa fa-ban access-denied-icon"></i>
            <h1>Truy Cập Bị Từ Chối</h1>
            <p>Bạn không có quyền truy cập vào trang này.<br>
            Vui lòng đăng nhập với tài khoản có quyền phù hợp.</p>
            
            <div style="margin-top: 30px;">
                <a href="<%= request.getContextPath() %>/logout" class="btn-home">
                    <i class="fa fa-sign-out"></i> Đăng xuất và đăng nhập lại
                </a>
            </div>
            
            <div style="margin-top: 20px;">
                <a href="javascript:history.back()" style="color: #667eea; text-decoration: none;">
                    <i class="fa fa-arrow-left"></i> Quay lại trang trước
                </a>
            </div>
        </div>
    </section>

    <!-- Js Plugins -->
    <script src="<%= request.getContextPath() %>/js/jquery-3.3.1.min.js"></script>
    <script src="<%= request.getContextPath() %>/js/bootstrap.min.js"></script>
</body>
</html>
