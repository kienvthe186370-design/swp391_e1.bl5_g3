package utils;

public class RolePermission {

    public static final String ADMIN = "Admin";
    public static final String SELLER_MANAGER = "SellerManager";
    public static final String SELLER = "Seller";
    public static final String MARKETER = "Marketer";
    public static final String STAFF = "Staff";

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

    public static boolean canViewSalesReports(String role) {
        return SELLER_MANAGER.equalsIgnoreCase(role);
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
            return canManageOrders(role);
        }

        if (path.startsWith("/products")) {
            return canManageProducts(role);
        }

        if (path.startsWith("/categories") || path.startsWith("/brands") || path.startsWith("/attributes")) {
            return canManageCatalog(role);
        }

        if (path.startsWith("/slider") || path.startsWith("/banner") || path.startsWith("/blog")) {
            return canManageMarketing(role);
        }

        if (path.startsWith("/vouchers")) {
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
            default:
                return role;
        }
    }
}
