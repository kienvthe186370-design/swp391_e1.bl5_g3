package controller;

import DAO.DiscountCampaignDAO;
import DAO.CategoryDAO;
import DAO.ProductDAO;
import DAO.BrandDAO;
import entity.DiscountCampaign;
import entity.Employee;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Controller for Admin Discount Campaign Management
 */
@WebServlet(name = "AdminDiscountCampaignController", urlPatterns = {"/admin/discount"})
public class AdminDiscountCampaignController extends HttpServlet {

    private DiscountCampaignDAO campaignDAO;
    private CategoryDAO categoryDAO;
    private ProductDAO productDAO;
    private BrandDAO brandDAO;

    @Override
    public void init() throws ServletException {
        campaignDAO = new DiscountCampaignDAO();
        categoryDAO = new CategoryDAO();
        productDAO = new ProductDAO();
        brandDAO = new BrandDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if (action == null) {
            action = "list";
        }
        
        switch (action) {
            case "list":
                showCampaignList(request, response);
                break;
            case "add":
                showAddForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "toggleStatus":
                toggleCampaignStatus(request, response);
                break;
            default:
                showCampaignList(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        
        if ("add".equals(action)) {
            addCampaign(request, response);
        } else if ("update".equals(action)) {
            updateCampaign(request, response);
        }
    }

    /**
     * Show campaign list with pagination, search and filter
     */
    private void showCampaignList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String search = request.getParameter("search");
        String status = request.getParameter("status");
        String appliedToType = request.getParameter("appliedToType");
        String pageStr = request.getParameter("page");
        String pageSizeStr = request.getParameter("pageSize");
        
        int page = 1;
        int pageSize = 10;
        
        if (pageStr != null) {
            try {
                page = Integer.parseInt(pageStr);
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        
        if (pageSizeStr != null) {
            try {
                pageSize = Integer.parseInt(pageSizeStr);
                if (pageSize != 5 && pageSize != 10 && pageSize != 20) {
                    pageSize = 10;
                }
            } catch (NumberFormatException e) {
                pageSize = 10;
            }
        }
        
        List<DiscountCampaign> campaigns = campaignDAO.getAllCampaigns(search, status, appliedToType, page, pageSize);
        int totalCampaigns = campaignDAO.getTotalCampaigns(search, status, appliedToType);
        int totalPages = (int) Math.ceil((double) totalCampaigns / pageSize);
        
        request.setAttribute("campaigns", campaigns);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCampaigns", totalCampaigns);
        request.setAttribute("search", search);
        request.setAttribute("status", status);
        request.setAttribute("appliedToType", appliedToType);
        
        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-discount-list.jsp").forward(request, response);
    }

    /**
     * Show add campaign form
     */
    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Load categories, products, brands for selection
        request.setAttribute("categories", categoryDAO.getAllCategories());
        request.setAttribute("products", productDAO.getAllProducts());
        request.setAttribute("brands", brandDAO.getAllBrands());
        
        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-discount-detail.jsp").forward(request, response);
    }

    /**
     * Show edit campaign form
     */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/discount?error=invalid");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            DiscountCampaign campaign = campaignDAO.getCampaignById(id);
            
            if (campaign != null) {
                request.setAttribute("campaign", campaign);
                
                // Load categories, products, brands for selection
                request.setAttribute("categories", categoryDAO.getAllCategories());
                request.setAttribute("products", productDAO.getAllProducts());
                request.setAttribute("brands", brandDAO.getAllBrands());
                
                request.getRequestDispatcher("/AdminLTE-3.2.0/admin-discount-detail.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/discount?error=notfound");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/discount?error=invalid");
        }
    }

    /**
     * Add new campaign
     */
    private void addCampaign(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Employee employee = (Employee) session.getAttribute("employee");
        
        if (employee == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        try {
            String campaignName = request.getParameter("campaignName");
            String discountType = request.getParameter("discountType");
            String discountValueStr = request.getParameter("discountValue");
            String maxDiscountAmountStr = request.getParameter("maxDiscountAmount");
            String appliedToType = request.getParameter("appliedToType");
            String appliedToIDStr = request.getParameter("appliedToID");
            String startDateStr = request.getParameter("startDate");
            String endDateStr = request.getParameter("endDate");
            boolean isActive = request.getParameter("isActive") != null;
            
            // Validate required fields
            if (campaignName == null || campaignName.trim().isEmpty() ||
                discountType == null || discountValueStr == null ||
                appliedToType == null || startDateStr == null || endDateStr == null) {
                response.sendRedirect(request.getContextPath() + "/admin/discount?action=add&error=missing");
                return;
            }
            
            DiscountCampaign campaign = new DiscountCampaign();
            campaign.setCampaignName(campaignName.trim());
            campaign.setDiscountType(discountType);
            campaign.setDiscountValue(new BigDecimal(discountValueStr));
            
            if (maxDiscountAmountStr != null && !maxDiscountAmountStr.trim().isEmpty()) {
                campaign.setMaxDiscountAmount(new BigDecimal(maxDiscountAmountStr));
            }
            
            campaign.setAppliedToType(appliedToType);
            
            if (!"all".equals(appliedToType) && appliedToIDStr != null && !appliedToIDStr.trim().isEmpty()) {
                campaign.setAppliedToID(Integer.parseInt(appliedToIDStr));
            }
            
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
            campaign.setStartDate(LocalDateTime.parse(startDateStr, formatter));
            campaign.setEndDate(LocalDateTime.parse(endDateStr, formatter));
            campaign.setActive(isActive);
            campaign.setCreatedBy(employee.getEmployeeID());
            
            boolean success = campaignDAO.insertCampaign(campaign);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/discount?success=added");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/discount?error=add_failed");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/discount?error=add_failed");
        }
    }

    /**
     * Update campaign
     */
    private void updateCampaign(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/discount?error=invalid");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            DiscountCampaign campaign = campaignDAO.getCampaignById(id);
            
            if (campaign == null) {
                response.sendRedirect(request.getContextPath() + "/admin/discount?error=notfound");
                return;
            }
            
            String campaignName = request.getParameter("campaignName");
            String discountType = request.getParameter("discountType");
            String discountValueStr = request.getParameter("discountValue");
            String maxDiscountAmountStr = request.getParameter("maxDiscountAmount");
            String appliedToType = request.getParameter("appliedToType");
            String appliedToIDStr = request.getParameter("appliedToID");
            String startDateStr = request.getParameter("startDate");
            String endDateStr = request.getParameter("endDate");
            boolean isActive = request.getParameter("isActive") != null;
            
            // Validate required fields
            if (campaignName == null || campaignName.trim().isEmpty() ||
                discountType == null || discountValueStr == null ||
                appliedToType == null || startDateStr == null || endDateStr == null) {
                response.sendRedirect(request.getContextPath() + "/admin/discount?action=edit&id=" + id + "&error=missing");
                return;
            }
            
            campaign.setCampaignName(campaignName.trim());
            campaign.setDiscountType(discountType);
            campaign.setDiscountValue(new BigDecimal(discountValueStr));
            
            if (maxDiscountAmountStr != null && !maxDiscountAmountStr.trim().isEmpty()) {
                campaign.setMaxDiscountAmount(new BigDecimal(maxDiscountAmountStr));
            } else {
                campaign.setMaxDiscountAmount(null);
            }
            
            campaign.setAppliedToType(appliedToType);
            
            if (!"all".equals(appliedToType) && appliedToIDStr != null && !appliedToIDStr.trim().isEmpty()) {
                campaign.setAppliedToID(Integer.parseInt(appliedToIDStr));
            } else {
                campaign.setAppliedToID(null);
            }
            
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
            campaign.setStartDate(LocalDateTime.parse(startDateStr, formatter));
            campaign.setEndDate(LocalDateTime.parse(endDateStr, formatter));
            campaign.setActive(isActive);
            
            boolean success = campaignDAO.updateCampaign(campaign);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/discount?success=updated");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/discount?error=update_failed");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/discount?error=update_failed");
        }
    }

    /**
     * Toggle campaign status
     */
    private void toggleCampaignStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/discount?error=invalid");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            boolean success = campaignDAO.toggleCampaignStatus(id);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/discount?success=toggled");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/discount?error=toggle_failed");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/discount?error=invalid");
        }
    }

    @Override
    public String getServletInfo() {
        return "Admin Discount Campaign Management Controller";
    }
}
