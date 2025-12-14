package controller;


import DAO.CustomerAddressDAO;
import config.GoshipConfig;
import entity.CustomerAddress;
import entity.ShippingRate;
import service.GoshipService;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONObject;

@WebServlet(name = "ShippingRateServlet", urlPatterns = {"/api/shipping-rates", "/api/shipping/rates"})
public class ShippingRateServlet extends HttpServlet {
    private GoshipService goshipService = new GoshipService();
    private CustomerAddressDAO addressDAO = new CustomerAddressDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String path = request.getServletPath();
        
        // API mới: /api/shipping/rates?toCity=xxx&toDistrict=yyy
        if (path.equals("/api/shipping/rates")) {
            handleGetRatesByName(request, response);
        } else {
            // API cũ: /api/shipping-rates?addressId=xxx
            handleGetRatesByAddressId(request, response);
        }
    }
    
    /**
     * Lấy rates theo tên thành phố/quận (dùng cho admin order detail)
     */
    private void handleGetRatesByName(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        JSONObject json = new JSONObject();
        
        try {
            String toCity = request.getParameter("toCity");
            String toDistrict = request.getParameter("toDistrict");
            int weight = 500;
            
            try {
                String weightStr = request.getParameter("weight");
                if (weightStr != null) weight = Integer.parseInt(weightStr);
            } catch (NumberFormatException e) {}
            
            if (toCity == null || toDistrict == null) {
                json.put("success", false);
                json.put("message", "Thiếu tham số toCity hoặc toDistrict");
                response.getWriter().write(json.toString());
                return;
            }
            
            // Lấy rates từ Goship
            List<ShippingRate> rates = goshipService.getShippingRates(
                GoshipConfig.SHOP_CITY, GoshipConfig.SHOP_DISTRICT,
                toCity, toDistrict, weight
            );
            
            JSONArray ratesArray = new JSONArray();
            for (ShippingRate rate : rates) {
                JSONObject rateJson = new JSONObject();
                rateJson.put("id", rate.getCarrierId() != null ? rate.getCarrierId() : rate.getRateId());
                rateJson.put("carrierId", rate.getCarrierId());
                rateJson.put("carrierName", rate.getCarrierName());
                rateJson.put("carrierShortName", rate.getCarrierShortName());
                rateJson.put("serviceName", rate.getServiceName());
                rateJson.put("price", rate.getBasePrice());
                rateJson.put("basePrice", rate.getBasePrice());
                rateJson.put("estimatedDelivery", rate.getEstimatedDelivery());
                rateJson.put("carrierLogo", rate.getCarrierLogo());
                ratesArray.put(rateJson);
            }
            
            json.put("success", true);
            json.put("rates", ratesArray);
            
        } catch (Exception e) {
            e.printStackTrace();
            json.put("success", false);
            json.put("message", "Lỗi: " + e.getMessage());
        }
        
        response.getWriter().write(json.toString());
    }
    
    /**
     * Lấy rates theo addressId (dùng cho checkout)
     */
    private void handleGetRatesByAddressId(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        JSONObject json = new JSONObject();
        
        try {
            int addressId = Integer.parseInt(request.getParameter("addressId"));
            CustomerAddress address = addressDAO.getAddressById(addressId);
            
            if (address == null) {
                json.put("success", false);
                json.put("message", "Địa chỉ không tồn tại");
                response.getWriter().write(json.toString());
                return;
            }
            
            // Sử dụng địa chỉ shop từ config
            List<ShippingRate> rates = goshipService.getShippingRates(
                GoshipConfig.SHOP_CITY, GoshipConfig.SHOP_DISTRICT,
                address.getCity(), address.getDistrict(), 500
            );
            
            JSONArray ratesArray = new JSONArray();
            for (ShippingRate rate : rates) {
                JSONObject rateJson = new JSONObject();
                rateJson.put("rateId", rate.getRateId());
                rateJson.put("carrierId", rate.getCarrierId());
                rateJson.put("carrierName", rate.getCarrierName());
                rateJson.put("carrierShortName", rate.getCarrierShortName());
                rateJson.put("serviceName", rate.getServiceName());
                rateJson.put("price", rate.getBasePrice());
                rateJson.put("estimatedDelivery", rate.getEstimatedDelivery());
                rateJson.put("carrierLogo", rate.getCarrierLogo());
                ratesArray.put(rateJson);
            }
            
            json.put("success", true);
            json.put("rates", ratesArray);
            
        } catch (NumberFormatException e) {
            json.put("success", false);
            json.put("message", "addressId không hợp lệ");
        } catch (Exception e) {
            e.printStackTrace();
            json.put("success", false);
            json.put("message", "Lỗi: " + e.getMessage());
        }
        
        response.getWriter().write(json.toString());
    }
}
