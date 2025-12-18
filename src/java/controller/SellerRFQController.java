package controller;

import DAO.RFQDAONew;
import DAO.QuotationDAO;
import entity.RFQ;
import entity.Quotation;
import entity.Employee;
import utils.RolePermission;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.List;

/**
 * SellerRFQController - Xử lý các request RFQ từ phía Seller
 * 
 * Luồng mới (đã tách Quotation):
 * 1. Seller xem danh sách RFQ được assign
 * 2. Thương lượng ngày giao (max 3 lần)
 * 3. Tạo Quotation (chuyển sang SellerQuotationController)
 * 
 * URL Patterns:
 * - /admin/rfq (GET) - Danh sách RFQ
 * - /admin/rfq/detail (GET) - Chi tiết RFQ
 * - /admin/rfq/propose-date (POST) - Đề xuất ngày giao mới
 * - /admin/rfq/update-notes (POST) - Cập nhật ghi chú
 */
@WebServlet(name = "SellerRFQController", urlPatterns = {"/admin/rfq", "/admin/rfq/*"})
public class SellerRFQController extends HttpServlet {

    private RFQDAONew rfqDAO = new RFQDAONew();
    private QuotationDAO quotationDAO = new QuotationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo();
        if (pathInfo == null) pathInfo = "";
        
        // Check login and permission
        HttpSession session = request.getSession();
        Employee employee = (Employee) session.getAttribute("employee");
        if (employee == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // Check if user can process RFQ (Seller role)
        if (!RolePermission.canProcessRFQ(employee.getRole())) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=access_denied");
            return;
        }
        
        switch (pathInfo) {
            case "":
            case "/":
            case "/list":
                showRFQList(request, response, employee);
                break;
            case "/detail":
                showRFQDetail(request, response, employee);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/rfq");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String pathInfo = request.getPathInfo();
        
        // Check login and permission
        HttpSession session = request.getSession();
        Employee employee = (Employee) session.getAttribute("employee");
        if (employee == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        if (!RolePermission.canProcessRFQ(employee.getRole())) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=access_denied");
            return;
        }
        
        switch (pathInfo) {
            case "/propose-date":
                proposeDate(request, response, employee);
                break;
            case "/update-notes":
                updateNotes(request, response, employee);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/rfq");
        }
    }

    private void showRFQList(HttpServletRequest request, HttpServletResponse response, Employee employee)
            throws ServletException, IOException {
        
        String keyword = request.getParameter("keyword");
        String status = request.getParameter("status");
        
        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (Exception e) {}
        
        int pageSize = 5;
        
        // Seller chỉ xem RFQ được assign cho mình
        List<RFQ> rfqs = rfqDAO.getSellerRFQs(employee.getEmployeeID(), keyword, status, page, pageSize);
        int totalCount = rfqDAO.countSellerRFQs(employee.getEmployeeID(), keyword, status);
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        if (totalPages < 1) totalPages = 1; // Luôn có ít nhất 1 trang
        
        // Statistics for this seller
        int[] stats = rfqDAO.getRFQStatistics(employee.getEmployeeID());
        
        request.setAttribute("rfqs", rfqs);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("keyword", keyword);
        request.setAttribute("status", status);
        request.setAttribute("pendingCount", stats[0]);
        request.setAttribute("reviewingCount", stats[1]);
        request.setAttribute("negotiatingCount", stats[2]);
        request.setAttribute("quotationCreatedCount", stats[3]);
        request.setAttribute("completedCount", stats[4]);
        
        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-rfq-list.jsp").forward(request, response);
    }

    private void showRFQDetail(HttpServletRequest request, HttpServletResponse response, Employee employee)
            throws ServletException, IOException {
        
        int rfqID = Integer.parseInt(request.getParameter("id"));
        RFQ rfq = rfqDAO.getRFQById(rfqID);
        
        if (rfq == null) {
            response.sendRedirect(request.getContextPath() + "/admin/rfq");
            return;
        }
        
        // Security check - Seller chỉ xem RFQ được assign cho mình
        if (!rfqDAO.isRFQAssignedToSeller(rfqID, employee.getEmployeeID())) {
            response.sendRedirect(request.getContextPath() + "/admin/rfq?error=access_denied");
            return;
        }
        
        rfq.setHistory(rfqDAO.getRFQHistory(rfqID));
        
        // Load Quotation if exists
        Quotation quotation = quotationDAO.getQuotationByRFQId(rfqID);
        if (quotation != null) {
            rfq.setQuotation(quotation);
        }
        
        request.setAttribute("rfq", rfq);
        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-rfq-detail.jsp").forward(request, response);
    }

    private void proposeDate(HttpServletRequest request, HttpServletResponse response, Employee employee)
            throws ServletException, IOException {
        
        try {
            int rfqID = Integer.parseInt(request.getParameter("rfqId"));
            String proposedDateStr = request.getParameter("proposedDate");
            String reason = request.getParameter("reason");
            
            // Security check
            if (!rfqDAO.isRFQAssignedToSeller(rfqID, employee.getEmployeeID())) {
                response.sendRedirect(request.getContextPath() + "/admin/rfq?error=access_denied");
                return;
            }
            
            RFQ rfq = rfqDAO.getRFQById(rfqID);
            if (rfq == null || !rfq.canSellerProposeDate()) {
                response.sendRedirect(request.getContextPath() + "/admin/rfq/detail?id=" + rfqID + "&error=cannot_propose");
                return;
            }
            
            // Parse date
            SimpleDateFormat sdf;
            if (proposedDateStr.contains("/")) {
                sdf = new SimpleDateFormat("dd/MM/yyyy");
            } else {
                sdf = new SimpleDateFormat("yyyy-MM-dd");
            }
            Timestamp proposedDate = new Timestamp(sdf.parse(proposedDateStr).getTime());
            
            boolean success = rfqDAO.proposeDeliveryDate(rfqID, proposedDate, reason, employee.getEmployeeID());
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/rfq/detail?id=" + rfqID + "&success=date_proposed");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/rfq/detail?id=" + rfqID + "&error=propose_failed");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/rfq?error=propose_failed");
        }
    }

    private void updateNotes(HttpServletRequest request, HttpServletResponse response, Employee employee)
            throws ServletException, IOException {
        
        int rfqID = Integer.parseInt(request.getParameter("rfqId"));
        String notes = request.getParameter("sellerNotes");
        
        // Security check
        if (!rfqDAO.isRFQAssignedToSeller(rfqID, employee.getEmployeeID())) {
            response.sendRedirect(request.getContextPath() + "/admin/rfq?error=access_denied");
            return;
        }
        
        rfqDAO.updateSellerNotes(rfqID, notes, employee.getEmployeeID());
        response.sendRedirect(request.getContextPath() + "/admin/rfq/detail?id=" + rfqID + "&success=notes_updated");
    }
}
