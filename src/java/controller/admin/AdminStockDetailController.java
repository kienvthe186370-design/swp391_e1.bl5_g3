package controller.admin;

import DAO.StockDAO;
import entity.Employee;
import entity.StockReceipt;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * Controller xử lý nhập kho sản phẩm (F_27)
 * URL: /admin/stock/detail
 */
@WebServlet(name = "AdminStockDetailController", urlPatterns = {"/admin/stock/detail"})
public class AdminStockDetailController extends HttpServlet {

    private StockDAO stockDAO;

    @Override
    public void init() throws ServletException {
        stockDAO = new StockDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra đăng nhập
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employee") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Lấy variantId từ parameter
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=" + 
                    encodeURL("Không tìm thấy sản phẩm"));
            return;
        }

        int variantId;
        try {
            variantId = Integer.parseInt(idStr);
            if (variantId <= 0) {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=" + 
                    encodeURL("ID sản phẩm không hợp lệ"));
            return;
        }

        // Lấy thông tin stock detail
        Map<String, Object> stockDetail = stockDAO.getStockDetail(variantId);
        if (stockDetail == null || stockDetail.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=" + 
                    encodeURL("Không tìm thấy thông tin sản phẩm"));
            return;
        }

        // Lấy lịch sử nhập kho
        List<Map<String, Object>> receiptHistory = stockDAO.getReceiptHistory(variantId);
        
        // Lấy tổng hợp
        Map<String, Object> receiptSummary = stockDAO.getReceiptSummary(variantId);

        // Set attributes
        request.setAttribute("stockDetail", stockDetail);
        request.setAttribute("receiptHistory", receiptHistory);
        request.setAttribute("receiptSummary", receiptSummary);
        request.setAttribute("variantId", variantId);

        // Hiển thị thông báo thành công nếu có
        String success = request.getParameter("success");
        if ("true".equals(success)) {
            request.setAttribute("successMessage", "Nhập kho thành công!");
        }

        // Set content page for AdminLTE layout
        request.setAttribute("contentPage", "stock-detail");
        request.setAttribute("activePage", "stock");
        request.setAttribute("pageTitle", "Nhập kho sản phẩm");

        // Forward đến AdminLTE index.jsp
        request.getRequestDispatcher("/AdminLTE-3.2.0/index.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        // Kiểm tra đăng nhập
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employee") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Lấy parameters
        String variantIdStr = request.getParameter("variantId");
        String quantityStr = request.getParameter("quantity");
        String unitCostStr = request.getParameter("unitCost");

        // Validate variantId
        int variantId;
        try {
            variantId = Integer.parseInt(variantIdStr);
            if (variantId <= 0) {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/products?error=" + 
                    encodeURL("ID sản phẩm không hợp lệ"));
            return;
        }

        // Validate quantity
        int quantity;
        try {
            quantity = Integer.parseInt(quantityStr);
            if (quantity <= 0) {
                request.setAttribute("errorMessage", "Số lượng phải lớn hơn 0");
                doGet(request, response);
                return;
            }
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Số lượng không hợp lệ");
            doGet(request, response);
            return;
        }

        // Validate unitCost
        BigDecimal unitCost;
        try {
            unitCost = new BigDecimal(unitCostStr);
            if (unitCost.compareTo(BigDecimal.ZERO) <= 0) {
                request.setAttribute("errorMessage", "Giá nhập phải lớn hơn 0");
                doGet(request, response);
                return;
            }
        } catch (NumberFormatException | NullPointerException e) {
            request.setAttribute("errorMessage", "Giá nhập không hợp lệ");
            doGet(request, response);
            return;
        }

        // Lấy employeeId từ session
        Employee employee = (Employee) session.getAttribute("employee");
        Integer createdBy = employee != null ? employee.getEmployeeID() : null;

        // Tạo StockReceipt object
        StockReceipt receipt = new StockReceipt(variantId, quantity, unitCost, createdBy);

        // Insert phiếu nhập
        boolean success = stockDAO.insertReceipt(receipt);
        
        if (success) {
            // Tính lại stock và giá vốn
            stockDAO.recalculateStock(variantId);
            
            // Redirect với thông báo thành công
            response.sendRedirect(request.getContextPath() + 
                    "/admin/stock/detail?id=" + variantId + "&success=true");
        } else {
            request.setAttribute("errorMessage", "Có lỗi xảy ra khi nhập kho. Vui lòng thử lại.");
            doGet(request, response);
        }
    }

    private String encodeURL(String str) {
        try {
            return java.net.URLEncoder.encode(str, "UTF-8");
        } catch (Exception e) {
            return str;
        }
    }
}
