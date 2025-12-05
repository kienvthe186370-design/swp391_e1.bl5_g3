-- Script để thêm/update tài khoản Employee
-- Password: 123456 (SHA-256 hash)
USE [PickleballShop1]
GO

DECLARE @TestPassword NVARCHAR(255) = 'jZae727K08KaOmKSgOaGzww/XVqGr/PKEgIMkjrcbJI=';

-- Kiểm tra và update Admin
IF EXISTS (SELECT 1 FROM Employees WHERE Email = 'admin@pickleball.vn')
BEGIN
    UPDATE Employees 
    SET PasswordHash = @TestPassword, 
        Role = 'Admin',
        IsActive = 1
    WHERE Email = 'admin@pickleball.vn';
    PRINT 'Updated Admin account';
END
ELSE
BEGIN
    INSERT INTO Employees (FullName, Email, PasswordHash, Phone, Role, IsActive, CreatedDate)
    VALUES (N'Admin User', 'admin@pickleball.vn', @TestPassword, '0901234567', 'Admin', 1, GETDATE());
    PRINT 'Created Admin account';
END

-- Kiểm tra và update/create Seller
IF EXISTS (SELECT 1 FROM Employees WHERE Email = 'seller@pickleball.vn')
BEGIN
    UPDATE Employees 
    SET PasswordHash = @TestPassword, 
        Role = 'Seller',
        IsActive = 1
    WHERE Email = 'seller@pickleball.vn';
    PRINT 'Updated Seller account';
END
ELSE
BEGIN
    INSERT INTO Employees (FullName, Email, PasswordHash, Phone, Role, IsActive, CreatedDate)
    VALUES (N'Seller User', 'seller@pickleball.vn', @TestPassword, '0902345678', 'Seller', 1, GETDATE());
    PRINT 'Created Seller account';
END

-- Kiểm tra và update/create SellerManager
IF EXISTS (SELECT 1 FROM Employees WHERE Email = 'sellermanager@pickleball.vn')
BEGIN
    UPDATE Employees 
    SET PasswordHash = @TestPassword, 
        Role = 'SellerManager',
        IsActive = 1
    WHERE Email = 'sellermanager@pickleball.vn';
    PRINT 'Updated SellerManager account';
END
ELSE
BEGIN
    INSERT INTO Employees (FullName, Email, PasswordHash, Phone, Role, IsActive, CreatedDate)
    VALUES (N'Seller Manager', 'sellermanager@pickleball.vn', @TestPassword, '0903456789', 'SellerManager', 1, GETDATE());
    PRINT 'Created SellerManager account';
END

-- Kiểm tra và update Marketer
IF EXISTS (SELECT 1 FROM Employees WHERE Email = 'marketing@pickleball.vn')
BEGIN
    UPDATE Employees 
    SET PasswordHash = @TestPassword, 
        Role = 'Marketer',
        IsActive = 1
    WHERE Email = 'marketing@pickleball.vn';
    PRINT 'Updated Marketer account';
END
ELSE
BEGIN
    INSERT INTO Employees (FullName, Email, PasswordHash, Phone, Role, IsActive, CreatedDate)
    VALUES (N'Marketing User', 'marketing@pickleball.vn', @TestPassword, '0904567890', 'Marketer', 1, GETDATE());
    PRINT 'Created Marketer account';
END

-- Kiểm tra và update Staff
IF EXISTS (SELECT 1 FROM Employees WHERE Email = 'staff@pickleball.vn')
BEGIN
    UPDATE Employees 
    SET PasswordHash = @TestPassword, 
        Role = 'Staff',
        IsActive = 1
    WHERE Email = 'staff@pickleball.vn';
    PRINT 'Updated Staff account';
END
ELSE
BEGIN
    INSERT INTO Employees (FullName, Email, PasswordHash, Phone, Role, IsActive, CreatedDate)
    VALUES (N'Staff User', 'staff@pickleball.vn', @TestPassword, '0905678901', 'Staff', 1, GETDATE());
    PRINT 'Created Staff account';
END

GO

-- Verify all accounts
PRINT ''
PRINT '========================================='
PRINT 'DANH SÁCH TÀI KHOẢN EMPLOYEE'
PRINT '========================================='
SELECT 
    EmployeeID,
    FullName,
    Email,
    Role,
    CASE WHEN PasswordHash = 'jZae727K08KaOmKSgOaGzww/XVqGr/PKEgIMkjrcbJI=' 
         THEN 'Password: 123456 ✓' 
         ELSE 'Password khác ✗' 
    END as PasswordStatus,
    CASE WHEN IsActive = 1 THEN 'Active ✓' ELSE 'Inactive ✗' END as Status
FROM Employees
WHERE Email IN (
    'admin@pickleball.vn',
    'seller@pickleball.vn', 
    'sellermanager@pickleball.vn',
    'marketing@pickleball.vn',
    'staff@pickleball.vn'
)
ORDER BY Role;

PRINT ''
PRINT '========================================='
PRINT 'TÀI KHOẢN TEST'
PRINT '========================================='
PRINT 'Admin:          admin@pickleball.vn / 123456'
PRINT 'Seller:         seller@pickleball.vn / 123456'
PRINT 'Seller Manager: sellermanager@pickleball.vn / 123456'
PRINT 'Marketer:       marketing@pickleball.vn / 123456'
PRINT 'Staff:          staff@pickleball.vn / 123456'
PRINT '========================================='
GO
