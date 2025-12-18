package controller;

import DAO.QuotationDAO;
import DAO.RFQDAONew;
import entity.RFQ;
import entity.Quotation;
import entity.Customer;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

/**
 * CustomerQuotationController - Xử lý các request Quotation từ phía Customer
 * 
 * URL Patterns:
 * - /quotation/list (GET) - Danh sách Quotation của customer
 * - /quotation/detail (GET) - Chi tiết Quotation
 * - /quotation/accept (POST) - Chấp nhận báo giá
 * - /quotation/reject (POST) - Từ chối báo giá
 * - /quotation/counter (POST) - Counter giá
 */
@WebServlet(name = "CustomerQuotationController", urlPatterns = {"/quotation/*"})
public class CustomerQuotationController extends HttpServlet {

    private QuotationDAO quotationDAO = new QuotationDAO();
    private RFQDAONew rfqDAO = new RFQDAONew();

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
            case "/accept":
                acceptQuotation(request, response, customer);
                break;
            case "/reject":
                rejectQuotation(request, response, customer);
                break;
            case "/counter":
                counterPrice(request, response, customer);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/quotation/list");
        }
    }

    /**
     * Hiển thị danh sách Quotation của customer
     */
    private void showQuotationList(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (Exception ignored) {}
        int pageSize = 10;

        String keyword = request.getParameter("keyword");
        String status = request.getParameter("status");

        // Lấy danh sách Quotation
        List<Quotation> quotations = quotationDAO.getCustomerQuotations(customer.getCustomerID(), 
                                                                         keyword, status, page, pageSize);
        int totalCount = quotationDAO.countCustomerQuotations(customer.getCustomerID(), keyword, status);
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);

        // Load RFQ info for each quotation
        for (Quotation q : quotations) {
            RFQ rfq = rfqDAO.getRFQById(q.getRfqID());
            q.setRfq(rfq);
        }

        // Đếm số lượng theo trạng thái
        int sentCount = quotationDAO.countCustomerQuotations(customer.getCustomerID(), null, Quotation.STATUS_SENT);
        int negotiatingCount = quotationDAO.countCustomerQuotations(customer.getCustomerID(), null, Quotation.STATUS_CUSTOMER_COUNTERED)
                             + quotationDAO.countCustomerQuotations(customer.getCustomerID(), null, Quotation.STATUS_SELLER_COUNTERED);
        int acceptedCount = quotationDAO.countCustomerQuotations(customer.getCustomerID(), null, Quotation.STATUS_ACCEPTED);
        int paidCount = quotationDAO.countCustomerQuotations(customer.getCustomerID(), null, Quotation.STATUS_PAID);

        request.setAttribute("quotations", quotations);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("keyword", keyword);
        request.setAttribute("status", status);
        request.setAttribute("sentCount", sentCount);
        request.setAttribute("negotiatingCount", negotiatingCount);
        request.setAttribute("acceptedCount", acceptedCount);
        request.setAttribute("paidCount", paidCount);

        request.getRequestDispatcher("/customer/quotation-list.jsp").forward(request, response);
    }

    /**
     * Hiển thị chi tiết Quotation
     */
    private void showQuotationDetail(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        try {
            int quotationID = 0;
            try {
                quotationID = Integer.parseInt(request.getParameter("id"));
            } catch (Exception e) {
                response.sendRedirect(request.getContextPath() + "/quotation/list");
                return;
            }

            Quotation quotation = quotationDAO.getQuotationById(quotationID);
            
            if (quotation == null) {
                response.sendRedirect(request.getContextPath() + "/quotation/list?error=not_found");
                return;
            }

            // Load RFQ để kiểm tra quyền
            RFQ rfq = rfqDAO.getRFQById(quotation.getRfqID());
            if (rfq == null || rfq.getCustomerID() != customer.getCustomerID()) {
                response.sendRedirect(request.getContextPath() + "/quotation/list?error=access_denied");
                return;
            }

            quotation.setRfq(rfq);
            quotation.setItems(quotationDAO.getQuotationItems(quotationID));
            quotation.setHistory(quotationDAO.getQuotationHistory(quotationID));

            request.setAttribute("quotation", quotation);
            request.getRequestDispatcher("/customer/quotation-detail.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/quotation/list?error=exception&msg=" + e.getMessage());
        }
    }

    /**
     * Chấp nhận báo giá
     */
    private void acceptQuotation(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        int quotationID = Integer.parseInt(request.getParameter("quotationId"));
        Quotation quotation = quotationDAO.getQuotationById(quotationID);
        
        if (quotation == null) {
            response.sendRedirect(request.getContextPath() + "/quotation/list");
            return;
        }

        // Kiểm tra quyền
        RFQ rfq = rfqDAO.getRFQById(quotation.getRfqID());
        if (rfq == null || rfq.getCustomerID() != customer.getCustomerID()) {
            response.sendRedirect(request.getContextPath() + "/quotation/list");
            return;
        }

        // Kiểm tra có thể accept không
        if (!quotation.canAccept()) {
            response.sendRedirect(request.getContextPath() + "/quotation/detail?id=" + quotationID + "&error=cannot_accept");
            return;
        }

        // Kiểm tra hết hạn
        if (quotation.isExpired()) {
            response.sendRedirect(request.getContextPath() + "/quotation/detail?id=" + quotationID + "&error=expired");
            return;
        }

        boolean success = quotationDAO.acceptQuotation(quotationID, customer.getCustomerID());
        
        if (success) {
            // Redirect to payment page
            response.sendRedirect(request.getContextPath() + "/quotation/detail?id=" + quotationID + "&success=accepted");
        } else {
            response.sendRedirect(request.getContextPath() + "/quotation/detail?id=" + quotationID + "&error=accept_failed");
        }
    }

    /**
     * Từ chối báo giá
     */
    private void rejectQuotation(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        int quotationID = Integer.parseInt(request.getParameter("quotationId"));
        String reason = request.getParameter("reason");
        
        if (reason == null || reason.trim().isEmpty()) {
            reason = "Khách hàng từ chối báo giá";
        }

        Quotation quotation = quotationDAO.getQuotationById(quotationID);
        
        if (quotation == null) {
            response.sendRedirect(request.getContextPath() + "/quotation/list");
            return;
        }

        // Kiểm tra quyền
        RFQ rfq = rfqDAO.getRFQById(quotation.getRfqID());
        if (rfq == null || rfq.getCustomerID() != customer.getCustomerID()) {
            response.sendRedirect(request.getContextPath() + "/quotation/list");
            return;
        }

        boolean success = quotationDAO.rejectQuotation(quotationID, reason, customer.getCustomerID());
        
        if (success) {
            response.sendRedirect(request.getContextPath() + "/quotation/detail?id=" + quotationID + "&success=rejected");
        } else {
            response.sendRedirect(request.getContextPath() + "/quotation/detail?id=" + quotationID + "&error=reject_failed");
        }
    }

    /**
     * Counter giá
     */
    private void counterPrice(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        try {
            int quotationID = Integer.parseInt(request.getParameter("quotationId"));
            String counterPriceStr = request.getParameter("counterPrice");
            String note = request.getParameter("note");

            Quotation quotation = quotationDAO.getQuotationById(quotationID);
            
            if (quotation == null) {
                response.sendRedirect(request.getContextPath() + "/quotation/list");
                return;
            }

            // Kiểm tra quyền
            RFQ rfq = rfqDAO.getRFQById(quotation.getRfqID());
            if (rfq == null || rfq.getCustomerID() != customer.getCustomerID()) {
                response.sendRedirect(request.getContextPath() + "/quotation/list");
                return;
            }

            // Kiểm tra có thể counter không
            if (!quotation.canCustomerCounter()) {
                response.sendRedirect(request.getContextPath() + "/quotation/detail?id=" + quotationID + "&error=cannot_counter");
                return;
            }

            BigDecimal counterPrice = new BigDecimal(counterPriceStr);
            boolean success = quotationDAO.customerCounterPrice(quotationID, counterPrice, note, customer.getCustomerID());

            if (success) {
                response.sendRedirect(request.getContextPath() + "/quotation/detail?id=" + quotationID + "&success=countered");
            } else {
                response.sendRedirect(request.getContextPath() + "/quotation/detail?id=" + quotationID + "&error=counter_failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/quotation/list?error=counter_failed");
        }
    }
}
