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

@WebServlet(urlPatterns = {"/api/goship/cities", "/api/goship/districts", "/api/goship/wards", "/api/goship/rates", "/api/goship/rates-by-address"})
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
            } else if (path.endsWith("/wards")) {
                handleGetWards(request, out);
            } else if (path.endsWith("/rates-by-address")) {
                handleGetRatesByAddress(request, out);
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
    
    private void handleGetWards(HttpServletRequest request, PrintWriter out) {
        String districtId = request.getParameter("districtId");
        
        if (districtId == null || districtId.isEmpty()) {
            JSONObject error = new JSONObject();
            error.put("success", false);
            error.put("message", "Thiếu tham số districtId");
            out.print(error.toString());
            return;
        }
        
        try {
            String apiResponse = callGoshipApi("/districts/" + districtId + "/wards", "GET", null);
            
            if (apiResponse != null) {
                JSONObject json = new JSONObject(apiResponse);
                if (json.has("data")) {
                    JSONArray wards = json.getJSONArray("data");
                    JSONObject result = new JSONObject();
                    result.put("success", true);
                    result.put("wards", wards);
                    out.print(result.toString());
                    return;
                }
            }
            
            JSONObject error = new JSONObject();
            error.put("success", false);
            error.put("message", "Không thể lấy danh sách phường/xã");
            out.print(error.toString());
            
        } catch (Exception e) {
            JSONObject error = new JSONObject();
            error.put("success", false);
            error.put("message", "Lỗi: " + e.getMessage());
            out.print(error.toString());
        }
    }
    
    /**
     * Tính phí ship từ địa chỉ text (parse tên thành phố và quận/huyện)
     */
    private void handleGetRatesByAddress(HttpServletRequest request, PrintWriter out) {
        String address = request.getParameter("address");
        String weightStr = request.getParameter("weight");
        String codStr = request.getParameter("cod");
        
        int weight = 500;
        int cod = 0;
        
        try {
            if (weightStr != null) weight = Integer.parseInt(weightStr);
            if (codStr != null) cod = Integer.parseInt(codStr);
        } catch (NumberFormatException e) {}
        
        if (address == null || address.isEmpty()) {
            JSONObject error = new JSONObject();
            error.put("success", false);
            error.put("message", "Thiếu địa chỉ giao hàng");
            out.print(error.toString());
            return;
        }
        
        try {
            // Parse address to find city and district names
            // Address format: "Street, Ward, District, City" or similar
            String[] parts = address.split(",");
            String cityName = null;
            String districtName = null;
            
            // Major cities in Vietnam (direct-controlled municipalities)
            String[] majorCities = {"hà nội", "ha noi", "hồ chí minh", "ho chi minh", "hcm", 
                "đà nẵng", "da nang", "hải phòng", "hai phong", "cần thơ", "can tho"};
            
            // Try to find city and district from address parts (from end to start)
            for (int i = parts.length - 1; i >= 0; i--) {
                String part = parts[i].trim().toLowerCase();
                String partNormalized = normalizeVietnamese(part);
                
                // Check for major cities first
                if (cityName == null) {
                    for (String city : majorCities) {
                        if (part.contains(city) || partNormalized.contains(normalizeVietnamese(city))) {
                            cityName = parts[i].trim();
                            break;
                        }
                    }
                }
                
                // Check for province/city keywords
                if (cityName == null && (part.contains("tỉnh") || part.contains("tinh") ||
                    part.contains("thành phố") || part.contains("thanh pho") || 
                    part.contains("tp.") || part.contains("tp "))) {
                    cityName = parts[i].trim();
                }
                
                // Check for district keywords
                if (districtName == null && cityName != null && !parts[i].trim().equals(cityName)) {
                    if (part.contains("quận") || part.contains("quan") ||
                        part.contains("huyện") || part.contains("huyen") ||
                        part.contains("thị xã") || part.contains("thi xa") ||
                        part.contains("thành phố") || part.contains("thanh pho")) {
                        districtName = parts[i].trim();
                    }
                }
            }
            
            // If not found by keywords, assume last part is city, second to last is district
            if (cityName == null && parts.length >= 1) {
                cityName = parts[parts.length - 1].trim();
            }
            if (districtName == null && parts.length >= 2) {
                districtName = parts[parts.length - 2].trim();
            }
            
            System.out.println("[GoshipAPI] Parsed address: " + address);
            System.out.println("[GoshipAPI] Found - City: " + cityName + ", District: " + districtName);
            
            // Find city ID
            String toCityId = findCityIdByName(cityName);
            if (toCityId == null) {
                JSONObject error = new JSONObject();
                error.put("success", false);
                error.put("message", "Không tìm thấy thành phố: " + cityName);
                out.print(error.toString());
                return;
            }
            
            // Find district ID
            String toDistrictId = findDistrictIdByName(toCityId, districtName);
            if (toDistrictId == null) {
                JSONObject error = new JSONObject();
                error.put("success", false);
                error.put("message", "Không tìm thấy quận/huyện: " + districtName);
                out.print(error.toString());
                return;
            }
            
            System.out.println("[GoshipAPI] Found IDs - CityId: " + toCityId + ", DistrictId: " + toDistrictId);
            
            // Now get rates
            getRatesInternal(toCityId, toDistrictId, weight, cod, out);
            
        } catch (Exception e) {
            e.printStackTrace();
            JSONObject error = new JSONObject();
            error.put("success", false);
            error.put("message", "Lỗi xử lý địa chỉ: " + e.getMessage());
            out.print(error.toString());
        }
    }
    
    private String findCityIdByName(String cityName) {
        if (cityName == null) return null;
        try {
            String response = callGoshipApi(GoshipConfig.ENDPOINT_CITIES, "GET", null);
            if (response != null) {
                JSONObject json = new JSONObject(response);
                if (json.has("data")) {
                    JSONArray data = json.getJSONArray("data");
                    
                    // Clean and normalize search name
                    String searchName = normalizeVietnamese(cityName.toLowerCase()
                        .replace("thành phố", "").replace("thanh pho", "")
                        .replace("tỉnh", "").replace("tinh", "")
                        .replace("tp.", "").replace("tp ", "").trim());
                    
                    System.out.println("[GoshipAPI] Searching city with normalized name: " + searchName);
                    
                    // Special mappings for district-level cities to their provinces
                    // These are cities that belong to a province, not direct municipalities
                    searchName = mapDistrictCityToProvince(searchName);
                    
                    System.out.println("[GoshipAPI] After mapping: " + searchName);
                    
                    for (int i = 0; i < data.length(); i++) {
                        JSONObject city = data.getJSONObject(i);
                        String name = normalizeVietnamese(city.optString("name", "").toLowerCase());
                        
                        if (name.contains(searchName) || searchName.contains(name)) {
                            System.out.println("[GoshipAPI] Found city match: " + city.optString("name", "") + " -> ID: " + city.optString("id", ""));
                            return city.optString("id", "");
                        }
                    }
                    
                    // Second pass: try partial match with key words
                    String[] searchWords = searchName.split("\\s+");
                    for (int i = 0; i < data.length(); i++) {
                        JSONObject city = data.getJSONObject(i);
                        String name = normalizeVietnamese(city.optString("name", "").toLowerCase());
                        
                        for (String word : searchWords) {
                            if (word.length() > 2 && name.contains(word)) {
                                System.out.println("[GoshipAPI] Found city by partial match: " + city.optString("name", "") + " -> ID: " + city.optString("id", ""));
                                return city.optString("id", "");
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Map district-level cities to their parent provinces
     * These are "Thành phố" that belong to a "Tỉnh", not direct municipalities
     */
    private String mapDistrictCityToProvince(String cityName) {
        // Huế -> Thừa Thiên Huế
        if (cityName.contains("hue")) return "thua thien hue";
        // Phủ Lý -> Hà Nam
        if (cityName.contains("phu ly")) return "ha nam";
        // Thái Bình city -> Thái Bình province
        if (cityName.equals("thai binh")) return "thai binh";
        // Nam Định city -> Nam Định province
        if (cityName.equals("nam dinh")) return "nam dinh";
        // Ninh Bình city -> Ninh Bình province
        if (cityName.equals("ninh binh")) return "ninh binh";
        // Thanh Hóa city -> Thanh Hóa province
        if (cityName.equals("thanh hoa")) return "thanh hoa";
        // Vinh -> Nghệ An
        if (cityName.contains("vinh") && !cityName.contains("binh")) return "nghe an";
        // Hạ Long -> Quảng Ninh
        if (cityName.contains("ha long")) return "quang ninh";
        // Việt Trì -> Phú Thọ
        if (cityName.contains("viet tri")) return "phu tho";
        // Thái Nguyên city -> Thái Nguyên province
        if (cityName.equals("thai nguyen")) return "thai nguyen";
        // Bắc Ninh city -> Bắc Ninh province
        if (cityName.equals("bac ninh")) return "bac ninh";
        // Hải Dương city -> Hải Dương province
        if (cityName.equals("hai duong")) return "hai duong";
        // Hưng Yên city -> Hưng Yên province
        if (cityName.equals("hung yen")) return "hung yen";
        // Vĩnh Yên -> Vĩnh Phúc
        if (cityName.contains("vinh yen")) return "vinh phuc";
        // Bắc Giang city -> Bắc Giang province
        if (cityName.equals("bac giang")) return "bac giang";
        // Lạng Sơn city -> Lạng Sơn province
        if (cityName.equals("lang son")) return "lang son";
        // Cao Bằng city -> Cao Bằng province
        if (cityName.equals("cao bang")) return "cao bang";
        // Tuyên Quang city -> Tuyên Quang province
        if (cityName.equals("tuyen quang")) return "tuyen quang";
        // Yên Bái city -> Yên Bái province
        if (cityName.equals("yen bai")) return "yen bai";
        // Lào Cai city -> Lào Cai province
        if (cityName.equals("lao cai")) return "lao cai";
        // Điện Biên Phủ -> Điện Biên
        if (cityName.contains("dien bien")) return "dien bien";
        // Sơn La city -> Sơn La province
        if (cityName.equals("son la")) return "son la";
        // Hòa Bình city -> Hòa Bình province
        if (cityName.equals("hoa binh")) return "hoa binh";
        
        return cityName;
    }
    
    private String findDistrictIdByName(String cityId, String districtName) {
        if (cityId == null || districtName == null) return null;
        try {
            String response = callGoshipApi("/cities/" + cityId + "/districts", "GET", null);
            if (response != null) {
                JSONObject json = new JSONObject(response);
                if (json.has("data")) {
                    JSONArray data = json.getJSONArray("data");
                    String searchName = normalizeVietnamese(districtName.toLowerCase()
                        .replace("quận", "").replace("huyện", "").replace("thị xã", "").trim());
                    
                    for (int i = 0; i < data.length(); i++) {
                        JSONObject district = data.getJSONObject(i);
                        String name = normalizeVietnamese(district.optString("name", "").toLowerCase());
                        if (name.contains(searchName) || searchName.contains(name)) {
                            return district.optString("id", "");
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    private String normalizeVietnamese(String str) {
        if (str == null) return "";
        return str.replaceAll("[àáạảãâầấậẩẫăằắặẳẵ]", "a")
                  .replaceAll("[èéẹẻẽêềếệểễ]", "e")
                  .replaceAll("[ìíịỉĩ]", "i")
                  .replaceAll("[òóọỏõôồốộổỗơờớợởỡ]", "o")
                  .replaceAll("[ùúụủũưừứựửữ]", "u")
                  .replaceAll("[ỳýỵỷỹ]", "y")
                  .replaceAll("[đ]", "d");
    }
    
    private void getRatesInternal(String toCityId, String toDistrictId, int weight, int cod, PrintWriter out) {
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
            error.put("message", "Không thể lấy phí vận chuyển từ Goship");
            out.print(error.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
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
