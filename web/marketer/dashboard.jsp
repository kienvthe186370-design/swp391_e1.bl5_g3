<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entity.Employee" %>
<%
    Employee employee = (Employee) session.getAttribute("employee");
    if (employee == null || !"Marketer".equalsIgnoreCase(employee.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Marketer Dashboard - <%= employee.getFullName() %></title>

    <!-- Google Font -->
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">

    <!-- Css Styles -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/bootstrap.min.css" type="text/css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css" type="text/css">
    
    <style>
        .dashboard-header {
            background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
            color: white;
            padding: 40px 0;
        }
        .dashboard-card {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
            margin-bottom: 30px;
            transition: transform 0.3s;
        }
        .dashboard-card:hover {
            transform: translateY(-5px);
        }
        .stat-icon {
            font-size: 48px;
            color: #fa709a;
            margin-bottom: 15px;
        }
        .sidebar {
            background: #2c3e50;
            min-height: 100vh;
            padding: 20px 0;
        }
        .sidebar a {
            color: #ecf0f1;
            padding: 15px 25px;
            display: block;
            text-decoration: none;
            transition: all 0.3s;
        }
        .sidebar a:hover, .sidebar a.active {
            background: #34495e;
            border-left: 4px solid #fa709a;
        }
    </style>
</head>

<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-2 sidebar">
                <div style="text-align: center; padding: 20px 0; border-bottom: 1px solid #34495e;">
                    <h4 style="color: white;">Marketer Panel</h4>
                    <p style="color: #95a5a6; font-size: 14px;"><%= employee.getFullName() %></p>
                </div>
                <a href="<%= request.getContextPath() %>/marketer/dashboard" class="active"><i class="fa fa-dashboard"></i> Dashboard</a>
                <a href="<%= request.getContextPath() %>/marketer/campaigns"><i class="fa fa-bullhorn"></i> Chiến dịch</a>
                <a href="<%= request.getContextPath() %>/marketer/vouchers"><i class="fa fa-ticket"></i> Voucher</a>
                <a href="<%= request.getContextPath() %>/marketer/blog"><i class="fa fa-newspaper-o"></i> Blog</a>
                <a href="<%= request.getContextPath() %>/marketer/sliders"><i class="fa fa-image"></i> Slider</a>
                <a href="<%= request.getContextPath() %>/marketer/analytics"><i class="fa fa-line-chart"></i> Phân tích</a>
                <a href="<%= request.getContextPath() %>/marketer/profile"><i class="fa fa-user"></i> Tài khoản</a>
                <a href="<%= request.getContextPath() %>/logout"><i class="fa fa-sign-out"></i> Đăng xuất</a>
            </div>

            <!-- Main Content -->
            <div class="col-md-10">
                <!-- Header -->
                <div class="dashboard-header">
                    <div class="container">
                        <h2>Chào mừng, <%= employee.getFullName() %>!</h2>
                        <p>Trang quản lý Marketing - Quản lý chiến dịch, voucher và nội dung</p>
                    </div>
                </div>

                <!-- Stats Cards -->
                <div class="container" style="margin-top: 30px;">
                    <div class="row">
                        <div class="col-md-3">
                            <div class="dashboard-card text-center">
                                <i class="fa fa-bullhorn stat-icon"></i>
                                <h3>0</h3>
                                <p>Chiến dịch đang chạy</p>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="dashboard-card text-center">
                                <i class="fa fa-ticket stat-icon"></i>
                                <h3>0</h3>
                                <p>Voucher active</p>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="dashboard-card text-center">
                                <i class="fa fa-newspaper-o stat-icon"></i>
                                <h3>0</h3>
                                <p>Bài viết</p>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="dashboard-card text-center">
                                <i class="fa fa-users stat-icon"></i>
                                <h3>0</h3>
                                <p>Khách hàng mới</p>
                            </div>
                        </div>
                    </div>

                    <!-- Recent Campaigns -->
                    <div class="row">
                        <div class="col-md-12">
                            <div class="dashboard-card">
                                <h4>Chiến dịch gần đây</h4>
                                <p style="color: #999;">Chưa có chiến dịch nào</p>
                            </div>
                        </div>
                    </div>

                    <!-- Analytics -->
                    <div class="row">
                        <div class="col-md-6">
                            <div class="dashboard-card">
                                <h4>Hiệu suất Marketing</h4>
                                <p style="color: #999;">Chưa có dữ liệu</p>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="dashboard-card">
                                <h4>Voucher phổ biến</h4>
                                <p style="color: #999;">Chưa có dữ liệu</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Js Plugins -->
    <script src="<%= request.getContextPath() %>/js/jquery-3.3.1.min.js"></script>
    <script src="<%= request.getContextPath() %>/js/bootstrap.min.js"></script>
</body>
</html>
