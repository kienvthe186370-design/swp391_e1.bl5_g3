# Hệ Thống Phân Quyền - Pickleball Shop

## Tổng Quan

Hệ thống phân quyền đa cấp với 4 loại tài khoản chính:
1. **Customer** - Khách hàng mua sắm
2. **Seller** - Nhân viên bán hàng
3. **Seller Manager** - Quản lý đội ngũ Seller
4. **Admin** - Quản trị viên hệ thống

## Cấu Trúc Phân Quyền

### 1. Customer (Khách hàng)
**Quyền truy cập:**
- `/customer/home` - Trang chủ riêng
- `/customer/shop` - Mua sắm
- `/customer/cart` - Giỏ hàng
- `/customer/orders` - Đơn hàng của mình
- `/customer/profile` - Thông tin cá nhân
- `/customer/wishlist` - Danh sách yêu thích

**Đặc điểm:**
- Mỗi customer chỉ xem được thông tin của chính mình
- Không thể truy cập vào trang của customer khác
- Không thể truy cập vào các trang quản lý

### 2. Seller (Nhân viên bán hàng)
**Quyền truy cập:**
- `/seller/dashboard` - Dashboard riêng
- `/seller/orders` - Quản lý đơn hàng được giao
- `/seller/products` - Xem sản phẩm
- `/seller/customers` - Xem thông tin khách hàng
- `/seller/reports` - Báo cáo cá nhân
- `/seller/profile` - Thông tin cá nhân

**Đặc điểm:**
- Chỉ xem và xử lý đơn hàng được giao cho mình
- Không thể truy cập dữ liệu của Seller khác
- Không có quyền thêm/xóa sản phẩm

### 3. Seller Manager (Quản lý Seller)
**Quyền truy cập:**
- `/seller-manager/dashboard` - Dashboard quản lý
- `/seller-manager/sellers` - Quản lý đội ngũ Seller
- `/seller-manager/orders` - Xem tất cả đơn hàng
- `/seller-manager/products` - Quản lý sản phẩm
- `/seller-manager/reports` - Báo cáo tổng hợp
- `/seller-manager/performance` - Đánh giá hiệu suất

**Đặc điểm:**
- Xem được dữ liệu của tất cả Seller
- Phân công đơn hàng cho Seller
- Đánh giá hiệu suất làm việc
- Không có quyền quản lý Admin

### 4. Admin (Quản trị viên)
**Quyền truy cập:**
- `/AdminLTE-3.2.0/index.jsp` - Dashboard AdminLTE
- `/admin/*` - Tất cả trang admin
- Toàn bộ folder AdminLTE-3.2.0

**Đặc điểm:**
- Sử dụng template AdminLTE 3.2.0 có sẵn
- Toàn quyền truy cập mọi chức năng
- Quản lý tất cả user và nhân viên
- Cấu hình hệ thống
- Dashboard chuyên nghiệp với AdminLTE

## Tài Khoản Test

### Customer Accounts
```
Email: customer1@gmail.com
Password: 123456
Role: Customer

Email: customer2@gmail.com
Password: 123456
Role: Customer

Email: customer3@gmail.com
Password: 123456
Role: Customer
```

### Employee Accounts
```
Email: admin@pickleball.vn
Password: 123456
Role: Admin

Email: seller@pickleball.vn
Password: 123456
Role: Seller

Email: marketing@pickleball.vn
Password: 123456
Role: Marketer

Email: staff@pickleball.vn
Password: 123456
Role: Staff
```

**Lưu ý:** Tất cả password đã được hash bằng SHA-256: `jZae727K08KaOmKSgOaGzww/XVqGr/PKEgIMkjrcbJI=`

## Cách Hoạt Động

### 1. Đăng Nhập
```java
// LoginServlet.java
- Kiểm tra email/password
- Xác định loại tài khoản (Customer hoặc Employee)
- Lưu thông tin vào session
- Redirect đến trang tương ứng với role
```

### 2. Phân Quyền
```java
// RoleAuthorizationFilter.java
- Kiểm tra session có tồn tại không
- Xác định role của user
- So sánh với URL đang truy cập
- Cho phép hoặc từ chối truy cập
```

### 3. Session Attributes
Sau khi đăng nhập thành công:

**Customer:**
```java
session.setAttribute("customer", customerObject);
session.setAttribute("userID", customerID);
session.setAttribute("userName", fullName);
session.setAttribute("userType", "customer");
```

**Employee:**
```java
session.setAttribute("employee", employeeObject);
session.setAttribute("userID", employeeID);
session.setAttribute("userName", fullName);
session.setAttribute("userRole", role);
session.setAttribute("userType", "employee");
```

## Cấu Trúc File

