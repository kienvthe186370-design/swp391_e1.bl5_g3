package controller;

import DAO.OrderDAO;
import DAO.ShippingDAO;
import entity.Order;
import entity.Shipping;
import config.GoshipConfig;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;
import java.io.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Webhook handler để nhận cập nhật trạng thái từ Goship
 * URL: /api/goship/webhook
 * 
 * Goship sẽ gọi webhook này khi trạng thái vận đơn thay đổi
 */
@WebServlet(name = "GoshipWebhookServlet", urlPatterns = {"/api/goship/webhook"})
public class GoshipWebhookServlet extends HttpServlet {
    
    private static final Logger LOGGER = Logger.getLogger(GoshipWebhookServlet.class.getName());
    private OrderDAO orderDAO;
    private ShippingDAO shippingDAO;
    
    @Override
    public void init() throws ServletException {
        orderDAO = new OrderDAO();
        shippingDAO = new ShippingDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            // Đọc request body
            StringBuilder sb = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
            String requestBody = sb.toString();
            
            LOGGER.info("[GoshipWebhook] Received: " + requestBody);
            
            if (requestBody.isEmpty()) {
                sendResponse(out, false, "Empty request body");
                return;
            }
            
            JSONObject json = new JSONObject(requestBody);
            
            // Goship webhook format:
            // {
            //   "event": "shipment.status_changed",
            //   "data": {
            //     "code": "GOSHIP_ORDER_CODE",
            //     "tracking_number": "TRACKING_CODE",
            //     "status": "picking|picked|delivering|delivered|return|cancelled",
            //     "status_text": "Đang lấy hàng",
            //     "cod_amount": 0,
            //     "updated_at": "2024-01-01 12:00:00"
            //   }
            // }
            
            String event = json.optString("event", "");
            
            if (!"shipment.status_changed".equals(event)) {
                LOGGER.info("[GoshipWebhook] Ignoring event: " + event);
                sendResponse(out, true, "Event ignored");
                return;
            }
            
            JSONObject data = json.optJSONObject("data");
            if (data == null) {
                sendResponse(out, false, "Missing data");
                return;
            }
            
            String goshipOrderCode = data.optString("code", "");
            String trackingCode = data.optString("tracking_number", "");
            String goshipStatus = data.optString("status", "");
            String statusText = data.optString("status_text", "");
            
            LOGGER.info("[GoshipWebhook] Processing: code=" + goshipOrderCode + 
                       ", status=" + goshipStatus + ", tracking=" + trackingCode);
            
            // Tìm đơn hàng theo goship order code
            Order order = orderDAO.getOrderByGoshipCode(goshipOrderCode);
            
            if (order == null) {
                LOGGER.warning("[GoshipWebhook] Order not found for goship code: " + goshipOrderCode);
                sendResponse(out, false, "Order not found");
                return;
            }
            
            // Cập nhật trạng thái shipping
            updateShippingStatus(order.getOrderID(), goshipStatus, trackingCode);
            
            // Map Goship status sang Order status
            String newOrderStatus = mapGoshipStatusToOrderStatus(goshipStatus);
            
            if (newOrderStatus != null && !newOrderStatus.equals(order.getOrderStatus())) {
                // Cập nhật trạng thái đơn hàng
                String note = "Cập nhật từ Goship: " + statusText;
                orderDAO.updateOrderStatus(order.getOrderID(), newOrderStatus, null, note);
                LOGGER.info("[GoshipWebhook] Updated order " + order.getOrderCode() + 
                           " status to: " + newOrderStatus);
            }
            
            sendResponse(out, true, "Webhook processed successfully");
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "[GoshipWebhook] Error processing webhook", e);
            sendResponse(out, false, "Error: " + e.getMessage());
        }
    }
    
    /**
     * Map trạng thái Goship sang trạng thái đơn hàng
     */
    private String mapGoshipStatusToOrderStatus(String goshipStatus) {
        if (goshipStatus == null) return null;
        
        switch (goshipStatus.toLowerCase()) {
            case "picking":
            case "picked":
                return "Shipping"; // Đang giao
            case "delivering":
                return "Shipping"; // Đang giao
            case "delivered":
                return "Delivered"; // Đã giao
            case "return":
            case "returned":
                return "Cancelled"; // Hoàn hàng -> Hủy
            case "cancelled":
                return "Cancelled"; // Đã hủy
            default:
                return null; // Không thay đổi
        }
    }
    
    /**
     * Cập nhật thông tin shipping trong database
     */
    private void updateShippingStatus(int orderID, String goshipStatus, String trackingCode) {
        try {
            Shipping shipping = shippingDAO.getShippingByOrderId(orderID);
            if (shipping != null) {
                // Cập nhật goship status
                shippingDAO.updateGoshipStatus(shipping.getShippingID(), goshipStatus);
                
                // Cập nhật tracking code nếu có
                if (trackingCode != null && !trackingCode.isEmpty() && 
                    (shipping.getTrackingCode() == null || shipping.getTrackingCode().isEmpty())) {
                    shippingDAO.updateTrackingCode(shipping.getShippingID(), trackingCode);
                }
                
                // Cập nhật ngày giao nếu đã delivered
                if ("delivered".equalsIgnoreCase(goshipStatus)) {
                    shippingDAO.updateDeliveredDate(shipping.getShippingID());
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "[GoshipWebhook] Error updating shipping status", e);
        }
    }
    
    private void sendResponse(PrintWriter out, boolean success, String message) {
        JSONObject response = new JSONObject();
        response.put("success", success);
        response.put("message", message);
        out.print(response.toString());
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // GET request để test webhook endpoint
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        JSONObject result = new JSONObject();
        result.put("status", "ok");
        result.put("message", "Goship Webhook endpoint is active");
        result.put("usage", "POST shipment status updates to this endpoint");
        out.print(result.toString());
    }
}
