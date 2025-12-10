/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;

import DAO.VoucherDAO;
import entity.Voucher;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;

/**
 * Controller for Voucher Management
 * @author xuand
 */
@WebServlet(name="VoucherController", urlPatterns={"/admin/voucher"})
public class VoucherController extends HttpServlet {
    
    private VoucherDAO voucherDAO;
    
    @Override
    public void init() throws ServletException {
        voucherDAO = new VoucherDAO();
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
                showVoucherList(request, response);
                break;
            case "add":
                showAddForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                deleteVoucher(request, response);
                break;
            case "toggleStatus":
                toggleVoucherStatus(request, response);
                break;
            default:
                showVoucherList(request, response);
                break;
        }
    } 

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        
        if ("add".equals(action)) {
            addVoucher(request, response);
        } else if ("update".equals(action)) {
            updateVoucher(request, response);
        }
    }
    
    /**
     * Show voucher list with pagination, search, filter and sort
     */
    private void showVoucherList(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        String search = request.getParameter("search");
        String status = request.getParameter("status");
        String discountType = request.getParameter("discountType");
        String sortBy = request.getParameter("sortBy");
        String sortOrder = request.getParameter("sortOrder");
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
            } catch (NumberFormatException e) {
                pageSize = 10;
            }
        }
        
        List<Voucher> vouchers = voucherDAO.getAllVouchers(search, status, discountType, sortBy, sortOrder, page, pageSize);
        int totalVouchers = voucherDAO.getTotalVouchers(search, status, discountType);
        int totalPages = (int) Math.ceil((double) totalVouchers / pageSize);
        
        request.setAttribute("vouchers", vouchers);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalVouchers", totalVouchers);
        request.setAttribute("search", search);
        request.setAttribute("status", status);
        request.setAttribute("discountType", discountType);
        request.setAttribute("sortBy", sortBy);
        request.setAttribute("sortOrder", sortOrder);
        
        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-voucher-list.jsp").forward(request, response);
    }
    
    /**
     * Show add voucher form
     */
    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-voucher-detail.jsp").forward(request, response);
    }
    
    /**
     * Show edit voucher form
     */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Voucher voucher = voucherDAO.getVoucherById(id);
        
        if (voucher != null) {
            request.setAttribute("voucher", voucher);
            request.getRequestDispatcher("/AdminLTE-3.2.0/admin-voucher-detail.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/voucher?error=notfound");
        }
    }
    
    /**
     * Add new voucher
     */
    private void addVoucher(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        try {
            String voucherCode = request.getParameter("voucherCode").trim().toUpperCase();
            String voucherName = request.getParameter("voucherName");
            String description = request.getParameter("description");
            String discountType = request.getParameter("discountType");
            BigDecimal discountValue = new BigDecimal(request.getParameter("discountValue"));
            BigDecimal minOrderValue = new BigDecimal(request.getParameter("minOrderValue"));
            
            String maxDiscountAmountStr = request.getParameter("maxDiscountAmount");
            BigDecimal maxDiscountAmount = (maxDiscountAmountStr != null && !maxDiscountAmountStr.trim().isEmpty()) 
                ? new BigDecimal(maxDiscountAmountStr) : null;
            
            String maxUsageStr = request.getParameter("maxUsage");
            Integer maxUsage = (maxUsageStr != null && !maxUsageStr.trim().isEmpty()) 
                ? Integer.parseInt(maxUsageStr) : null;
            
            String startDateStr = request.getParameter("startDate");
            String endDateStr = request.getParameter("endDate");
            
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            Timestamp startDate = new Timestamp(sdf.parse(startDateStr).getTime());
            Timestamp endDate = new Timestamp(sdf.parse(endDateStr).getTime());
            
            boolean isActive = request.getParameter("isActive") != null;
            boolean isPrivate = request.getParameter("isPrivate") != null;
            
            // Check if voucher code already exists
            if (voucherDAO.isVoucherCodeExists(voucherCode, null)) {
                response.sendRedirect(request.getContextPath() + "/admin/voucher?error=code_exists");
                return;
            }
            
            // Get current user ID from session (if available)
            HttpSession session = request.getSession();
            Integer createdBy = null;
            if (session.getAttribute("employee") != null) {
                entity.Employee emp = (entity.Employee) session.getAttribute("employee");
                createdBy = emp.getEmployeeID();
            }
            
            Voucher voucher = new Voucher();
            voucher.setVoucherCode(voucherCode);
            voucher.setVoucherName(voucherName);
            voucher.setDescription(description);
            voucher.setDiscountType(discountType);
            voucher.setDiscountValue(discountValue);
            voucher.setMinOrderValue(minOrderValue);
            voucher.setMaxDiscountAmount(maxDiscountAmount);
            voucher.setMaxUsage(maxUsage);
            voucher.setStartDate(startDate);
            voucher.setEndDate(endDate);
            voucher.setIsActive(isActive);
            voucher.setIsPrivate(isPrivate);
            voucher.setCreatedBy(createdBy);
            
            boolean success = voucherDAO.insertVoucher(voucher);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/voucher?success=added");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/voucher?error=add_failed");
            }
            
        } catch (ParseException e) {
            System.err.println("Date parsing error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/voucher?error=invalid_date");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/voucher?error=add_failed");
        }
    }
    
    /**
     * Update voucher
     */
    private void updateVoucher(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String voucherCode = request.getParameter("voucherCode").trim().toUpperCase();
            String voucherName = request.getParameter("voucherName");
            String description = request.getParameter("description");
            String discountType = request.getParameter("discountType");
            BigDecimal discountValue = new BigDecimal(request.getParameter("discountValue"));
            BigDecimal minOrderValue = new BigDecimal(request.getParameter("minOrderValue"));
            
            String maxDiscountAmountStr = request.getParameter("maxDiscountAmount");
            BigDecimal maxDiscountAmount = (maxDiscountAmountStr != null && !maxDiscountAmountStr.trim().isEmpty()) 
                ? new BigDecimal(maxDiscountAmountStr) : null;
            
            String maxUsageStr = request.getParameter("maxUsage");
            Integer maxUsage = (maxUsageStr != null && !maxUsageStr.trim().isEmpty()) 
                ? Integer.parseInt(maxUsageStr) : null;
            
            String startDateStr = request.getParameter("startDate");
            String endDateStr = request.getParameter("endDate");
            
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            Timestamp startDate = new Timestamp(sdf.parse(startDateStr).getTime());
            Timestamp endDate = new Timestamp(sdf.parse(endDateStr).getTime());
            
            boolean isActive = request.getParameter("isActive") != null;
            boolean isPrivate = request.getParameter("isPrivate") != null;
            
            // Check if voucher code already exists (excluding current voucher)
            if (voucherDAO.isVoucherCodeExists(voucherCode, id)) {
                response.sendRedirect(request.getContextPath() + "/admin/voucher?error=code_exists");
                return;
            }
            
            Voucher voucher = new Voucher();
            voucher.setVoucherID(id);
            voucher.setVoucherCode(voucherCode);
            voucher.setVoucherName(voucherName);
            voucher.setDescription(description);
            voucher.setDiscountType(discountType);
            voucher.setDiscountValue(discountValue);
            voucher.setMinOrderValue(minOrderValue);
            voucher.setMaxDiscountAmount(maxDiscountAmount);
            voucher.setMaxUsage(maxUsage);
            voucher.setStartDate(startDate);
            voucher.setEndDate(endDate);
            voucher.setIsActive(isActive);
            voucher.setIsPrivate(isPrivate);
            
            boolean success = voucherDAO.updateVoucher(voucher);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/voucher?success=updated");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/voucher?error=update_failed");
            }
            
        } catch (ParseException e) {
            System.err.println("Date parsing error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/voucher?error=invalid_date");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/voucher?error=update_failed");
        }
    }
    
    /**
     * Delete voucher
     */
    private void deleteVoucher(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        boolean success = voucherDAO.deleteVoucher(id);
        
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/voucher?success=deleted");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/voucher?error=delete_failed");
        }
    }
    
    /**
     * Toggle voucher status (active <-> inactive)
     */
    private void toggleVoucherStatus(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        boolean success = voucherDAO.toggleVoucherStatus(id);
        
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/voucher?success=toggled");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/voucher?error=toggle_failed");
        }
    }

    @Override
    public String getServletInfo() {
        return "Voucher Management Controller";
    }
}
