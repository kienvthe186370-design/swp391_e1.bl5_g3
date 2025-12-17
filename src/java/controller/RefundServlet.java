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
    maxFileSize = 1024 * 1024 * 10,      // 10 MB
    maxRequestSize = 1024 * 1024 * 60    // 60 MB (cho phép 5 file x 10MB + overhead)
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
     * FinalPrice trong OrderDetail là đơn giá (unit price), không phải tổng
     */
    private BigDecimal calculateRefundAmount(Order order, String[] itemIds, String[] quantities) {
        if (itemIds == null || itemIds.length == 0) {
            // Hoàn toàn bộ đơn hàng
            return order.getTotalAmount();
        }
        
        BigDecimal total = BigDecimal.ZERO;
        List<OrderDetail> details = order.getOrderDetails();
        
        System.out.println("[RefundServlet] calculateRefundAmount - itemIds: " + java.util.Arrays.toString(itemIds));
        System.out.println("[RefundServlet] calculateRefundAmount - quantities: " + java.util.Arrays.toString(quantities));
        
        for (int i = 0; i < itemIds.length; i++) {
            int detailId = Integer.parseInt(itemIds[i]);
            int qty = Integer.parseInt(quantities[i]);
            
            for (OrderDetail detail : details) {
                if (detail.getOrderDetailID() == detailId) {
                    // FinalPrice là đơn giá, nhân với số lượng hoàn để ra tổng tiền hoàn cho item này
                    BigDecimal unitPrice = detail.getFinalPrice();
                    BigDecimal itemTotal = unitPrice.multiply(BigDecimal.valueOf(qty));
                    
                    System.out.println("[RefundServlet] Item " + detailId + ": unitPrice=" + unitPrice + 
                                     ", qty=" + qty + ", itemTotal=" + itemTotal);
                    
                    total = total.add(itemTotal);
                    break;
                }
            }
        }
        
        System.out.println("[RefundServlet] Total refund amount: " + total);
        return total;
    }

    /**
     * Upload hình ảnh/video minh chứng
     */
    private void uploadRefundMedia(HttpServletRequest request, int refundRequestId) {
        try {
            System.out.println("[RefundServlet] Starting uploadRefundMedia for refundRequestId: " + refundRequestId);
            
            String uploadPath = getServletContext().getRealPath("/uploads/refunds");
            System.out.println("[RefundServlet] Upload path: " + uploadPath);
            
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                boolean created = uploadDir.mkdirs();
                System.out.println("[RefundServlet] Created upload directory: " + created);
            }
            
            long MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
            int fileCount = 0;
            int MAX_FILES = 5;
            
            System.out.println("[RefundServlet] Total parts in request: " + request.getParts().size());
            
            for (Part part : request.getParts()) {
                System.out.println("[RefundServlet] Part name: " + part.getName() + ", size: " + part.getSize() + ", contentType: " + part.getContentType());
                
                if (part.getName().equals("mediaFiles") && part.getSize() > 0) {
                    // Validate số lượng file
                    if (fileCount >= MAX_FILES) {
                        System.out.println("[RefundServlet] Exceeded max files limit: " + MAX_FILES);
                        break;
                    }
                    
                    // Validate dung lượng file
                    if (part.getSize() > MAX_FILE_SIZE) {
                        System.out.println("[RefundServlet] File too large: " + part.getSize() + " bytes, max: " + MAX_FILE_SIZE);
                        continue;
                    }
                    
                    String fileName = getFileName(part);
                    System.out.println("[RefundServlet] Extracted filename: " + fileName);
                    
                    if (fileName != null && !fileName.isEmpty()) {
                        // Validate định dạng file
                        String extension = fileName.substring(fileName.lastIndexOf(".")).toLowerCase();
                        if (!extension.matches("\\.(jpg|jpeg|png|gif|mp4|mov|avi)")) {
                            System.out.println("[RefundServlet] Invalid file type: " + extension);
                            continue;
                        }
                        System.out.println("[RefundServlet] Processing file: " + fileName + ", size: " + part.getSize());
                        
                        // Generate unique filename
                        String newFileName = UUID.randomUUID().toString() + extension;
                        String filePath = uploadPath + File.separator + newFileName;
                        
                        // Save file using InputStream instead of part.write()
                        try (InputStream input = part.getInputStream();
                             FileOutputStream output = new FileOutputStream(filePath)) {
                            byte[] buffer = new byte[8192];
                            int bytesRead;
                            while ((bytesRead = input.read(buffer)) != -1) {
                                output.write(buffer, 0, bytesRead);
                            }
                        }
                        
                        File savedFile = new File(filePath);
                        System.out.println("[RefundServlet] File saved: " + savedFile.exists() + ", size: " + savedFile.length());
                        
                        fileCount++;
                        
                        // Determine media type
                        String mediaType = "image";
                        String extLower = extension.toLowerCase();
                        if (extLower.equals(".mp4") || extLower.equals(".avi") || extLower.equals(".mov") || extLower.equals(".wmv")) {
                            mediaType = "video";
                        }
                        
                        // Save to database
                        RefundMedia media = new RefundMedia();
                        media.setRefundRequestID(refundRequestId);
                        media.setMediaURL("/uploads/refunds/" + newFileName);
                        media.setMediaType(mediaType);
                        boolean saved = refundDAO.addRefundMedia(media);
                        System.out.println("[RefundServlet] Media saved to DB: " + saved + ", URL: " + media.getMediaURL() + ", Type: " + mediaType);
                    }
                }
            }
            System.out.println("[RefundServlet] Total files uploaded: " + fileCount);
        } catch (Exception e) {
            System.out.println("[RefundServlet] Error uploading media: " + e.getMessage());
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
