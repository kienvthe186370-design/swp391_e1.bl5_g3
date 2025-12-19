package controller;

import DAO.StockRequestDAO;
import entity.Employee;
import entity.StockRequest;
import entity.StockRequestItem;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * Controller xử lý approve yêu cầu nhập kho cho Admin
 */
@WebServlet(name = "AdminStockRequestController", urlPatterns = {"/admin/stock-requests/approve"})
public class AdminStockRequestController extends HttpServlet {

    private StockRequestDAO stockRequestDAO = new StockRequestDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Employee employee = (Employee) session.getAttribute("employee");
        
        if (employee == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        // Chỉ Admin được approve
        if (!"Admin".equalsIgnoreCase(employee.getRole())) {
            response.sendRedirect(request.getContextPath() + "/admin/stock-requests?error=access_denied");
            return;
        }
        
        int requestID = 0;
        try {
            requestID = Integer.parseInt(request.getParameter("requestId"));
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/stock-requests?error=invalid_id");
            return;
        }
        
        String adminNotes = request.getParameter("adminNotes");
        
        // Lấy số lượng admin duyệt cho từng item
        StockRequest stockRequest = stockRequestDAO.getStockRequestById(requestID);
        Map<Integer, Integer> approvedQuantities = new HashMap<>();
        
        if (stockRequest != null && stockRequest.getItems() != null) {
            for (StockRequestItem item : stockRequest.getItems()) {
                String paramName = "approvedQuantity_" + item.getStockRequestItemID();
                String quantityStr = request.getParameter(paramName);
                if (quantityStr != null && !quantityStr.trim().isEmpty()) {
                    try {
                        int quantity = Integer.parseInt(quantityStr.trim());
                        if (quantity >= 0) {
                            approvedQuantities.put(item.getStockRequestItemID(), quantity);
                        }
                    } catch (NumberFormatException e) {
                        // Bỏ qua, dùng số lượng seller yêu cầu
                    }
                }
            }
        }
        
        boolean success = stockRequestDAO.approveStockRequest(requestID, employee.getEmployeeID(), adminNotes, approvedQuantities);
        
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/stock-requests?action=detail&id=" + requestID + "&success=approved");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/stock-requests?action=detail&id=" + requestID + "&error=" + stockRequestDAO.getLastError());
        }
    }
}
