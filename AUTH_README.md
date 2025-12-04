# Hệ Thống Đăng Nhập/Đăng Ký - Pickleball Shop

## Các Chức Năng Đã Hoàn Thành

### 1. Đăng Nhập (Login)
- URL: `/login`
- Xác thực email và mật khẩu
- Lưu thông tin user vào session
- Cập nhật thời gian đăng nhập cuối

### 2. Đăng Ký (Register)
- URL: `/register`
- Kiểm tra email đã tồn tại
- Validate mật khẩu (tối thiểu 6 ký tự)
- Mã hóa mật khẩu bằng SHA-256
- Tự động tạo tài khoản trong database

### 3. Quên Mật Khẩu (Forgot Password)
- URL: `/forgot-password`
- Gửi mã xác nhận qua email
- Mã có hiệu lực 30 phút
- Đặt lại mật khẩu mới

### 4. Đăng Xuất (Logout)
- URL: `/logout`
- Xóa session và chuyển về trang login

## Cấu Trúc File

```
src/java/
├── entity/
│   └── Customer.java              # Entity cho bảng Customers
├── DAO/
│   ├── DBContext.java             # Kết nối database (đã có)
│   └── CustomerDAO.java           # DAO xử lý logic database
├── utils/
│   ├── PasswordUtil.java          # Mã hóa và xác thực mật khẩu
│   └── EmailUtil.java             # Gửi email (cần cấu hình)
├── controller/
│   ├── LoginServlet.java          # Xử lý đăng nhập
│   ├── RegisterServlet.java       # Xử lý đăng ký
│   ├── ForgotPasswordServlet.java # Xử lý quên mật khẩu
│   ├── ResetPasswordServlet.java  # Xử lý đặt lại mật khẩu
│   └── LogoutServlet.java         # Xử lý đăng xuất
└── filter/
    └── AuthenticationFilter.java  # Filter bảo vệ các trang cần login

web/
├── login.jsp                      # Giao diện đăng nhập
├── register.jsp                   # Giao diện đăng ký
└── forgot-password.jsp            # Giao diện quên mật khẩu
```

## Cách Sử Dụng

### 1. Kiểm Tra Kết Nối Database
Database đã được cấu hình trong `DBContext.java`:
- Server: localhost:1433
- Database: PickleballShop1
- User: sa
- Password: 123

### 2. Thêm Thư Viện Email (Tùy chọn)
Để sử dụng chức năng gửi email, thêm vào `pom.xml` nếu dùng Maven:
```xml
<dependency>
    <groupId>com.sun.mail</groupId>
    <artifactId>jakarta.mail</artifactId>
    <version>2.0.1</version>
</dependency>
<dependency>
    <groupId>jakarta.activation</groupId>
    <artifactId>jakarta.activation-api</artifactId>
    <version>2.1.0</version>
</dependency>
```

Hoặc download JAR files và thêm vào `lib/`:
- jakarta.mail-2.0.1.jar
- jakarta.activation-api-2.1.0.jar

### 3. Cấu Hình Email (Tùy chọn)
Mở file `src/java/utils/EmailUtil.java` và cập nhật:
```java
private static final String FROM_EMAIL = "your-email@gmail.com";
private static final String PASSWORD = "your-app-password";
```

**Lưu ý:** Với Gmail, bạn cần tạo App Password:
1. Vào Google Account Settings
2. Security → 2-Step Verification
3. App passwords → Tạo mật khẩu ứng dụng

### 4. Test Các Chức Năng

#### Đăng Ký Tài Khoản Mới:
1. Truy cập: `http://localhost:8080/your-app/register`
2. Điền thông tin đầy đủ
3. Nhấn "Đăng Ký"

#### Đăng Nhập:
1. Truy cập: `http://localhost:8080/your-app/login`
2. Nhập email và mật khẩu
3. Nhấn "Đăng Nhập"

