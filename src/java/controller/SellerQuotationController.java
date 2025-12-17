package controller;

import DAO.RFQDAO;
import entity.Employee;
import entity.RFQ;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * SellerQuotationController - Danh sách đơn báo giá cho Seller Manager
 */
@WebServlet(name = "SellerQuotationController", urlPatterns = {"/admin/quotations"})
public class SellerQuotationController extends HttpServlet {

    private RFQDAO rfqDAO = new RFQDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Employee employee = (Employee) session.getAttribute("employee");
        if (employee == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (Exception ignored) {}
        int pageSize = 5;

        String keyword = request.getParameter("keyword");
        String status = request.getParameter("status");

        int pendingCount = rfqDAO.countQuotations(keyword, RFQ.STATUS_QUOTED);
        int paidCount = rfqDAO.countQuotations(keyword, RFQ.STATUS_COMPLETED);
        int rejectedCount = rfqDAO.countQuotations(keyword, RFQ.STATUS_QUOTE_REJECTED);

        List<RFQ> quotations = rfqDAO.getQuotations(keyword, status, page, pageSize);
        int totalCount = rfqDAO.countQuotations(keyword, status);
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

        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-quotation-list.jsp")
               .forward(request, response);
    }
}
