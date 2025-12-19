package utils;

public class RolePermission {

    public static final String ADMIN = "Admin";
    public static final String SELLER_MANAGER = "SellerManager";
    public static final String SELLER = "Seller";
    public static final String MARKETER = "Marketer";
    public static final String STAFF = "Staff";
    public static final String SHIPPER = "Shipper";

    public static boolean canManageEmployees(String role) {
        return ADMIN.equalsIgnoreCase(role);
    }

    public static boolean canManageSettings(String role) {
        return ADMIN.equalsIgnoreCase(role);
    }

    public static boolean canManageCustomers(String role) {
        return SELLER_MANAGER.equalsIgnoreCase(role);
    }

    public static boolean canViewCustomers(String role) {
        return SELLER_MANAGER.equalsIgnoreCase(role) || SELLER.equalsIgnoreCase(role);
    }

    public static boolean canManageOrders(String role) {
        return SELLER_MANAGER.equalsIgnoreCase(role) || SELLER.equalsIgnoreCase(role);
    }

    /**
     * Quyền quản lý hoàn tiền
     * - SellerManager: Giám sát tất cả, xác nhận hoàn tiền
     * - Seller: Xử lý yêu cầu hoàn tiền của đơn hàng được assign
     */
    public static boolean canManageRefunds(String role) {
        return SELLER_MANAGER.equalsIgnoreCase(role) || SELLER.equalsIgnoreCase(role);
    }

    /**
     * Quyền quản lý RFQ (Seller và SellerManager)
     * - Seller: Xử lý RFQ được assign cho mình
     * - SellerManager: Giám sát tất cả (nhưng không xử lý trực tiếp theo yêu cầu mới)
     */
    public static boolean canManageRFQ(String role) {
        return SELLER.equalsIgnoreCase(role) || SELLER_MANAGER.equalsIgnoreCase(role);
    }
    
    /**
     * Quyền xử lý RFQ trực tiếp (chỉ Seller)
     */
    public static boolean canProcessRFQ(String role) {
        return SELLER.equalsIgnoreCase(role);
    }
    
    /**
     * Kiểm tra có phải Seller không
     */
    public static boolean isSeller(String role) {
        return SELLER.equalsIgnoreCase(role);
    }

    public static boolean canViewSalesReports(String role) {
        return SELLER_MANAGER.equalsIgnoreCase(role);
    }
    
    // ==================== ORDER MANAGEMENT PERMISSIONS ====================
    
    /**
     * Quyền phân công đơn hàng (SellerManager và Admin)
     */
    public static boolean canAssignOrders(String role) {
        return SELLER_MANAGER.equalsIgnoreCase(role) || ADMIN.equalsIgnoreCase(role);
    }
    
    /**
     * Quyền xem tất cả đơn hàng (SellerManager và Admin xem tất cả, Seller chỉ xem đơn được phân)
     */
    public static boolean canViewAllOrders(String role) {
        return SELLER_MANAGER.equalsIgnoreCase(role) || ADMIN.equalsIgnoreCase(role);
    }
    
    /**
     * Quyền cập nhật trạng thái đơn hàng
     */
    public static boolean canUpdateOrderStatus(String role) {
        return SELLER_MANAGER.equalsIgnoreCase(role) || SELLER.equalsIgnoreCase(role) || ADMIN.equalsIgnoreCase(role);
    }
    
    // ==================== SHIPPER PERMISSIONS ====================
    
    /**
     * Kiểm tra có phải Shipper không
     */
    public static boolean isShipper(String role) {
        return SHIPPER.equalsIgnoreCase(role);
    }
    
    /**
     * Quyền xem đơn hàng của shipper (chỉ đơn được phân công)
     */
    public static boolean canViewShipperOrders(String role) {
        return SHIPPER.equalsIgnoreCase(role);
    }
    
    /**
     * Quyền cập nhật trạng thái vận chuyển
     */
    public static boolean canUpdateShippingStatus(String role) {
        return SHIPPER.equalsIgnoreCase(role);
    }
    
