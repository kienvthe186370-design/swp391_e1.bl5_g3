# Pickleball Shop - E-commerce Platform

Hệ thống thương mại điện tử bán vợt và phụ kiện Pickleball với quản lý phân quyền đa cấp.

## 🚀 Tính Năng

### Khách Hàng (Customer)
- ✅ Đăng ký tài khoản
- ✅ Đăng nhập/Đăng xuất
- ✅ Quên mật khẩu
- ✅ Trang chủ cá nhân
- 🔄 Mua sắm sản phẩm (Coming soon)
- 🔄 Quản lý đơn hàng (Coming soon)
- 🔄 Giỏ hàng (Coming soon)

### Seller (Nhân viên bán hàng)
- ✅ Dashboard riêng
- 🔄 Quản lý đơn hàng được giao
- 🔄 Xem sản phẩm
- 🔄 Báo cáo cá nhân

### Seller Manager (Quản lý bán hàng)
- ✅ Dashboard quản lý
- 🔄 Quản lý đội ngũ Seller
- 🔄 Xem tất cả đơn hàng
- 🔄 Báo cáo tổng hợp
- 🔄 Đánh giá hiệu suất

### Admin (Quản trị viên)
- ✅ Dashboard AdminLTE chuyên nghiệp
- 🔄 Quản lý toàn bộ hệ thống
- 🔄 Quản lý user & nhân viên
- 🔄 Quản lý sản phẩm
- 🔄 Báo cáo & thống kê

## 🛠️ Công Nghệ

### Backend
- **Java Servlet** - Server-side logic
- **JSP** - Dynamic web pages
- **JDBC** - Database connectivity
- **SQL Server** - Database

### Frontend
- **HTML5/CSS3** - Structure & styling
- **Bootstrap 4** - Responsive framework
- **JavaScript/jQuery** - Client-side interactivity
- **AdminLTE 3.2.0** - Admin dashboard template

### Security
- **SHA-256** - Password hashing
- **Session-based** - Authentication
- **Role-based** - Authorization
- **Filter** - Route protection

## 📋 Yêu Cầu Hệ Thống

- **JDK**: 8 hoặc cao hơn
- **Server**: Apache Tomcat 9+ hoặc GlassFish
- **Database**: SQL Server 2016+
- **IDE**: NetBeans 12+ (recommended)

## 🔧 Cài Đặt

### 1. Clone Repository
```bash
git clone https://github.com/your-username/pickleball-shop.git
cd pickleball-shop
```

### 2. Cấu Hình Database

#### Tạo Database
```sql
-- Chạy script tạo database
-- File: database_script.sql (nếu có)
```

#### Cập nhật Connection String
Mở file `src/java/DAO/DBContext.java`:
```java
private static final String URL = "jdbc:sqlserver://localhost:1433;databaseName=PickleballShop1";
private static final String USER = "sa";
private static final String PASSWORD = "your_password"; // Đổi password của bạn
```

#### Tạo Tài Khoản Test
```sql
-- Chạy script tạo tài khoản
-- File: database_update_employees.sql
```

### 3. Thêm Thư Viện

Đảm bảo các file JAR sau có trong folder `lib/`:
- `sqljdbc42.jar` - SQL Server JDBC Driver
- `jakarta.servlet.jsp.jstl-2.0.0.jar` - JSTL
- `jakarta.servlet.jsp.jstl-api-2.0.0.jar` - JSTL API

### 4. Build & Deploy

#### Với NetBeans:
1. Mở project trong NetBeans
2. Clean and Build (Shift + F11)
3. Run (F6)

#### Với Command Line:
```bash
ant clean build
# Deploy file WAR vào Tomcat
```

## 🔐 Tài Khoản Test

### Customer
```
Email: customer1@gmail.com
Password: 123456
```

### Admin
```
Email: admin@pickleball.vn
Password: 123456
```

### Seller
```
Email: seller@pickleball.vn
Password: 123456
```

### Seller Manager
```
Email: sellermanager@pickleball.vn
Password: 123456
```

## 📁 Cấu Trúc Project

```
pickleball-shop/
├── src/java/
│   ├── entity/          # Entity classes
│   ├── DAO/             # Data Access Objects
│   ├── controller/      # Servlets
│   ├── filter/          # Security filters
│   └── utils/           # Utility classes
├── web/
│   ├── customer/        # Customer pages
│   ├── seller/          # Seller pages
│   ├── seller-manager/  # Manager pages
│   ├── AdminLTE-3.2.0/  # Admin dashboard
│   ├── css/             # Stylesheets
│   ├── js/              # JavaScript files
│   ├── img/             # Images
│   └── *.jsp            # Public pages
├── lib/                 # JAR libraries
├── build.xml            # Ant build file
└── README.md            # This file
```

## 🎯 Luồng Hoạt Động

### Đăng Nhập
```
User → login.jsp → LoginServlet → Check credentials
                                   ↓
                            Save to session
                                   ↓
                          Redirect by role:
                          - Customer → /customer/home
                          - Seller → /seller/dashboard
                          - Manager → /seller-manager/dashboard
                          - Admin → /AdminLTE-3.2.0/index.jsp
```

### Phân Quyền
```
Request → RoleAuthorizationFilter → Check session & role
                                    ↓
                            Allow or Deny access
                                    ↓
                            access-denied.jsp (if denied)
```

## 📚 Documentation

- [AUTH_README.md](AUTH_README.md) - Hướng dẫn Authentication
- [AUTHORIZATION_README.md](AUTHORIZATION_README.md) - Hướng dẫn Authorization
- [GIT_COMMIT_GUIDE.md](GIT_COMMIT_GUIDE.md) - Hướng dẫn Git

## 🐛 Troubleshooting

### Lỗi kết nối database
```
Kiểm tra:
1. SQL Server đang chạy
2. TCP/IP enabled trong SQL Server Configuration Manager
3. Username/password đúng trong DBContext.java
```

### Lỗi không đăng nhập được
```
Kiểm tra:
1. Đã chạy script tạo tài khoản test
2. Password đã được hash đúng
3. Role trong database khớp với code (Admin, Seller, SellerManager)
```

### Lỗi 404 sau khi đăng nhập
```
Kiểm tra:
1. File JSP tồn tại
2. URL mapping trong servlet đúng
3. Filter không chặn nhầm
```

## 🤝 Contributing

1. Fork repository
2. Tạo branch mới (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

## 📝 License

This project is licensed under the MIT License.

## 👥 Team

- **Developer**: Your Name
- **Project**: SWP391 - E-commerce Platform
- **Year**: 2025

## 📞 Contact

- Email: your-email@example.com
- GitHub: [@your-username](https://github.com/your-username)

## 🙏 Acknowledgments

- AdminLTE - Admin dashboard template
- Bootstrap - CSS framework
- Font Awesome - Icons
- jQuery - JavaScript library

---

**Note**: Đây là project học tập. Không sử dụng cho mục đích thương mại mà không có sự cho phép.
