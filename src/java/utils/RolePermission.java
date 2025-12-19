package utils;

public class RolePermission {

    // ==================== CONSTANTS ====================
    public static final String ADMIN = "Admin";
    public static final String SELLER_MANAGER = "SellerManager";
    public static final String SELLER = "Seller";
    public static final String MARKETER = "Marketer";
    public static final String STAFF = "Staff";
    public static final String SHIPPER = "Shipper";

    // ==================== SYSTEM MANAGEMENT (ADMIN) ====================

    public static boolean canManageEmployees(String role) {
        return ADMIN.equalsIgnoreCase(role);
    }

    public static boolean canManageSettings(String role) {
        return ADMIN.equalsIgnoreCase(role);
    }

    // ==================== CUSTOMER & ORDERS (SELLER MANAGER / SELLER) ====================

    public static boolean canManageCustomers(String role) {
        return SELLER_MANAGER.equalsIgnoreCase(role);
    }

    public static boolean canViewCustomers(String role) {
        return SELLER_MANAGER.equalsIgnoreCase(role);
    }

    // Admin KHÔNG quản lý đơn hàng
    public static boolean canManageOrders(String role) {
        return SELLER_MANAGER.equalsIgnoreCase(role) || SELLER.equalsIgnoreCase(role);
    }

    public static boolean canManageRefunds(String role) {
        return SELLER_MANAGER.equalsIgnoreCase(role) || SELLER.equalsIgnoreCase(role);
    }

    public static boolean canManageRFQ(String role) {
        return SELLER.equalsIgnoreCase(role) || SELLER_MANAGER.equalsIgnoreCase(role);
    }

    public static boolean canProcessRFQ(String role) {
        return SELLER.equalsIgnoreCase(role);
    }

    public static boolean isSeller(String role) {
        return SELLER.equalsIgnoreCase(role);
    }
    
    
    
    public static boolean canViewSalesReports(String role) {
        return SELLER_MANAGER.equalsIgnoreCase(role);
    }

    // Admin KHÔNG phân công đơn hàng
    public static boolean canAssignOrders(String role) {
        return SELLER_MANAGER.equalsIgnoreCase(role);
    }

    public static boolean canViewAllOrders(String role) {
        return SELLER_MANAGER.equalsIgnoreCase(role);
    }

    public static boolean canUpdateOrderStatus(String role) {
        if (role != null) {
            role = role.trim();
        }
        boolean result = SELLER_MANAGER.equalsIgnoreCase(role) || SELLER.equalsIgnoreCase(role) || ADMIN.equalsIgnoreCase(role);
        System.out.println("[RolePermission] canUpdateOrderStatus - role: '" + role + "', result: " + result);
        return result;
    }

    // ==================== SHIPPER ====================

    public static boolean isShipper(String role) {
        return SHIPPER.equalsIgnoreCase(role);
    }

    public static boolean canViewShipperOrders(String role) {
        return SHIPPER.equalsIgnoreCase(role);
    }

    public static boolean canUpdateShippingStatus(String role) {
        return SHIPPER.equalsIgnoreCase(role);
    }

    public static boolean canAssignShipper(String role) {
        return SELLER_MANAGER.equalsIgnoreCase(role);
    }

    // ==================== STOCK REQUESTS (ADMIN & SELLER) ====================

    // Admin CÓ quyền quản lý yêu cầu nhập hàng
    public static boolean canManageStockRequests(String role) {
        return SELLER.equalsIgnoreCase(role) || ADMIN.equalsIgnoreCase(role);
    }

    public static boolean canCreateStockRequest(String role) {
        return SELLER.equalsIgnoreCase(role);
    }

    public static boolean canApproveStockRequest(String role) {
        return ADMIN.equalsIgnoreCase(role);
    }

    // ==================== MARKETING (MARKETER) ====================
    // Admin CÓ thể quản lý sản phẩm/danh mục (Technical) nhưng KHÔNG làm Marketing

    public static boolean canManageProducts(String role) {
        return MARKETER.equalsIgnoreCase(role) || ADMIN.equalsIgnoreCase(role);
    }