```
src/java/
├── entity/
│   ├── Customer.java
│   └── Employee.java
├── DAO/
│   ├── CustomerDAO.java
│   └── EmployeeDAO.java
├── controller/
│   ├── LoginServlet.java
│   ├── LogoutServlet.java
│   ├── CustomerHomeServlet.java
│   ├── SellerDashboardServlet.java
│   ├── SellerManagerDashboardServlet.java
│   └── AdminDashboardServlet.java
└── filter/
    ├── AuthenticationFilter.java (cũ - cho các trang chung)
    └── RoleAuthorizationFilter.java (mới - phân quyền theo role)

web/
├── customer/
│   └── home.jsp
├── seller/
│   └── dashboard.jsp
├── seller-manager/
│   └── dashboard.jsp
├── AdminLTE-3.2.0/
│   ├── index.jsp (Admin Dashboard - có session check)
│   ├── adminindex.html (Original AdminLTE)
│   └── ... (các file AdminLTE khác)
├── login.jsp
├── register.jsp
└── access-denied.jsp
```

## Luồng Xử Lý

### Khi User Đăng Nhập:
1. User nhập email/password vào `login.jsp`
2. `LoginServlet` xử lý:
   - Thử đăng nhập Customer trước
   - Nếu không phải Customer, thử Employee
   - Lưu thông tin vào session
   - Redirect theo role:
     - Customer → `/customer/home`
     - Seller → `/seller/dashboard`
     - SellerManager → `/seller-manager/dashboard`
     - Admin → `/AdminLTE-3.2.0/index.jsp` (AdminLTE Dashboard)

### Khi User Truy Cập Trang:
1. `RoleAuthorizationFilter` chặn request
2. Kiểm tra session có tồn tại không
3. Kiểm tra role có phù hợp với URL không
4. Nếu OK: cho phép truy cập
5. Nếu không: redirect đến `access-denied.jsp`

## Bảo Mật

### Đã Implement:
✅ Session-based authentication
✅ Role-based authorization
✅ Password hashing (SHA-256)
✅ Filter bảo vệ các route
✅ Kiểm tra quyền truy cập mỗi request
✅ Tách biệt dữ liệu giữa các role
✅ Access denied page

### Nên Cải Thiện:
⚠️ Sử dụng BCrypt thay vì SHA-256
⚠️ Thêm CSRF token
⚠️ Session timeout
⚠️ Remember me functionality
⚠️ Two-factor authentication
⚠️ Rate limiting
⚠️ Audit logging

## Test Phân Quyền

### Test 1: Customer không thể truy cập Seller
```
1. Đăng nhập: customer1@gmail.com / 123456
2. Thử truy cập: /seller/dashboard
3. Kết quả: Redirect đến access-denied.jsp
```

### Test 2: Seller không thể truy cập Admin
```
1. Đăng nhập: seller@pickleball.vn / 123456
2. Thử truy cập: /admin/dashboard
3. Kết quả: Redirect đến access-denied.jsp
```

### Test 3: Admin có thể truy cập AdminLTE
```
1. Đăng nhập: admin@pickleball.vn / 123456
2. Truy cập: /AdminLTE-3.2.0/index.jsp
3. Kết quả: Thành công - Hiển thị AdminLTE Dashboard
4. Thông tin admin hiển thị trên navbar và sidebar
```

### Test 4: Mỗi Customer chỉ xem được dữ liệu của mình
```
1. Đăng nhập: customer1@gmail.com / 123456
2. Xem: /customer/orders
3. Kết quả: Chỉ thấy đơn hàng của customer1
```

## Thêm Role Mới

Để thêm role mới (ví dụ: Marketer):

### 1. Cập nhật Database
```sql
INSERT INTO Employees (FullName, Email, PasswordHash, Role, IsActive, CreatedDate)
VALUES (N'Marketer User', 'marketer@pickleball.vn', 'hash_password', 'Marketer', 1, GETDATE());
```

### 2. Thêm vào LoginServlet
```java
case "marketer":
    return "marketer/dashboard";
```

### 3. Thêm vào RoleAuthorizationFilter
```java
else if (path.startsWith("/marketer/")) {
    Employee employee = (Employee) session.getAttribute("employee");
    hasAccess = (employee != null && "Marketer".equalsIgnoreCase(employee.getRole()));
}
```

### 4. Tạo Controller
```java
@WebServlet(name = "MarketerDashboardServlet", urlPatterns = {"/marketer/dashboard"})
public class MarketerDashboardServlet extends HttpServlet { ... }
```

### 5. Tạo JSP
```
web/marketer/dashboard.jsp
```

## Troubleshooting

### Lỗi: Không redirect đúng trang sau login
**Nguyên nhân:** Role trong database không khớp với code
**Giải pháp:** Kiểm tra role trong database (Admin, Seller, SellerManager - phân biệt hoa thường)

### Lỗi: Access denied khi đã đăng nhập đúng
**Nguyên nhân:** Filter không nhận diện đúng role
**Giải pháp:** Kiểm tra session attributes và logic trong RoleAuthorizationFilter

### Lỗi: Session bị mất sau khi refresh
**Nguyên nhân:** Session timeout hoặc cookie settings
**Giải pháp:** Cấu hình session timeout trong web.xml

## Liên Hệ & Hỗ Trợ

Nếu có vấn đề về phân quyền:
1. Kiểm tra console log
2. Kiểm tra session attributes
3. Kiểm tra role trong database
4. Kiểm tra URL pattern trong filter
