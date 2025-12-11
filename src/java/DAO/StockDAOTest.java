package DAO;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * Test class for StockDAO
 * Run this main method to test database connection and queries
 */
public class StockDAOTest {
    
    public static void main(String[] args) {
        System.out.println("=== StockDAO Test ===\n");
        
        StockDAO stockDAO = new StockDAO();
        
        // Test 1: Kiểm tra kết nối database
        System.out.println("Test 1: Kiểm tra kết nối database...");
        try {
            java.sql.Connection conn = stockDAO.getConnection();
            if (conn != null) {
                System.out.println("✓ Kết nối database thành công!");
                conn.close();
            } else {
                System.out.println("✗ Kết nối database thất bại!");
                return;
            }
        } catch (Exception e) {
            System.out.println("✗ Lỗi kết nối: " + e.getMessage());
            return;
        }
        
        // Test 2: Kiểm tra bảng StockReceipts tồn tại
        System.out.println("\nTest 2: Kiểm tra bảng StockReceipts...");
        try {
            java.sql.Connection conn = stockDAO.getConnection();
            java.sql.DatabaseMetaData meta = conn.getMetaData();
            java.sql.ResultSet tables = meta.getTables(null, null, "StockReceipts", null);
            if (tables.next()) {
                System.out.println("✓ Bảng StockReceipts tồn tại!");
            } else {
                System.out.println("✗ Bảng StockReceipts CHƯA TỒN TẠI!");
                System.out.println("\n>>> Hãy chạy script SQL sau để tạo bảng:");
                System.out.println("--------------------------------------------");
                System.out.println("CREATE TABLE StockReceipts (");
                System.out.println("    ReceiptID INT IDENTITY(1,1) PRIMARY KEY,");
                System.out.println("    VariantID INT NOT NULL,");
                System.out.println("    Quantity INT NOT NULL CHECK (Quantity > 0),");
                System.out.println("    UnitCost DECIMAL(18,2) NOT NULL CHECK (UnitCost > 0),");
                System.out.println("    ReceiptDate DATETIME DEFAULT GETDATE(),");
                System.out.println("    CreatedBy INT NULL,");
                System.out.println("    FOREIGN KEY (VariantID) REFERENCES ProductVariants(VariantID),");
                System.out.println("    FOREIGN KEY (CreatedBy) REFERENCES Employees(EmployeeID)");
                System.out.println(");");
                System.out.println("--------------------------------------------");
            }
            conn.close();
        } catch (Exception e) {
            System.out.println("✗ Lỗi kiểm tra bảng: " + e.getMessage());
        }
        
        // Test 3: Lấy danh sách VariantID có sẵn
        System.out.println("\nTest 3: Lấy danh sách VariantID có sẵn...");
        int testVariantId = 0;
        try {
            java.sql.Connection conn = stockDAO.getConnection();
            java.sql.PreparedStatement ps = conn.prepareStatement(
                "SELECT TOP 5 pv.VariantID, pv.SKU, p.ProductName " +
                "FROM ProductVariants pv JOIN Products p ON pv.ProductID = p.ProductID " +
                "WHERE pv.IsActive = 1 ORDER BY pv.VariantID"
            );
            java.sql.ResultSet rs = ps.executeQuery();
            System.out.println("Các VariantID có sẵn:");
            while (rs.next()) {
                int vid = rs.getInt("VariantID");
                String sku = rs.getString("SKU");
                String name = rs.getString("ProductName");
                System.out.println("  - VariantID=" + vid + ", SKU=" + sku + ", Product=" + name);
                if (testVariantId == 0) testVariantId = vid;
            }
            conn.close();
            
            if (testVariantId == 0) {
                System.out.println("✗ Không có variant nào trong database!");
                return;
            }
        } catch (Exception e) {
            System.out.println("✗ Lỗi: " + e.getMessage());
            return;
        }
        
        // Test 4: Test getStockDetail
        System.out.println("\nTest 4: Test getStockDetail(variantId=" + testVariantId + ")...");
        try {
            Map<String, Object> detail = stockDAO.getStockDetail(testVariantId);
            if (detail != null && !detail.isEmpty()) {
                System.out.println("✓ getStockDetail thành công!");
                System.out.println("  - variantId: " + detail.get("variantId"));
                System.out.println("  - sku: " + detail.get("sku"));
                System.out.println("  - productName: " + detail.get("productName"));
                System.out.println("  - sellingPrice: " + detail.get("sellingPrice"));
                System.out.println("  - currentStock: " + detail.get("currentStock"));
                System.out.println("  - avgCostPrice: " + detail.get("avgCostPrice"));
                System.out.println("  - mainImage: " + detail.get("mainImage"));
            } else {
                System.out.println("✗ getStockDetail trả về rỗng!");
                System.out.println("  Kiểm tra lại query SQL trong StockDAO.getStockDetail()");
            }
        } catch (Exception e) {
            System.out.println("✗ Lỗi getStockDetail: " + e.getMessage());
            e.printStackTrace();
        }
        
        // Test 5: Test getReceiptHistory
        System.out.println("\nTest 5: Test getReceiptHistory(variantId=" + testVariantId + ")...");
        try {
            List<Map<String, Object>> history = stockDAO.getReceiptHistory(testVariantId);
            System.out.println("✓ getReceiptHistory thành công! Số phiếu nhập: " + history.size());
            for (Map<String, Object> receipt : history) {
                System.out.println("  - ReceiptID=" + receipt.get("receiptId") + 
                                   ", Qty=" + receipt.get("quantity") + 
                                   ", UnitCost=" + receipt.get("unitCost"));
            }
        } catch (Exception e) {
            System.out.println("✗ Lỗi getReceiptHistory: " + e.getMessage());
        }
        
        // Test 6: Test getReceiptSummary
        System.out.println("\nTest 6: Test getReceiptSummary(variantId=" + testVariantId + ")...");
        try {
            Map<String, Object> summary = stockDAO.getReceiptSummary(testVariantId);
            System.out.println("✓ getReceiptSummary thành công!");
            System.out.println("  - totalQuantity: " + summary.get("totalQuantity"));
            System.out.println("  - totalAmount: " + summary.get("totalAmount"));
        } catch (Exception e) {
            System.out.println("✗ Lỗi getReceiptSummary: " + e.getMessage());
        }
        
        System.out.println("\n=== Test hoàn tất ===");
        System.out.println("\nNếu Test 4 thất bại (getStockDetail trả về rỗng), hãy thử:");
        System.out.println("1. Truy cập URL: /admin/stock/detail?id=" + testVariantId);
        System.out.println("2. Kiểm tra console server để xem lỗi SQL");
    }
}