    public static boolean canManageCatalog(String role) {
        return MARKETER.equalsIgnoreCase(role) || ADMIN.equalsIgnoreCase(role);
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

    // ==================== PATH-BASED ACCESS CONTROL ====================

    public static boolean hasPermission(String role, String path) {
        return hasPermission(role, path, null);
    }

    public static boolean hasPermission(String role, String path, String action) {
        if (role == null || path == null) return false;

        // Global checks
        if (path.equals("/dashboard") || path.isEmpty() || path.equals("/")) {
            return canViewDashboard(role);
        }
        
        if (path.startsWith("/rfq") || path.startsWith("/quotations")) {
            return canManageRFQ(role);
        }
        
        if (path.startsWith("/stock-requests")) {
            return canManageStockRequests(role);
        }
        
        if (path.startsWith("/refund")) {
            return canManageRefunds(role);
        }

        // 1. ADMIN - Đã loại bỏ Orders, Marketing, Voucher, Reports
        if (ADMIN.equalsIgnoreCase(role)) {
            if (path.startsWith("/employees")) return true;
            if (path.startsWith("/products") || path.startsWith("/product-")) return true;
            if (path.startsWith("/stock")) return true;
            if (path.startsWith("/categories")) return true;
            if (path.startsWith("/brands")) return true;
            if (path.startsWith("/attributes")) return true;
            if (path.startsWith("/settings")) return true;
            if (path.startsWith("/api/")) return true; // API endpoints cho product management
            // Admin quản lý Stock Requests (đã check ở Global block trên)
            return false;
        }

        // 2. SELLER MANAGER
        if (SELLER_MANAGER.equalsIgnoreCase(role)) {
            if (path.startsWith("/customers")) return true;
            if (path.startsWith("/orders")) return true;
            if (path.startsWith("/reports")) return true;
            return false;
        }

        // 3. SELLER
        if (SELLER.equalsIgnoreCase(role)) {
            // Đơn hàng - list, detail và updateStatus
            if (path.startsWith("/orders")) {
                if (action == null || action.isEmpty()) return true;
                if ("list".equals(action)) return true;
                if ("detail".equals(action)) return true;
                if ("updateStatus".equals(action)) return true;  // Cho phép Seller cập nhật trạng thái
                if ("updateNote".equals(action)) return true;    // Cho phép Seller cập nhật ghi chú
                // Không cho phép: assignment, shipperAssignment, shipperOrders
                return false;
            }
            return false;
        }

        // 4. MARKETER
        if (MARKETER.equalsIgnoreCase(role)) {
            if (path.startsWith("/products") || path.startsWith("/product-")) return true;
            if (path.startsWith("/categories")) return true;
            if (path.startsWith("/brands")) return true;
            if (path.startsWith("/attributes")) return true;
            if (path.startsWith("/slider")) return true;
            if (path.startsWith("/blog")) return true;
            if (path.startsWith("/discount")) return true;
            if (path.startsWith("/voucher")) return true;
            if (path.startsWith("/feedbacks")) return true;
            if (path.startsWith("/api/")) return true; // API endpoints cho product management
            return false;
        }

        // 5. SHIPPER
        if (SHIPPER.equalsIgnoreCase(role)) {
            // Đơn hàng - shipperOrders, shipperDetail và updateShippingStatus
            if (path.startsWith("/orders")) {
                if ("shipperOrders".equals(action)) return true;
                if ("shipperDetail".equals(action)) return true;
                if ("updateShippingStatus".equals(action)) return true;  // Cho phép Shipper cập nhật trạng thái giao hàng
                // Không cho phép các action khác
                return false;
            }
            return false;
        }

        return false;
    }

    public static String getDefaultPage(String role) {
        return "/admin/dashboard";
    }

    public static String getRoleDisplayName(String role) {
        if (role == null) return "Unknown";
        switch (role.toLowerCase()) {
            case "admin": return "Quản trị viên";
            case "sellermanager": return "Quản lý bán hàng";
            case "seller": return "Nhân viên bán hàng";
            case "marketer": return "Nhân viên marketing";
            case "staff": return "Nhân viên";
            case "shipper": return "Nhân viên giao hàng";
            default: return role;
        }
    }
}
