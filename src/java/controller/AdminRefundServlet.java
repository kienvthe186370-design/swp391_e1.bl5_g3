package controller;

import DAO.*;
import entity.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

/**
 * Servlet quản lý yêu cầu hoàn tiền cho Admin/SellerManager/Seller
 * - Admin/SellerManager: Xem và xử lý tất cả yêu cầu hoàn tiền
 * - Seller: Chỉ xem và xử lý yêu cầu hoàn tiền của đơn hàng được assign cho mình
 */
@WebServlet(name = "AdminRefundServlet", urlPatterns = {"/admin/refunds", "/admin/refund"})
public class AdminRefundServlet extends HttpServlet {

    private RefundDAO refundDAO = new RefundDAO();
    private OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Employee employee = (Employee) session.getAttribute("employee");
        
        if (employee == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }
        
        // Kiểm tra quyền: Admin, SellerManager, Seller
        String role = employee.getRole();
        if (!canAccessRefunds(role)) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            return;
        }
        
        request.setAttribute("employeeRole", role);
        
        String action = request.getParameter("action");
        if (action == null) action = "list";
        
        switch (action) {
            case "detail":
                showRefundDetail(request, response, employee);
                break;
            default:
                showRefundList(request, response, employee);
        }
    }
    
    private boolean canAccessRefunds(String role) {
        // Chỉ SellerManager và Seller có quyền truy cập refund
        // Admin không liên quan đến đơn hàng nên không xử lý refund
        return "SellerManager".equalsIgnoreCase(role) || 
               "Seller".equalsIgnoreCase(role);
    }
    
    private boolean isManager(String role) {
        // SellerManager có quyền giám sát và xác nhận hoàn tiền
        return "SellerManager".equalsIgnoreCase(role);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        Employee employee = (Employee) session.getAttribute("employee");
        
        if (employee == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }
        
        String action = request.getParameter("action");
        
        switch (action) {
            case "approve":
                approveRefund(request, response, employee);
                break;
            case "reject":
                rejectRefund(request, response, employee);
                break;
            case "complete":
                completeRefund(request, response, employee);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/refunds");
        }
    }

    /**
     * Hiển thị danh sách yêu cầu hoàn tiền
     * - Admin/SellerManager: Xem tất cả
     * - Seller: Chỉ xem đơn hàng được assign
     */
    private void showRefundList(HttpServletRequest request, HttpServletResponse response, Employee employee)
            throws ServletException, IOException {
        
        String status = request.getParameter("status");
        String role = employee.getRole();
        int page = 1;
        int pageSize = 20;
        
        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (Exception e) {}
        
        List<RefundRequest> refundRequests;
        int totalCount;
        int pendingCount, approvedCount, rejectedCount, completedCount;
        
        if (isManager(role)) {
            // SellerManager xem tất cả để giám sát
            refundRequests = refundDAO.getAllRefundRequests(status, page, pageSize);
            totalCount = refundDAO.countRefundRequests(status);
            pendingCount = refundDAO.countRefundRequests("Pending");
            approvedCount = refundDAO.countRefundRequests("Approved");
            rejectedCount = refundDAO.countRefundRequests("Rejected");
            completedCount = refundDAO.countRefundRequests("Completed");
        } else {
            // Seller chỉ xem đơn hàng được assign
            int sellerId = employee.getEmployeeID();
            refundRequests = refundDAO.getRefundRequestsBySeller(sellerId, status, page, pageSize);
            totalCount = refundDAO.countRefundRequestsBySeller(sellerId, status);
            pendingCount = refundDAO.countRefundRequestsBySeller(sellerId, "Pending");
            approvedCount = refundDAO.countRefundRequestsBySeller(sellerId, "Approved");
            rejectedCount = refundDAO.countRefundRequestsBySeller(sellerId, "Rejected");
            completedCount = refundDAO.countRefundRequestsBySeller(sellerId, "Completed");
        }
        
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        
        request.setAttribute("refundRequests", refundRequests);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("currentStatus", status);
        
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("approvedCount", approvedCount);
        request.setAttribute("rejectedCount", rejectedCount);
        request.setAttribute("completedCount", completedCount);
        
        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-refund-list.jsp").forward(request, response);
    }

    /**
     * Hiển thị chi tiết yêu cầu hoàn tiền
     */
    private void showRefundDetail(HttpServletRequest request, HttpServletResponse response, Employee employee)
            throws ServletException, IOException {
        
        String refundIdStr = request.getParameter("id");
        if (refundIdStr == null || refundIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/refunds");
            return;
        }
        
        int refundId = Integer.parseInt(refundIdStr);
        String role = employee.getRole();
        
        // Kiểm tra quyền xem: Seller chỉ xem được đơn hàng của mình
        if (!isManager(role)) {
            if (!refundDAO.canSellerProcessRefund(employee.getEmployeeID(), refundId)) {
                request.setAttribute("error", "Bạn không có quyền xem yêu cầu hoàn tiền này");
                showRefundList(request, response, employee);
                return;
            }
        }
        
        RefundRequest refundRequest = refundDAO.getRefundRequestById(refundId);
        
        if (refundRequest == null) {
            request.setAttribute("error", "Yêu cầu hoàn tiền không tồn tại");
            showRefundList(request, response, employee);
            return;
        }
        
        // Load full order info
        Order order = orderDAO.getOrderById(refundRequest.getOrderID());
        refundRequest.setOrder(order);
        
        request.setAttribute("refundRequest", refundRequest);
        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-refund-detail.jsp").forward(request, response);
    }

    /**
     * Kiểm tra quyền xử lý refund
     */
    /**
     * Kiểm tra quyền xử lý refund
     * - SellerManager: Có thể xử lý tất cả (giám sát)
     * - Seller: Chỉ xử lý đơn hàng được assign cho mình
     */
    private boolean canProcessRefund(Employee employee, int refundId) {
        String role = employee.getRole();
        if (isManager(role)) {
            return true;
        }
        // Seller chỉ xử lý được đơn hàng của mình
        return refundDAO.canSellerProcessRefund(employee.getEmployeeID(), refundId);
    }

    /**
     * Duyệt yêu cầu hoàn tiền
     */
    private void approveRefund(HttpServletRequest request, HttpServletResponse response, Employee employee)
            throws ServletException, IOException {
        
        try {
            int refundId = Integer.parseInt(request.getParameter("refundId"));
            
            // Kiểm tra quyền
            if (!canProcessRefund(employee, refundId)) {
                request.setAttribute("error", "Bạn không có quyền xử lý yêu cầu hoàn tiền này");
                showRefundList(request, response, employee);
                return;
            }
            
            String adminNotes = request.getParameter("adminNotes");
            
            boolean success = refundDAO.approveRefundRequest(refundId, employee.getEmployeeID(), adminNotes);
            
            if (success) {
                request.setAttribute("success", "Đã duyệt yêu cầu hoàn tiền #" + refundId);
            } else {
                request.setAttribute("error", "Có lỗi xảy ra khi duyệt yêu cầu");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
        }
        
        showRefundList(request, response, employee);
    }

    /**
     * Từ chối yêu cầu hoàn tiền
     */
    private void rejectRefund(HttpServletRequest request, HttpServletResponse response, Employee employee)
            throws ServletException, IOException {
        
        try {
            int refundId = Integer.parseInt(request.getParameter("refundId"));
            
            // Kiểm tra quyền
            if (!canProcessRefund(employee, refundId)) {
                request.setAttribute("error", "Bạn không có quyền xử lý yêu cầu hoàn tiền này");
                showRefundList(request, response, employee);
                return;
            }
            
            String adminNotes = request.getParameter("adminNotes");
            
            if (adminNotes == null || adminNotes.trim().isEmpty()) {
                request.setAttribute("error", "Vui lòng nhập lý do từ chối");
                showRefundList(request, response, employee);
                return;
            }
            
            boolean success = refundDAO.rejectRefundRequest(refundId, employee.getEmployeeID(), adminNotes);
            
            if (success) {
                request.setAttribute("success", "Đã từ chối yêu cầu hoàn tiền #" + refundId);
            } else {
                request.setAttribute("error", "Có lỗi xảy ra khi từ chối yêu cầu");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
        }
        
        showRefundList(request, response, employee);
    }

    /**
     * Hoàn thành hoàn tiền (sau khi đã chuyển tiền)
     * Chỉ SellerManager mới có quyền hoàn thành (vì liên quan đến chuyển tiền)
     */
    private void completeRefund(HttpServletRequest request, HttpServletResponse response, Employee employee)
            throws ServletException, IOException {
        
        try {
            // Chỉ SellerManager mới được hoàn thành (xác nhận đã chuyển tiền)
            if (!isManager(employee.getRole())) {
                request.setAttribute("error", "Chỉ SellerManager mới có quyền xác nhận hoàn tiền");
                showRefundList(request, response, employee);
                return;
            }
            
            int refundId = Integer.parseInt(request.getParameter("refundId"));
            
            // Kiểm tra trạng thái hiện tại
            RefundRequest currentRefund = refundDAO.getRefundRequestById(refundId);
            if (currentRefund == null) {
                request.setAttribute("error", "Không tìm thấy yêu cầu hoàn tiền #" + refundId);
                showRefundList(request, response, employee);
                return;
            }
            
            if (!"Approved".equals(currentRefund.getRefundStatus())) {
                request.setAttribute("error", "Chỉ có thể hoàn thành yêu cầu đã được duyệt. Trạng thái hiện tại: " + currentRefund.getRefundStatus());
                showRefundList(request, response, employee);
                return;
            }
            
            boolean success = refundDAO.completeRefund(refundId);
            System.out.println("[AdminRefundServlet] completeRefund - RefundID: " + refundId + ", Success: " + success);
            
            if (success) {
                // Cập nhật trạng thái đơn hàng
                try {
                    orderDAO.updateOrderStatus(currentRefund.getOrderID(), "Returned", employee.getEmployeeID(), 
                        "Hoàn tiền hoàn tất - Số tiền: " + currentRefund.getRefundAmount());
                    System.out.println("[AdminRefundServlet] Order status updated to Returned for OrderID: " + currentRefund.getOrderID());
                } catch (Exception orderEx) {
                    System.out.println("[AdminRefundServlet] Error updating order status: " + orderEx.getMessage());
                    // Vẫn báo thành công vì refund đã complete
                }
                request.setAttribute("success", "Đã hoàn thành hoàn tiền #" + refundId);
            } else {
                request.setAttribute("error", "Có lỗi xảy ra khi cập nhật trạng thái hoàn tiền. Vui lòng kiểm tra log server.");
            }
        } catch (Exception e) {
            System.out.println("[AdminRefundServlet] completeRefund ERROR: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
        }
        
        showRefundList(request, response, employee);
    }
}
