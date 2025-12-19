package controller;

import DAO.RFQDAONew;
import DAO.StockRequestDAO;
import entity.Employee;
import entity.RFQ;
import entity.RFQItem;
import entity.StockRequest;
import entity.StockRequestItem;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import utils.RolePermission;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * Controller xử lý yêu cầu nhập kho cho Seller
 */
@WebServlet(name = "SellerStockRequestController", urlPatterns = {"/admin/stock-requests"})
public class SellerStockRequestController extends HttpServlet {

    private static final int PAGE_SIZE = 5;
    private StockRequestDAO stockRequestDAO = new StockRequestDAO();
    private RFQDAONew rfqDAO = new RFQDAONew();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Employee employee = (Employee) session.getAttribute("employee");
        
        if (employee == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        String userRole = employee.getRole();
        
        // Chỉ Seller và Admin được truy cập
        if (!RolePermission.canManageStockRequests(userRole)) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=access_denied");
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null) action = "list";
        
        switch (action) {
            case "detail":
                showDetail(request, response, employee);
                break;
            case "create":
                showCreateForm(request, response, employee);
                break;
            default:
                showList(request, response, employee);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Employee employee = (Employee) session.getAttribute("employee");
        
        if (employee == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("create".equals(action)) {
            createStockRequest(request, response, employee);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/stock-requests");
        }
    }

    /**
     * Hiển thị danh sách yêu cầu nhập kho
     */
    private void showList(HttpServletRequest request, HttpServletResponse response, Employee employee)
            throws ServletException, IOException {
        
        String keyword = request.getParameter("keyword");
        String status = request.getParameter("status");
        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (Exception e) {}
        
        boolean isAdmin = "Admin".equalsIgnoreCase(employee.getRole());
        
        // Seller chỉ xem yêu cầu của mình, Admin xem tất cả
        Integer requestedBy = isAdmin ? null : employee.getEmployeeID();
        
        List<StockRequest> requests = stockRequestDAO.searchStockRequests(keyword, status, requestedBy, page, PAGE_SIZE);
        int totalRequests = stockRequestDAO.countStockRequests(keyword, status, requestedBy);
        int totalPages = (int) Math.ceil((double) totalRequests / PAGE_SIZE);
        
        // Đếm số lượng theo trạng thái cho thống kê
        int pendingCount = stockRequestDAO.countStockRequests(null, "Pending", requestedBy);
        int completedCount = stockRequestDAO.countStockRequests(null, "Completed", requestedBy);
        
        request.setAttribute("stockRequests", requests);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRequests", totalRequests);
        request.setAttribute("keyword", keyword);
        request.setAttribute("status", status);
        request.setAttribute("isAdmin", isAdmin);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("completedCount", completedCount);
        
        request.getRequestDispatcher("/AdminLTE-3.2.0/stock-request-list.jsp").forward(request, response);
    }

    /**
     * Hiển thị chi tiết yêu cầu nhập kho
     */
    private void showDetail(HttpServletRequest request, HttpServletResponse response, Employee employee)
            throws ServletException, IOException {
        
        int requestID = 0;
        try {
            requestID = Integer.parseInt(request.getParameter("id"));
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/stock-requests?error=invalid_id");
            return;
        }
        
        StockRequest stockRequest = stockRequestDAO.getStockRequestById(requestID);
        if (stockRequest == null) {
            response.sendRedirect(request.getContextPath() + "/admin/stock-requests?error=not_found");
            return;
        }
        
        // Seller chỉ xem yêu cầu của mình
        boolean isAdmin = "Admin".equalsIgnoreCase(employee.getRole());
        if (!isAdmin && stockRequest.getRequestedBy() != employee.getEmployeeID()) {
            response.sendRedirect(request.getContextPath() + "/admin/stock-requests?error=access_denied");
            return;
        }
        
        request.setAttribute("stockRequest", stockRequest);
        request.setAttribute("isAdmin", isAdmin);
        
        request.getRequestDispatcher("/AdminLTE-3.2.0/stock-request-detail.jsp").forward(request, response);
    }

    /**
     * Hiển thị form tạo yêu cầu nhập hàng (từ RFQ)
     */
    private void showCreateForm(HttpServletRequest request, HttpServletResponse response, Employee employee)
            throws ServletException, IOException {
        
        int rfqID = 0;
        try {
            rfqID = Integer.parseInt(request.getParameter("rfqId"));
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/rfq?action=detail&id=" + request.getParameter("rfqId") + "&error=invalid_rfq");
            return;
        }
        
        // Kiểm tra RFQ đã có yêu cầu nhập hàng chưa
        if (stockRequestDAO.hasStockRequestForRFQ(rfqID)) {
            response.sendRedirect(request.getContextPath() + "/admin/rfq?action=detail&id=" + rfqID + "&error=already_has_request");
            return;
        }
        
        RFQ rfq = rfqDAO.getRFQById(rfqID);
        if (rfq == null) {
            response.sendRedirect(request.getContextPath() + "/admin/rfq?action=detail&id=" + rfqID + "&error=rfq_not_found");
            return;
        }
        
        // Lấy thông tin tồn kho cho từng item
        List<RFQItem> itemsWithStock = getRFQItemsWithStock(rfq.getItems());
        
        // Lọc chỉ những item thiếu hàng
        List<RFQItem> shortageItems = new ArrayList<>();
        for (RFQItem item : itemsWithStock) {
            int stock = item.getProduct() != null ? item.getProduct().getTotalStock() : 0;
            if (item.getQuantity() > stock) {
                shortageItems.add(item);
            }
        }
        
        if (shortageItems.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/rfq?action=detail&id=" + rfqID + "&info=no_shortage");
            return;
        }
        
        request.setAttribute("rfq", rfq);
        request.setAttribute("shortageItems", shortageItems);
        
        request.getRequestDispatcher("/AdminLTE-3.2.0/stock-request-form.jsp").forward(request, response);
    }

    /**
     * Tạo yêu cầu nhập hàng
     */
    private void createStockRequest(HttpServletRequest request, HttpServletResponse response, Employee employee)
            throws ServletException, IOException {
        
        int rfqID = 0;
        try {
            rfqID = Integer.parseInt(request.getParameter("rfqId"));
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/rfq?action=detail&id=" + request.getParameter("rfqId") + "&error=invalid_rfq");
            return;
        }
        
        // Kiểm tra RFQ đã có yêu cầu nhập hàng chưa
        if (stockRequestDAO.hasStockRequestForRFQ(rfqID)) {
            response.sendRedirect(request.getContextPath() + "/admin/rfq?action=detail&id=" + rfqID + "&error=already_has_request");
            return;
        }
        
        RFQ rfq = rfqDAO.getRFQById(rfqID);
        if (rfq == null) {
            response.sendRedirect(request.getContextPath() + "/admin/rfq?action=detail&id=" + rfqID + "&error=rfq_not_found");
            return;
        }
        
        String notes = request.getParameter("notes");
        
        // Tạo StockRequest
        StockRequest stockRequest = new StockRequest();
        stockRequest.setRfqID(rfqID);
        stockRequest.setRequestedBy(employee.getEmployeeID());
        stockRequest.setNotes(notes);
        
        // Tạo items từ form (Seller có thể tự nhập số lượng)
        List<StockRequestItem> requestItems = new ArrayList<>();
        int itemCount = 0;
        try {
            itemCount = Integer.parseInt(request.getParameter("itemCount"));
        } catch (Exception e) {}
        
        for (int i = 0; i < itemCount; i++) {
            try {
                int productId = Integer.parseInt(request.getParameter("productId_" + i));
                String variantIdStr = request.getParameter("variantId_" + i);
                Integer variantId = (variantIdStr != null && !variantIdStr.isEmpty() && !variantIdStr.equals("null")) 
                                    ? Integer.parseInt(variantIdStr) : null;
                String productName = request.getParameter("productName_" + i);
                String sku = request.getParameter("sku_" + i);
                int currentStock = Integer.parseInt(request.getParameter("currentStock_" + i));
                int rfqQuantity = Integer.parseInt(request.getParameter("rfqQuantity_" + i));
                int requestedQuantity = Integer.parseInt(request.getParameter("requestedQuantity_" + i));
                
                if (requestedQuantity > 0) {
                    StockRequestItem item = new StockRequestItem();
                    item.setProductID(productId);
                    item.setVariantID(variantId);
                    item.setProductName(productName);
                    item.setSku(sku);
                    item.setRequestedQuantity(requestedQuantity);
                    item.setCurrentStock(currentStock);
                    item.setRfqQuantity(rfqQuantity);
                    requestItems.add(item);
                }
            } catch (Exception e) {
                // Skip invalid item
            }
        }
        
        if (requestItems.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/rfq?action=detail&id=" + rfqID + "&error=no_items");
            return;
        }
        
        int requestID = stockRequestDAO.createStockRequest(stockRequest, requestItems);
        
        if (requestID > 0) {
            response.sendRedirect(request.getContextPath() + "/admin/stock-requests?action=detail&id=" + requestID + "&success=created");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/rfq?action=detail&id=" + rfqID + "&error=" + stockRequestDAO.getLastError());
        }
    }

    /**
     * Lấy RFQ items kèm thông tin tồn kho và ảnh sản phẩm
     */
    private List<RFQItem> getRFQItemsWithStock(List<RFQItem> items) {
        if (items == null) return new ArrayList<>();
        
        DAO.DBContext db = new DAO.DBContext();
        Connection conn = null;
        
        try {
            conn = db.getConnection();
            
            for (RFQItem item : items) {
                // Lấy tồn kho từ ProductVariants
                String sql = "SELECT ISNULL(SUM(Stock), 0) as TotalStock FROM ProductVariants WHERE ProductID = ?";
                if (item.getVariantID() != null) {
                    sql = "SELECT ISNULL(Stock, 0) as TotalStock FROM ProductVariants WHERE VariantID = ?";
                }
                
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    if (item.getVariantID() != null) {
                        ps.setInt(1, item.getVariantID());
                    } else {
                        ps.setInt(1, item.getProductID());
                    }
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) {
                        // Tạm lưu stock vào product object
                        entity.Product p = new entity.Product();
                        p.setTotalStock(rs.getInt("TotalStock"));
                        item.setProduct(p);
                    }
                }
                
                // Lấy ảnh sản phẩm nếu chưa có
                if (item.getProductImage() == null || item.getProductImage().isEmpty()) {
                    String imgSql = "SELECT TOP 1 ImageURL FROM ProductImages WHERE ProductID = ? ORDER BY SortOrder";
                    try (PreparedStatement ps = conn.prepareStatement(imgSql)) {
                        ps.setInt(1, item.getProductID());
                        ResultSet rs = ps.executeQuery();
                        if (rs.next()) {
                            item.setProductImage(rs.getString("ImageURL"));
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (Exception e) { e.printStackTrace(); }
            }
        }
        
        return items;
    }
}
