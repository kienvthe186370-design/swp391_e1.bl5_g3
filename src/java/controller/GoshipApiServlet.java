package controller;

import config.GoshipConfig;
import service.GoshipService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONArray;
import org.json.JSONObject;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;

@WebServlet(urlPatterns = {"/api/goship/cities", "/api/goship/districts", "/api/goship/rates"})
public class GoshipApiServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json; charset=UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "*");
        
        String path = request.getServletPath();
        PrintWriter out = response.getWriter();
        
        try {
            if (path.endsWith("/cities")) {
                handleGetCities(out);
            } else if (path.endsWith("/districts")) {
                handleGetDistricts(request, out);
            } else if (path.endsWith("/rates")) {
                handleGetRates(request, out);
            }
        } catch (Exception e) {
            JSONObject error = new JSONObject();
            error.put("success", false);
            error.put("message", "Server error: " + e.getMessage());
            out.print(error.toString());
        }
    }
    
    private void handleGetCities(PrintWriter out) {
        try {
            String apiResponse = callGoshipApi(GoshipConfig.ENDPOINT_CITIES, "GET", null);
            
            if (apiResponse != null) {
                JSONObject json = new JSONObject(apiResponse);
                if (json.has("data")) {
                    JSONArray cities = json.getJSONArray("data");
                    JSONObject result = new JSONObject();
                    result.put("success", true);
                    result.put("cities", cities);
                    out.print(result.toString());
                    return;
                }
            }
            
            JSONObject error = new JSONObject();
            error.put("success", false);
            error.put("message", "Không thể lấy danh sách thành phố");
            out.print(error.toString());
            
        } catch (Exception e) {
            JSONObject error = new JSONObject();
            error.put("success", false);
            error.put("message", "Lỗi: " + e.getMessage());
            out.print(error.toString());
        }
    }
    
    private void handleGetDistricts(HttpServletRequest request, PrintWriter out) {
        String cityId = request.getParameter("cityId");
        
        if (cityId == null || cityId.isEmpty()) {
            JSONObject error = new JSONObject();
            error.put("success", false);
            error.put("message", "Thiếu tham số cityId");
            out.print(error.toString());
            return;
        }
        
        try {
            String apiResponse = callGoshipApi("/cities/" + cityId + "/districts", "GET", null);
            
            if (apiResponse != null) {
                JSONObject json = new JSONObject(apiResponse);
                if (json.has("data")) {
                    JSONArray districts = json.getJSONArray("data");
                    JSONObject result = new JSONObject();
                    result.put("success", true);
                    result.put("districts", districts);
                    out.print(result.toString());
                    return;
                }
            }
            
            JSONObject error = new JSONObject();
            error.put("success", false);
            error.put("message", "Không thể lấy danh sách quận/huyện");
            out.print(error.toString());
            
        } catch (Exception e) {
            JSONObject error = new JSONObject();
            error.put("success", false);
            error.put("message", "Lỗi: " + e.getMessage());
            out.print(error.toString());
        }
    }
    
    private void handleGetRates(HttpServletRequest request, PrintWriter out) {
        String toCityId = request.getParameter("toCityId");
        String toDistrictId = request.getParameter("toDistrictId");
        String weightStr = request.getParameter("weight");
        String codStr = request.getParameter("cod");
        
        int weight = 500;
        int cod = 0;
        
        try {
            if (weightStr != null) weight = Integer.parseInt(weightStr);
            if (codStr != null) cod = Integer.parseInt(codStr);
        } catch (NumberFormatException e) {}
        
        try {
            String fromCityId = getHanoiCityId();
            String fromDistrictId = getThachThatDistrictId(fromCityId);
            
            if (fromCityId == null || fromDistrictId == null) {
                JSONObject error = new JSONObject();
                error.put("success", false);
                error.put("message", "Không thể lấy mã địa chỉ gửi");
                out.print(error.toString());
                return;
            }
            
            JSONObject requestBody = new JSONObject();
            JSONObject shipment = new JSONObject();
            
            JSONObject addressFrom = new JSONObject();
            addressFrom.put("city", fromCityId);
            addressFrom.put("district", fromDistrictId);
            
            JSONObject addressTo = new JSONObject();
            addressTo.put("city", toCityId);
            addressTo.put("district", toDistrictId);
            
            JSONObject parcel = new JSONObject();
            parcel.put("cod", cod);
            parcel.put("weight", weight);
            parcel.put("width", 20);
            parcel.put("height", 10);
            parcel.put("length", 30);
            
            shipment.put("address_from", addressFrom);
            shipment.put("address_to", addressTo);
            shipment.put("parcel", parcel);
            requestBody.put("shipment", shipment);
            
            String apiResponse = callGoshipApi(GoshipConfig.ENDPOINT_RATES, "POST", requestBody.toString());
            
            if (apiResponse != null) {
                JSONObject json = new JSONObject(apiResponse);
                if (json.has("data")) {
                    JSONArray data = json.getJSONArray("data");
                    JSONArray rates = new JSONArray();
                    
                    for (int i = 0; i < data.length(); i++) {
                        JSONObject item = data.getJSONObject(i);
                        JSONObject rate = new JSONObject();
                        rate.put("id", item.optString("id", ""));
                        rate.put("carrierName", item.optString("carrier_name", ""));
                        rate.put("carrierLogo", item.optString("carrier_logo", ""));
                        rate.put("serviceName", item.optString("service", ""));
                        
                        long totalFee = item.optLong("total_fee", 0);
                        if (totalFee == 0) totalFee = item.optLong("fee", 30000);
                        rate.put("price", totalFee);
                        rate.put("estimatedDelivery", item.optString("expected", "2-3 ngày"));
                        
                        rates.put(rate);
                    }
                    
                    JSONObject result = new JSONObject();
                    result.put("success", true);
                    result.put("rates", rates);
                    out.print(result.toString());
                    return;
                }
            }
            
            JSONObject error = new JSONObject();
            error.put("success", false);
            error.put("message", "Không thể lấy phí vận chuyển");
            out.print(error.toString());
            
        } catch (Exception e) {
            JSONObject error = new JSONObject();
            error.put("success", false);
            error.put("message", "Lỗi: " + e.getMessage());
            out.print(error.toString());
        }
    }
    
    private String getHanoiCityId() {
        try {
            String response = callGoshipApi(GoshipConfig.ENDPOINT_CITIES, "GET", null);
            if (response != null) {
                JSONObject json = new JSONObject(response);
                if (json.has("data")) {
                    JSONArray data = json.getJSONArray("data");
                    for (int i = 0; i < data.length(); i++) {
                        JSONObject city = data.getJSONObject(i);
                        String name = city.optString("name", "").toLowerCase();
                        if (name.contains("hà nội") || name.contains("ha noi")) {
                            return city.optString("id", "");
                        }
                    }
                }
            }
        } catch (Exception e) {}
        return null;
    }
    
    private String getThachThatDistrictId(String cityId) {
        if (cityId == null) return null;
        try {
            String response = callGoshipApi("/cities/" + cityId + "/districts", "GET", null);
            if (response != null) {
                JSONObject json = new JSONObject(response);
                if (json.has("data")) {
                    JSONArray data = json.getJSONArray("data");
                    for (int i = 0; i < data.length(); i++) {
                        JSONObject district = data.getJSONObject(i);
                        String name = district.optString("name", "").toLowerCase();
                        if (name.contains("thạch thất") || name.contains("thach that")) {
                            return district.optString("id", "");
                        }
                    }
                }
            }
        } catch (Exception e) {}
        return null;
    }
    
    private String callGoshipApi(String endpoint, String method, String body) {
        HttpURLConnection conn = null;
        try {
            URL url = new URL(GoshipConfig.API_URL + endpoint);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod(method);
            conn.setRequestProperty("Authorization", "Bearer " + GoshipConfig.TOKEN);
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setRequestProperty("Accept", "application/json");
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(5000);
            
            if (body != null && !body.isEmpty()) {
                conn.setDoOutput(true);
                try (OutputStream os = conn.getOutputStream()) {
                    os.write(body.getBytes("UTF-8"));
                }
            }
            
            int responseCode = conn.getResponseCode();
            InputStream is = responseCode >= 400 ? conn.getErrorStream() : conn.getInputStream();
            if (is == null) return null;
            
            BufferedReader br = new BufferedReader(new InputStreamReader(is, "UTF-8"));
            StringBuilder response = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                response.append(line);
            }
            br.close();
            
            return response.toString();
        } catch (Exception e) {
            return null;
        } finally {
            if (conn != null) conn.disconnect();
        }
    }
}
