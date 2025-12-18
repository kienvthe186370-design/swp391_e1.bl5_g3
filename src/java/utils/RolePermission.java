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
        // Seller không được xem danh sách khách hàng, chỉ SellerManager mới có quyền
        return SELLER_MANAGER.equalsIgnoreCase(role);
    }

    public static boolean canManageOrders(String role) {
        return ADMIN.equalsIgnoreCase(role) || SELLER_MANAGER.equalsIgnoreCase(role) || SELLER.equalsIgnoreCase(role);
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
     * Quyền quản lý RFQ (chỉ SellerManager)
     */
    public static boolean canManageRFQ(String role) {
        return SELLER_MANAGER.equalsIgnoreCase(role);
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

    /**
     * Kiểm tra quyền truy cập (backward compatible)
     */
    public static boolean hasPermission(String role, String path) {
        return hasPermission(role, path, null);
    }
    
    /**
     * Kiểm tra quyền truy cập với action parameter
     * @param role Role của user
     * @param path Path sau /admin (VD: /orders, /products)
     * @param action Action từ query string (VD: assignment, shipperOrders)
     */
    public static boolean hasPermission(String role, String path, String action) {
        if (role == null || path == null) {
            return false;
        }

        // Dashboard - tất cả role đều được vào
        if (path.equals("/dashboard") || path.isEmpty() || path.equals("/")) {
            return canViewDashboard(role);
        }

        // ==================== ADMIN PERMISSIONS ====================
        // Admin chỉ quản lý: employees, products, stock, categories, brands, attributes
        if (ADMIN.equalsIgnoreCase(role)) {
            if (path.startsWith("/employees")) return true;
            if (path.startsWith("/products")) return true;
            if (path.startsWith("/stock")) return true;
            if (path.startsWith("/categories")) return true;
            if (path.startsWith("/brands")) return true;
            if (path.startsWith("/attributes")) return true;
            // Admin KHÔNG được truy cập các phần khác
            return false;
        }

        // ==================== SELLER MANAGER PERMISSIONS ====================
        if (SELLER_MANAGER.equalsIgnoreCase(role)) {
            // Khách hàng
            if (path.startsWith("/customers")) return true;
            
            // Đơn hàng - tất cả actions
            if (path.startsWith("/orders")) return true;
            
            // Hoàn tiền
            if (path.startsWith("/refund")) return true;
            
            // RFQ và Quotations
            if (path.startsWith("/rfq")) return true;
            if (path.startsWith("/quotations")) return true;
            
            // Báo cáo
            if (path.startsWith("/reports")) return true;
            
            return false;
        }

        // ==================== SELLER PERMISSIONS ====================
        if (SELLER.equalsIgnoreCase(role)) {
            // Đơn hàng - chỉ list và detail, KHÔNG được assignment
            if (path.startsWith("/orders")) {
                if (action == null || action.isEmpty()) return true;
                if ("list".equals(action)) return true;
                if ("detail".equals(action)) return true;
                // Không cho phép: assignment, shipperAssignment, shipperOrders
                return false;
            }
            
            // Hoàn tiền
            if (path.startsWith("/refund")) return true;
            
            return false;
        }

        // ==================== MARKETER PERMISSIONS ====================
        if (MARKETER.equalsIgnoreCase(role)) {
            // Sản phẩm
            if (path.startsWith("/products")) return true;
            
            // Danh mục
            if (path.startsWith("/categories")) return true;
            if (path.startsWith("/brands")) return true;
            if (path.startsWith("/attributes")) return true;
            
            // Marketing
            if (path.startsWith("/slider")) return true;
            if (path.startsWith("/blog")) return true;
            if (path.startsWith("/discount")) return true;
            
            // Voucher
            if (path.startsWith("/voucher")) return true;
            
            // Feedbacks - check riêng trong servlet vì path khác
            
            return false;
        }

        // ==================== SHIPPER PERMISSIONS ====================
        if (SHIPPER.equalsIgnoreCase(role)) {
            // Đơn hàng - chỉ shipperOrders và shipperDetail
            if (path.startsWith("/orders")) {
                if (action == null || action.isEmpty()) return true; // Default sẽ redirect trong servlet
                if ("shipperOrders".equals(action)) return true;
                if ("shipperDetail".equals(action)) return true;
                // Không cho phép các action khác
                return false;
            }
            return false;
        }

        // ==================== STAFF và các role khác ====================
        // Mặc định không có quyền gì
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
