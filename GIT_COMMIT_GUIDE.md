# Hướng Dẫn Commit Lên GitHub

## Files Cần Commit Cho Hệ Thống Login & Authorization

### 📁 Backend - Java Source Files

#### Entity Classes
```
src/java/entity/Customer.java
src/java/entity/Employee.java
```

#### DAO Classes
```
src/java/DAO/DBContext.java
src/java/DAO/CustomerDAO.java
src/java/DAO/EmployeeDAO.java
```

#### Controllers
```
src/java/controller/LoginServlet.java
src/java/controller/LogoutServlet.java
src/java/controller/RegisterServlet.java
src/java/controller/ForgotPasswordServlet.java
src/java/controller/ResetPasswordServlet.java
src/java/controller/CustomerHomeServlet.java
src/java/controller/SellerDashboardServlet.java
src/java/controller/SellerManagerDashboardServlet.java
src/java/controller/AdminDashboardServlet.java
```

#### Filters
```
src/java/filter/AuthenticationFilter.java
src/java/filter/RoleAuthorizationFilter.java
```

#### Utils
```
src/java/utils/PasswordUtil.java
src/java/utils/EmailUtil.java
```

### 📁 Frontend - Web Files

#### Login/Register Pages
```
web/login.jsp
web/register.jsp
web/forgot-password.jsp
web/access-denied.jsp
```

#### Customer Pages
```
web/customer/home.jsp
```

#### Seller Pages
```
web/seller/dashboard.jsp
```

#### Seller Manager Pages
```
web/seller-manager/dashboard.jsp
```

#### Admin Pages (AdminLTE)
```
web/AdminLTE-3.2.0/index.jsp
web/AdminLTE-3.2.0/adminindex.html
web/AdminLTE-3.2.0/dist/
web/AdminLTE-3.2.0/plugins/
web/AdminLTE-3.2.0/pages/
(Toàn bộ folder AdminLTE-3.2.0)
```

### 📁 Documentation
```
AUTH_README.md
AUTHORIZATION_README.md
database_update_employees.sql
GIT_COMMIT_GUIDE.md
```

### 📁 Configuration Files
```
build.xml
nbproject/project.properties
nbproject/project.xml
```

## 🚫 Files KHÔNG NÊN Commit

### Build Output
```
build/
dist/
```

### IDE Settings (Tùy chọn)
```
nbproject/private/
.netbeans.xml
```

### Database Credentials
```
Không commit file chứa password database thật
```

## 📝 Git Commands

### 1. Kiểm tra status
```bash
git status
```

### 2. Add files theo nhóm

#### Add Backend
```bash
git add src/java/entity/
git add src/java/DAO/
git add src/java/controller/
git add src/java/filter/
git add src/java/utils/
```

#### Add Frontend
```bash
git add web/login.jsp
git add web/register.jsp
git add web/forgot-password.jsp
git add web/access-denied.jsp
git add web/customer/
git add web/seller/
git add web/seller-manager/
git add web/AdminLTE-3.2.0/
```

#### Add Documentation
```bash
git add *.md
git add *.sql
```

### 3. Hoặc add tất cả (cẩn thận!)
```bash
git add .
```

### 4. Commit
```bash
git commit -m "feat: Add authentication and authorization system

- Implement login/register/forgot password
- Add role-based access control (Customer, Seller, SellerManager, Admin)
- Integrate AdminLTE dashboard for Admin
- Add session management and filters
- Create separate dashboards for each role"
```

### 5. Push lên GitHub
```bash
git push origin main
```
hoặc
```bash
git push origin master
```

## 📋 Checklist Trước Khi Commit

- [ ] Đã test login với tất cả roles
- [ ] Đã chạy script SQL để tạo tài khoản test
- [ ] Đã kiểm tra không commit file build/
- [ ] Đã kiểm tra không commit password thật
- [ ] Đã test redirect đúng cho từng role
- [ ] Đã test filter bảo vệ các route
- [ ] Code đã compile thành công
- [ ] Không có lỗi syntax

## 🔐 Tài Khoản Test (Sau khi chạy SQL script)

```
Customer:
- Email: customer1@gmail.com
- Password: 123456

Admin:
- Email: admin@pickleball.vn
- Password: 123456

Seller:
- Email: seller@pickleball.vn
- Password: 123456

Seller Manager:
- Email: sellermanager@pickleball.vn
- Password: 123456

Marketer:
- Email: marketing@pickleball.vn
- Password: 123456
```

## 📌 Lưu Ý Quan Trọng

### 1. .gitignore
Tạo file `.gitignore` nếu chưa có:
```
# Build folders
build/
dist/
target/

# IDE
nbproject/private/
.idea/
*.iml
.vscode/

# OS
.DS_Store
Thumbs.db

# Logs
*.log

# Database
*.db
*.sqlite
```

### 2. Database Script
File `database_update_employees.sql` nên được commit để team khác có thể tạo tài khoản test.

### 3. AdminLTE
Folder `AdminLTE-3.2.0` khá lớn. Nếu GitHub báo lỗi file quá lớn, có thể:
- Sử dụng Git LFS
- Hoặc chỉ commit file cần thiết
- Hoặc để link download AdminLTE trong README

### 4. Sensitive Data
**KHÔNG BAO GIỜ** commit:
- Database password thật
- API keys
- Secret tokens
- Private keys

## 🎯 Commit Message Convention

### Format
```
<type>: <subject>

<body>

<footer>
```

### Types
- `feat`: Tính năng mới
- `fix`: Sửa bug
- `docs`: Cập nhật documentation
- `style`: Format code
- `refactor`: Refactor code
- `test`: Thêm tests
- `chore`: Maintenance

### Examples
```bash
git commit -m "feat: Add customer authentication system"
git commit -m "fix: Fix seller login redirect issue"
git commit -m "docs: Update authorization README"
```

## 🚀 Quick Start Commands

```bash
# 1. Kiểm tra status
git status

# 2. Add tất cả files mới
git add src/java/
git add web/
git add *.md
git add *.sql

# 3. Commit
git commit -m "feat: Complete authentication and authorization system"

# 4. Push
git push origin main

# 5. Verify trên GitHub
# Mở browser và kiểm tra repository
```

## 📞 Troubleshooting

### Lỗi: File quá lớn
```bash
# Sử dụng Git LFS
git lfs install
git lfs track "*.jar"
git lfs track "web/AdminLTE-3.2.0/dist/**"
git add .gitattributes
```

### Lỗi: Conflict
```bash
# Pull trước khi push
git pull origin main
# Giải quyết conflicts
git add .
git commit -m "merge: Resolve conflicts"
git push origin main
```

### Lỗi: Permission denied
```bash
# Kiểm tra SSH key hoặc dùng HTTPS
git remote set-url origin https://github.com/username/repo.git
```

## ✅ Verification

Sau khi push, kiểm tra trên GitHub:
1. Tất cả files đã được upload
2. Folder structure đúng
3. README hiển thị đẹp
4. Không có file sensitive data
5. Clone về máy khác và test

## 📚 Resources

- [Git Documentation](https://git-scm.com/doc)
- [GitHub Guides](https://guides.github.com/)
- [Conventional Commits](https://www.conventionalcommits.org/)
