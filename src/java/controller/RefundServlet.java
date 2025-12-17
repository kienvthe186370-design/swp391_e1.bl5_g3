package controller;

import DAO.*;
import entity.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.*;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * Servlet xử lý yêu cầu hoàn tiền từ Customer
 */
@WebServlet(name = "RefundServlet", urlPatterns = {"/customer/refund", "/customer/refund-request"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,     // 1 MB
    maxFileSize = 1024 * 1024 * 5,       // 5 MB
    maxRequestSize = 1024 * 1024 * 25    // 25 MB
)
public class RefundServlet extends HttpServlet {

    private RefundDAO refundDAO = new RefundDAO();
    private OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null) action = "list";
        
        switch (action) {
            case "create":
                showCreateForm(request, response, customer);
                break;
            case "detail":
                showRefundDetail(request, response, customer);
                break;
            default:
                showRefundList(request, response, customer);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("submit".equals(action)) {
            submitRefundRequest(request, response, customer);
        } else {
            response.sendRedirect(request.getContextPath() + "/customer/refund");
        }
    }

    /**
     * Hiển thị danh sách yêu cầu hoàn tiền của customer
     */
    private void showRefundList(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        List<RefundRequest> refundRequests = refundDAO.getRefundRequestsByCustomer(customer.getCustomerID());
        request.setAttribute("refundRequests", refundRequests);
        request.getRequestDispatcher("/customer/refund-list.jsp").forward(request, response);
    }

    /**
     * Hiển thị form tạo yêu cầu hoàn tiền
     */
    private void showCreateForm(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr == null || orderIdStr.isEmpty()) {
            request.setAttribute("error", "Vui lòng chọn đơn hàng cần hoàn tiền");
            showRefundList(request, response, customer);
            return;
        }
        
        int orderId = Integer.parseInt(orderIdStr);
        Order order = orderDAO.getOrderById(orderId);
        
        // Kiểm tra đơn hàng thuộc về customer
        if (order == null || order.getCustomerID() != customer.getCustomerID()) {
            request.setAttribute("error", "Đơn hàng không tồn tại hoặc không thuộc về bạn");
            showRefundList(request, response, customer);
            return;
        }
        
        // Kiểm tra trạng thái đơn hàng có thể hoàn tiền
        if (!canRequestRefund(order)) {
            request.setAttribute("error", "Đơn hàng này không thể yêu cầu hoàn tiền. " +
                "Chỉ đơn hàng đã giao (Delivered) hoặc đang giao (Shipping) mới có thể yêu cầu hoàn tiền.");
            showRefundList(request, response, customer);
            return;
        }
        
        // Kiểm tra đã có yêu cầu hoàn tiền chưa
        if (refundDAO.hasRefundRequest(orderId)) {
            request.setAttribute("error", "Đơn hàng này đã có yêu cầu hoàn tiền đang xử lý");
            showRefundList(request, response, customer);
            return;
        }
        
        request.setAttribute("order", order);
        request.getRequestDispatcher("/customer/refund-request.jsp").forward(request, response);
    }

    /**
     * Hiển thị chi tiết yêu cầu hoàn tiền
     */
    private void showRefundDetail(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        String refundIdStr = request.getParameter("id");
        if (refundIdStr == null || refundIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/refund");
            return;
        }
        
        int refundId = Integer.parseInt(refundIdStr);
        RefundRequest refundRequest = refundDAO.getRefundRequestById(refundId);
        
        // Kiểm tra yêu cầu thuộc về customer
        if (refundRequest == null || refundRequest.getCustomerID() != customer.getCustomerID()) {
            request.setAttribute("error", "Yêu cầu hoàn tiền không tồn tại");
            showRefundList(request, response, customer);
            return;
        }
        
        request.setAttribute("refundRequest", refundRequest);
        request.getRequestDispatcher("/customer/refund-detail.jsp").forward(request, response);
    }

    /**
     * Xử lý submit yêu cầu hoàn tiền
     */
    private void submitRefundRequest(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        try {
            int orderId = Integer.parseInt(request.getParameter("orderId"));
            String refundReason = request.getParameter("refundReason");
            String[] itemIds = request.getParameterValues("itemIds");
            String[] quantities = request.getParameterValues("quantities");
            String[] itemReasons = request.getParameterValues("itemReasons");
            
            Order order = orderDAO.getOrderById(orderId);
            
            // Validate
            if (order == null || order.getCustomerID() != customer.getCustomerID()) {
                request.setAttribute("error", "Đơn hàng không hợp lệ");
                showRefundList(request, response, customer);
                return;
            }
            
            if (!canRequestRefund(order)) {
                request.setAttribute("error", "Đơn hàng này không thể yêu cầu hoàn tiền");
                showRefundList(request, response, customer);
                return;
            }
            
            if (refundDAO.hasRefundRequest(orderId)) {
                request.setAttribute("error", "Đơn hàng này đã có yêu cầu hoàn tiền");
                showRefundList(request, response, customer);
                return;
            }
            
            // Tính tổng tiền hoàn
            BigDecimal refundAmount = calculateRefundAmount(order, itemIds, quantities);
            
            // Tạo RefundRequest
            RefundRequest refundRequest = new RefundRequest();
            refundRequest.setOrderID(orderId);
            refundRequest.setCustomerID(customer.getCustomerID());
            refundRequest.setRefundReason(refundReason);
            refundRequest.setRefundAmount(refundAmount);
            
            int refundRequestId = refundDAO.createRefundRequest(refundRequest);
            
            if (refundRequestId > 0) {
                // Thêm các items
                if (itemIds != null) {
                    for (int i = 0; i < itemIds.length; i++) {
                        RefundItem item = new RefundItem();
                        item.setRefundRequestID(refundRequestId);
                        item.setOrderDetailID(Integer.parseInt(itemIds[i]));
                        item.setQuantity(Integer.parseInt(quantities[i]));
                        item.setItemReason(itemReasons != null && i < itemReasons.length ? itemReasons[i] : "");
                        refundDAO.addRefundItem(item);
                    }
                }
                
                // Upload media files
                uploadRefundMedia(request, refundRequestId);
                
                request.setAttribute("success", "Yêu cầu hoàn tiền đã được gửi thành công. Chúng tôi sẽ xem xét và phản hồi trong 24-48 giờ.");
            } else {
                request.setAttribute("error", "Có lỗi xảy ra khi gửi yêu cầu hoàn tiền");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
        }
        
        showRefundList(request, response, customer);
    }

    /**
     * Kiểm tra đơn hàng có thể yêu cầu hoàn tiền không
     */
    private boolean canRequestRefund(Order order) {
        String status = order.getOrderStatus();
        // Cho phép hoàn tiền khi: Delivered, Shipping (nếu muốn hủy khi đang giao)
        return "Delivered".equals(status) || "Shipping".equals(status);
    }

    /**
     * Tính tổng tiền hoàn dựa trên items được chọn
     */
    private BigDecimal calculateRefundAmount(Order order, String[] itemIds, String[] quantities) {
        if (itemIds == null || itemIds.length == 0) {
            // Hoàn toàn bộ đơn hàng
            return order.getTotalAmount();
        }
        
        BigDecimal total = BigDecimal.ZERO;
        List<OrderDetail> details = order.getOrderDetails();
        
        for (int i = 0; i < itemIds.length; i++) {
            int detailId = Integer.parseInt(itemIds[i]);
            int qty = Integer.parseInt(quantities[i]);
            
            for (OrderDetail detail : details) {
                if (detail.getOrderDetailID() == detailId) {
                    BigDecimal itemTotal = detail.getFinalPrice()
                        .divide(BigDecimal.valueOf(detail.getQuantity()), 2, BigDecimal.ROUND_HALF_UP)
                        .multiply(BigDecimal.valueOf(qty));
                    total = total.add(itemTotal);
                    break;
                }
            }
        }
        
        return total;
    }

    /**
     * Upload hình ảnh/video minh chứng
     */
    private void uploadRefundMedia(HttpServletRequest request, int refundRequestId) {
        try {
            String uploadPath = getServletContext().getRealPath("/uploads/refunds");
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            
            for (Part part : request.getParts()) {
                if (part.getName().equals("mediaFiles") && part.getSize() > 0) {
                    String fileName = getFileName(part);
                    if (fileName != null && !fileName.isEmpty()) {
                        // Generate unique filename
                        String extension = fileName.substring(fileName.lastIndexOf("."));
                        String newFileName = UUID.randomUUID().toString() + extension;
                        String filePath = uploadPath + File.separator + newFileName;
                        
                        // Save file
                        part.write(filePath);
                        
                        // Determine media type
                        String mediaType = "image";
                        if (extension.toLowerCase().matches("\\.(mp4|avi|mov|wmv)")) {
                            mediaType = "video";
                        }
                        
                        // Save to database
                        RefundMedia media = new RefundMedia();
                        media.setRefundRequestID(refundRequestId);
                        media.setMediaURL("/uploads/refunds/" + newFileName);
                        media.setMediaType(mediaType);
                        refundDAO.addRefundMedia(media);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return null;
    }
}
