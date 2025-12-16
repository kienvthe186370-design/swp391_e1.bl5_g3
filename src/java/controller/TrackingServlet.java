package controller;

import DAO.OrderDAO;
import DAO.ShippingDAO;
import DAO.ShippingTrackingDAO;
import entity.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * Servlet xử lý xem tracking từ database nội bộ
 */
@WebServlet(name = "TrackingServlet", urlPatterns = {"/tracking", "/customer/tracking"})
public class TrackingServlet extends HttpServlet {
    
    private OrderDAO orderDAO;
    private ShippingDAO shippingDAO;
    private ShippingTrackingDAO trackingDAO;
    
    @Override
    public void init() throws ServletException {
        orderDAO = new OrderDAO();
        shippingDAO = new ShippingDAO();
        trackingDAO = new ShippingTrackingDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        String trackingCode = request.getParameter("code");
        String orderIdParam = request.getParameter("orderId");
        
        Order order = null;
        Shipping shipping = null;
        List<ShippingTracking> trackingHistory = null;
        
        // Tìm theo orderId
        if (orderIdParam != null && !orderIdParam.isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdParam);
                
                // Kiểm tra quyền (customer chỉ xem được đơn của mình)
                HttpSession session = request.getSession();
                Customer customer = (Customer) session.getAttribute("customer");
                
                order = orderDAO.getOrderById(orderId);
                if (order != null) {
                    if (customer != null && order.getCustomerID() != customer.getCustomerID()) {
                        request.setAttribute("error", "Bạn không có quyền xem đơn hàng này");
                        request.getRequestDispatcher("/customer/tracking.jsp").forward(request, response);
                        return;
                    }
                    
                    shipping = order.getShipping();
                    if (shipping != null) {
                        trackingCode = shipping.getTrackingCode();
                        trackingHistory = trackingDAO.getTrackingHistory(shipping.getShippingID());
                    }
                }
            } catch (NumberFormatException e) {
                // ignore
            }
        }
        
        // Tìm theo tracking code
        if (trackingCode != null && !trackingCode.isEmpty() && !"NULL".equalsIgnoreCase(trackingCode)) {
            if (shipping == null) {
                // Tìm shipping theo tracking code
                shipping = findShippingByTrackingCode(trackingCode);
                if (shipping != null) {
                    order = orderDAO.getOrderById(shipping.getOrderID());
                    trackingHistory = trackingDAO.getTrackingHistory(shipping.getShippingID());
                }
            }
        }
        
        if (trackingCode == null || trackingCode.isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập mã vận đơn");
            request.getRequestDispatcher("/customer/tracking.jsp").forward(request, response);
            return;
        }
        
        // Tạo tracking result object cho JSP
        TrackingResult result = new TrackingResult();
        result.setTrackingCode(trackingCode);
        
        if (shipping != null && trackingHistory != null && !trackingHistory.isEmpty()) {
            result.setSuccess(true);
            
            // Lấy trạng thái mới nhất
            ShippingTracking latest = trackingHistory.get(0);
            result.setStatus(latest.getStatusCode());
            result.setStatusText(ShippingTracking.getVietnameseName(latest.getStatusCode()));
            result.setLastUpdate(latest.getCreatedAt());
            
            // Thông tin shipper
            if (shipping.getShipper() != null) {
                result.setShipperName(shipping.getShipper().getFullName());
                result.setShipperPhone(shipping.getShipper().getPhone());
            } else {
                // Load shipper info
                Shipping fullShipping = shippingDAO.getShippingWithShipper(shipping.getShippingID());
                if (fullShipping != null && fullShipping.getShipper() != null) {
                    result.setShipperName(fullShipping.getShipper().getFullName());
                    result.setShipperPhone(fullShipping.getShipper().getPhone());
                }
            }
            
            // Thông tin người nhận từ order
            if (order != null && order.getAddress() != null) {
                CustomerAddress addr = order.getAddress();
                result.setRecipientName(addr.getRecipientName());
                result.setRecipientPhone(addr.getPhone());
                result.setRecipientAddress(addr.getStreet() + ", " + addr.getWard() + ", " + 
                                          addr.getDistrict() + ", " + addr.getCity());
            }
            
            result.setTrackingEvents(trackingHistory);
        } else {
            result.setSuccess(false);
            result.setMessage("Không tìm thấy thông tin vận đơn với mã: " + trackingCode);
        }
        
        request.setAttribute("tracking", result);
        request.setAttribute("trackingCode", trackingCode);
        request.setAttribute("order", order);
        
        request.getRequestDispatcher("/customer/tracking.jsp").forward(request, response);
    }
    
    /**
     * Tìm shipping theo tracking code
     */
    private Shipping findShippingByTrackingCode(String trackingCode) {
        String sql = "SELECT ShippingID, OrderID FROM Shipping WHERE TrackingCode = ?";
        try (java.sql.Connection conn = new DAO.DBContext().getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, trackingCode);
            java.sql.ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                Shipping shipping = new Shipping();
                shipping.setShippingID(rs.getInt("ShippingID"));
                shipping.setOrderID(rs.getInt("OrderID"));
                shipping.setTrackingCode(trackingCode);
                return shipping;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Inner class để truyền dữ liệu tracking cho JSP
     */
    public static class TrackingResult {
        private boolean success;
        private String message;
        private String trackingCode;
        private String status;
        private String statusText;
        private java.sql.Timestamp lastUpdate;
        private String shipperName;
        private String shipperPhone;
        private String recipientName;
        private String recipientPhone;
        private String recipientAddress;
        private List<ShippingTracking> trackingEvents;
        
        // Getters and Setters
        public boolean isSuccess() { return success; }
        public void setSuccess(boolean success) { this.success = success; }
        
        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
        
        public String getTrackingCode() { return trackingCode; }
        public void setTrackingCode(String trackingCode) { this.trackingCode = trackingCode; }
        
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
        
        public String getStatusText() { return statusText; }
        public void setStatusText(String statusText) { this.statusText = statusText; }
        
        public java.sql.Timestamp getLastUpdate() { return lastUpdate; }
        public void setLastUpdate(java.sql.Timestamp lastUpdate) { this.lastUpdate = lastUpdate; }
        
        public String getShipperName() { return shipperName; }
        public void setShipperName(String shipperName) { this.shipperName = shipperName; }
        
        public String getShipperPhone() { return shipperPhone; }
        public void setShipperPhone(String shipperPhone) { this.shipperPhone = shipperPhone; }
        
        public String getRecipientName() { return recipientName; }
        public void setRecipientName(String recipientName) { this.recipientName = recipientName; }
        
        public String getRecipientPhone() { return recipientPhone; }
        public void setRecipientPhone(String recipientPhone) { this.recipientPhone = recipientPhone; }
        
        public String getRecipientAddress() { return recipientAddress; }
        public void setRecipientAddress(String recipientAddress) { this.recipientAddress = recipientAddress; }
        
        public List<ShippingTracking> getTrackingEvents() { return trackingEvents; }
        public void setTrackingEvents(List<ShippingTracking> trackingEvents) { this.trackingEvents = trackingEvents; }
    }
}
