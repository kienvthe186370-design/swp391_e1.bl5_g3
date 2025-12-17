package controller;

import DAO.RFQDAO;
import entity.Employee;
import entity.RFQ;
import entity.RFQItem;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * QuotationDetailController - Hiển thị chi tiết đơn báo giá (dùng chung layout RFQ detail)
 */
@WebServlet(name = "QuotationDetailController", urlPatterns = {"/admin/quotations/detail"})
public class QuotationDetailController extends HttpServlet {

    private final RFQDAO rfqDAO = new RFQDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Employee employee = (Employee) session.getAttribute("employee");
        if (employee == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int rfqID;
        try {
            rfqID = Integer.parseInt(request.getParameter("id"));
        } catch (Exception ex) {
            response.sendRedirect(request.getContextPath() + "/admin/quotations");
            return;
        }

        RFQ rfq = rfqDAO.getRFQById(rfqID);
        if (rfq == null) {
            response.sendRedirect(request.getContextPath() + "/admin/quotations");
            return;
        }

        rfq.setHistory(rfqDAO.getRFQHistory(rfqID));

        // Bổ sung cost price nếu thiếu (giống luồng RFQ detail)
        for (RFQItem item : rfq.getItems()) {
            if (item.getVariantID() != null && item.getCostPrice() == null) {
                item.setCostPrice(rfqDAO.getWeightedAverageCost(item.getVariantID()));
            }
        }

        request.setAttribute("rfq", rfq);
        // Dùng lại trang chi tiết RFQ cho đơn báo giá
        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-rfq-detail.jsp").forward(request, response);
    }
}
