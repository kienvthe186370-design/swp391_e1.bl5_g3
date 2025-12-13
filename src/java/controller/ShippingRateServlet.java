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

@WebServlet(name = "ShippingRateServlet", urlPatterns = {"/api/shipping-rates"})
public class ShippingRateServlet extends HttpServlet {
    private GoshipService goshipService = new GoshipService();
    private CustomerAddressDAO addressDAO = new CustomerAddressDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
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
