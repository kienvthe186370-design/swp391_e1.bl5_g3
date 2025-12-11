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
        String profitMarginTargetStr = request.getParameter("profitMarginTarget");

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

        // Lấy thông tin hiện tại để so sánh profitMarginTarget
        Map<String, Object> currentDetail = stockDAO.getStockDetail(variantId);
        BigDecimal currentProfitMargin = (BigDecimal) currentDetail.get("profitMarginTarget");
        if (currentProfitMargin == null) {
            currentProfitMargin = new BigDecimal("30");
        }

        // Validate và xử lý profitMarginTarget
        BigDecimal newProfitMarginTarget = null;
        if (profitMarginTargetStr != null && !profitMarginTargetStr.trim().isEmpty()) {
            try {
                newProfitMarginTarget = new BigDecimal(profitMarginTargetStr);
                if (newProfitMarginTarget.compareTo(BigDecimal.ZERO) < 0 || 
                    newProfitMarginTarget.compareTo(new BigDecimal("500")) > 0) {
                    request.setAttribute("errorMessage", "% Lợi nhuận phải từ 0 đến 500");
                    doGet(request, response);
                    return;
                }
            } catch (NumberFormatException e) {
                request.setAttribute("errorMessage", "% Lợi nhuận không hợp lệ");
                doGet(request, response);
                return;
            }
        }

        // Validate quantity (cho phép 0 hoặc rỗng nếu chỉ thay đổi % lợi nhuận)
        int quantity = 0;
        if (quantityStr != null && !quantityStr.trim().isEmpty()) {
            try {
                quantity = Integer.parseInt(quantityStr);
                if (quantity < 0) {
                    request.setAttribute("errorMessage", "Số lượng không được âm");
                    doGet(request, response);
                    return;
                }
            } catch (NumberFormatException e) {
                request.setAttribute("errorMessage", "Số lượng không hợp lệ");
                doGet(request, response);
                return;
            }
        }

        // Validate unitCost (bắt buộc nếu quantity > 0)
        BigDecimal unitCost = BigDecimal.ZERO;
        if (quantity > 0) {
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
        }

        // Kiểm tra: phải có ít nhất 1 thay đổi (nhập kho hoặc thay đổi % lợi nhuận)
        boolean hasProfitMarginChange = newProfitMarginTarget != null && 
                newProfitMarginTarget.compareTo(currentProfitMargin) != 0;
        boolean hasStockImport = quantity > 0;
        
        if (!hasProfitMarginChange && !hasStockImport) {
            request.setAttribute("errorMessage", "Vui lòng nhập số lượng hoặc thay đổi % lợi nhuận");
            doGet(request, response);
            return;
        }

        // Lấy employeeId từ session
        Employee employee = (Employee) session.getAttribute("employee");
        Integer createdBy = employee != null ? employee.getEmployeeID() : null;

        boolean success = true;
        
        // Cập nhật % lợi nhuận nếu có thay đổi
        if (hasProfitMarginChange) {
            success = stockDAO.updateProfitMarginTarget(variantId, newProfitMarginTarget);
        }
        
        // Insert phiếu nhập nếu có số lượng
        if (success && hasStockImport) {
            StockReceipt receipt = new StockReceipt(variantId, quantity, unitCost, createdBy);
            success = stockDAO.insertReceipt(receipt);
            
            if (success) {
                // Tính lại stock và giá vốn, giá bán
                stockDAO.recalculateStock(variantId);
            }
        }
        
        if (success) {
            // Redirect với thông báo thành công
            response.sendRedirect(request.getContextPath() + 
                    "/admin/stock/detail?id=" + variantId + "&success=true");
        } else {
            request.setAttribute("errorMessage", "Có lỗi xảy ra. Vui lòng thử lại.");
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
