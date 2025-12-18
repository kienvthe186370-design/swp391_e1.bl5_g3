package controller;

import DAO.RFQDAO;
import entity.RFQ;
import entity.Customer;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * CustomerQuotationController - Xử lý các request Đơn Báo Giá từ phía Customer
 * URL Patterns:
 * - /quotation/list (GET) - Danh sách đơn báo giá của customer
 * - /quotation/detail (GET) - Chi tiết đơn báo giá
 * - /quotation/reject (POST) - Từ chối báo giá
 */
@WebServlet(name = "CustomerQuotationController", urlPatterns = {"/quotation/*"})
public class CustomerQuotationController extends HttpServlet {

    private RFQDAO rfqDAO = new RFQDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo();
        if (pathInfo == null) pathInfo = "/list";
        
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login?redirect=quotation/list");
            return;
        }
        
        switch (pathInfo) {
            case "/list":
                showQuotationList(request, response, customer);
                break;
            case "/detail":
                showQuotationDetail(request, response, customer);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/quotation/list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String pathInfo = request.getPathInfo();
        
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        switch (pathInfo) {
            case "/reject":
                rejectQuotation(request, response, customer);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/quotation/list");
        }
    }

    /**
     * Hiển thị danh sách đơn báo giá của customer
     */
    private void showQuotationList(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (Exception ignored) {}
        int pageSize = 5;

        String keyword = request.getParameter("keyword");
        String status = request.getParameter("status");

        // Đếm số lượng theo trạng thái
        int pendingCount = rfqDAO.countCustomerQuotations(customer.getCustomerID(), keyword, RFQ.STATUS_QUOTED);
        int paidCount = rfqDAO.countCustomerQuotations(customer.getCustomerID(), keyword, RFQ.STATUS_COMPLETED);
        int rejectedCount = rfqDAO.countCustomerQuotations(customer.getCustomerID(), keyword, RFQ.STATUS_QUOTE_REJECTED);

        // Lấy danh sách báo giá
        List<RFQ> quotations = rfqDAO.getCustomerQuotations(customer.getCustomerID(), keyword, status, page, pageSize);
        int totalCount = rfqDAO.countCustomerQuotations(customer.getCustomerID(), keyword, status);
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);

        request.setAttribute("quotations", quotations);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("keyword", keyword);
        request.setAttribute("status", status);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("paidCount", paidCount);
        request.setAttribute("rejectedCount", rejectedCount);

        request.getRequestDispatcher("/customer/quotation-list.jsp").forward(request, response);
    }

    /**
     * Hiển thị chi tiết đơn báo giá
     */
    private void showQuotationDetail(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        int rfqId = 0;
        try {
            rfqId = Integer.parseInt(request.getParameter("id"));
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/quotation/list");
            return;
        }

        RFQ rfq = rfqDAO.getRFQById(rfqId);
        
        // Kiểm tra quyền truy cập
        if (rfq == null || rfq.getCustomerID() != customer.getCustomerID()) {
            response.sendRedirect(request.getContextPath() + "/quotation/list");
            return;
        }
        
        // Chỉ cho phép xem các đơn đã có báo giá
        if (!rfq.getStatus().equals(RFQ.STATUS_QUOTED) && 
            !rfq.getStatus().equals(RFQ.STATUS_QUOTE_ACCEPTED) &&
            !rfq.getStatus().equals(RFQ.STATUS_QUOTE_REJECTED) &&
            !rfq.getStatus().equals(RFQ.STATUS_COMPLETED)) {
            response.sendRedirect(request.getContextPath() + "/rfq/detail?id=" + rfqId);
            return;
        }

        request.setAttribute("rfq", rfq);
        request.getRequestDispatcher("/customer/quotation-detail.jsp").forward(request, response);
    }

    /**
     * Từ chối báo giá
     */
    private void rejectQuotation(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        int rfqId = 0;
        try {
            rfqId = Integer.parseInt(request.getParameter("rfqId"));
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/quotation/list");
            return;
        }

        String reason = request.getParameter("reason");
        if (reason == null || reason.trim().isEmpty()) {
            reason = "Khách hàng từ chối báo giá";
        }

        RFQ rfq = rfqDAO.getRFQById(rfqId);
        
        // Kiểm tra quyền và trạng thái
        if (rfq == null || rfq.getCustomerID() != customer.getCustomerID() || 
            !rfq.getStatus().equals(RFQ.STATUS_QUOTED)) {
            response.sendRedirect(request.getContextPath() + "/quotation/list");
            return;
        }

        // Cập nhật trạng thái
        boolean success = rfqDAO.rejectQuotation(rfqId, reason, customer.getCustomerID());
        
        if (success) {
            response.sendRedirect(request.getContextPath() + "/quotation/detail?id=" + rfqId + "&success=rejected");
        } else {
            response.sendRedirect(request.getContextPath() + "/quotation/detail?id=" + rfqId + "&error=reject_failed");
        }
    }
}