    /**
     * Quyền phân công shipper cho đơn hàng
     */
    public static boolean canAssignShipper(String role) {
        return SELLER_MANAGER.equalsIgnoreCase(role) || ADMIN.equalsIgnoreCase(role);
    }
    
    // ==================== STOCK REQUEST PERMISSIONS ====================
    
    /**
     * Quyền quản lý yêu cầu nhập kho
     * - Seller: Tạo yêu cầu từ RFQ, xem yêu cầu của mình
     * - Admin: Xem tất cả, approve yêu cầu
     */
    public static boolean canManageStockRequests(String role) {
        return SELLER.equalsIgnoreCase(role) || ADMIN.equalsIgnoreCase(role);
    }
    
    /**
     * Quyền tạo yêu cầu nhập kho (chỉ Seller)
     */
    public static boolean canCreateStockRequest(String role) {
        return SELLER.equalsIgnoreCase(role);
    }
    
    /**
     * Quyền approve yêu cầu nhập kho (chỉ Admin)
     */
    public static boolean canApproveStockRequest(String role) {
        return ADMIN.equalsIgnoreCase(role);
    }

    public static boolean canManageProducts(String role) {
        return MARKETER.equalsIgnoreCase(role);
    }

    public static boolean canManageCatalog(String role) {
        return MARKETER.equalsIgnoreCase(role);
    }

    public static boolean canManageMarketing(String role) {
        return MARKETER.equalsIgnoreCase(role);
    }

    public static boolean canManageVouchers(String role) {
        return MARKETER.equalsIgnoreCase(role);
    }

    public static boolean canViewDashboard(String role) {
        return role != null && !role.trim().isEmpty();
    }

    public static boolean hasPermission(String role, String path) {
        if (role == null || path == null) {
            return false;
        }

        // RFQ: Seller xử lý, SellerManager giám sát
        if (path.startsWith("/rfq")) {
            return canManageRFQ(role);
        }
        
        // Quotations (Đơn Báo Giá): Seller xử lý, SellerManager giám sát
        if (path.startsWith("/quotations")) {
            return canManageRFQ(role);
        }

        // Admin: full quyền cho các phần còn lại
        if (ADMIN.equalsIgnoreCase(role)) {
            return true;
        }

        if (path.equals("/dashboard") || path.isEmpty() || path.equals("/")) {
            return canViewDashboard(role);
        }

        if (path.startsWith("/employees")) {
            return false;
        }

        if (path.startsWith("/customers")) {
            return canViewCustomers(role);
        }

        if (path.startsWith("/orders")) {
            // Shipper có thể xem đơn hàng của mình
            return canManageOrders(role) || isShipper(role);
        }

        // Refund: SellerManager giám sát, Seller xử lý đơn của mình
        if (path.startsWith("/refund")) {
            return canManageRefunds(role);
        }
        
        // Stock Requests: Seller tạo yêu cầu, Admin duyệt
        if (path.startsWith("/stock-requests")) {
            return canManageStockRequests(role);
        }

        if (path.startsWith("/products")) {
            return canManageProducts(role);
        }

        if (path.startsWith("/categories") || path.startsWith("/brands") || path.startsWith("/attributes")) {
            return canManageCatalog(role);
        }

        if (path.startsWith("/slider") || path.startsWith("/banner") || path.startsWith("/blog") || path.startsWith("/discount")) {
            return canManageMarketing(role);
        }

        if (path.startsWith("/voucher")) {
            return canManageVouchers(role);
        }

        if (path.startsWith("/reports")) {
            return canViewSalesReports(role);
        }

        if (path.startsWith("/settings")) {
            return false;
        }
        return false;
    }

    public static String getDefaultPage(String role) {
        return "/admin/dashboard";
    }

    public static String getRoleDisplayName(String role) {
        if (role == null) {
            return "Unknown";
        }
        switch (role.toLowerCase()) {
            case "admin":
                return "Quản trị viên";
            case "sellermanager":
                return "Quản lý bán hàng";
            case "seller":
                return "Nhân viên bán hàng";
            case "marketer":
                return "Nhân viên marketing";
            case "staff":
                return "Nhân viên";
            case "shipper":
                return "Nhân viên giao hàng";
            default:
                return role;
        }
    }
}