#### Quên Mật Khẩu:
1. Truy cập: `http://localhost:8080/your-app/forgot-password`
2. Nhập email đã đăng ký
3. Nhập mã xác nhận (kiểm tra trong database nếu chưa cấu hình email)
4. Đặt mật khẩu mới

### 5. Kiểm Tra Mã Token (Quan Trọng!)

**Hiện tại chức năng gửi email đã được TẮT** để tránh lỗi thiếu thư viện.

Có 3 cách để lấy mã token reset password:

#### Cách 1: Xem trên màn hình (Đơn giản nhất)
Sau khi nhập email, mã token sẽ hiển thị ngay trên màn hình thông báo.

#### Cách 2: Xem trong Console/Log
Mã token sẽ được in ra console của NetBeans khi bạn yêu cầu reset password.

#### Cách 3: Truy vấn Database
```sql
SELECT VerificationToken, TokenExpiry 
FROM Customers 
WHERE Email = 'your-email@example.com'
```

**Để BẬT chức năng gửi email thật:**
1. Thêm thư viện Jakarta Mail vào project
2. Mở file `src/java/utils/EmailUtil.java`
3. Uncomment code gửi email
4. Cấu hình email và app password

## Session Attributes

Sau khi đăng nhập thành công, các thông tin sau được lưu trong session:
- `customer`: Object Customer đầy đủ
- `customerID`: ID của khách hàng
- `customerName`: Tên đầy đủ của khách hàng

## Bảo Mật

### Đã Implement:
- Mã hóa mật khẩu bằng SHA-256
- Token ngẫu nhiên cho reset password
- Token có thời gian hết hạn (30 phút)
- Kiểm tra email đã tồn tại
- Validate độ dài mật khẩu
- Filter bảo vệ các trang cần đăng nhập

### Nên Cải Thiện:
- Sử dụng BCrypt thay vì SHA-256
- Thêm CAPTCHA cho form đăng ký/đăng nhập
- Rate limiting cho các request
- HTTPS cho production
- Thêm salt cho mật khẩu

## Tích Hợp Vào Trang Web

### Thêm Link Đăng Nhập/Đăng Ký vào Header:
```html
<div class="header__top__right__auth">
    <% if (session.getAttribute("customer") != null) { %>
        <a href="#"><i class="fa fa-user"></i> <%= session.getAttribute("customerName") %></a>
        <a href="logout"><i class="fa fa-sign-out"></i> Đăng xuất</a>
    <% } else { %>
        <a href="login"><i class="fa fa-user"></i> Đăng nhập</a>
        <a href="register"><i class="fa fa-user-plus"></i> Đăng ký</a>
    <% } %>
</div>
```

## Troubleshooting

### Lỗi kết nối database:
- Kiểm tra SQL Server đang chạy
- Kiểm tra TCP/IP enabled trong SQL Server Configuration Manager
- Kiểm tra username/password trong DBContext.java

### Không gửi được email:
- Kiểm tra cấu hình email trong EmailUtil.java
- Kiểm tra App Password của Gmail
- Tạm thời comment dòng gửi email và lấy token từ database

### Session không lưu:
- Kiểm tra cookie settings trong browser
- Kiểm tra session timeout trong web.xml

## Test Accounts

Bạn có thể tạo test account bằng cách:
1. Đăng ký qua form register
2. Hoặc insert trực tiếp vào database:

```sql
INSERT INTO Customers (FullName, Email, PasswordHash, Phone, IsEmailVerified, IsActive, CreatedDate)
VALUES (
    N'Test User',
    'test@example.com',
    'jGl25bVBBBW96Qi9Te4V37Fnqchz/Eu4qB9vKrRIqRg=', -- password: 123456
    '0123456789',
    1,
    1,
    GETDATE()
)
```

## Liên Hệ & Hỗ Trợ

Nếu có vấn đề, kiểm tra:
1. Console log trong NetBeans
2. Browser console (F12)
3. Database logs
4. Server logs (Tomcat/GlassFish)
