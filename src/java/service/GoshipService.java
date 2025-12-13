package service;

import config.GoshipConfig;
import entity.ShippingRate;
import org.json.JSONArray;
import org.json.JSONObject;
import java.io.*;
import java.math.BigDecimal;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

public class GoshipService {
    
    // Cache city codes để không gọi API nhiều lần
    private static java.util.Map<String, String> cityCodeCache = new java.util.concurrent.ConcurrentHashMap<>();
    private static java.util.Map<String, String> districtCodeCache = new java.util.concurrent.ConcurrentHashMap<>();
    private static volatile boolean apiAvailable = true;
    private static long lastApiCheck = 0;
    
    public String getAccessToken() {
        return GoshipConfig.TOKEN;
    }

    public List<ShippingRate> getShippingRates(String fromCity, String fromDistrict, 
                                                String toCity, String toDistrict, int weight) {
        List<ShippingRate> rates = new ArrayList<>();
        
        // Quick fail nếu API đã bị lỗi gần đây (trong 5 phút)
        if (!apiAvailable && (System.currentTimeMillis() - lastApiCheck) < 300000) {
            System.out.println("[GoshipService] API unavailable, using default rates");
            return getDefaultRates();
        }
        
        try {
            String fromCityCode = getCityCodeCached(fromCity);
            if (fromCityCode == null) {
                markApiUnavailable();
                return getDefaultRates();
            }
            
            String fromDistrictCode = getDistrictCodeCached(fromCityCode, fromDistrict);
            String toCityCode = getCityCodeCached(toCity);
            String toDistrictCode = toCityCode != null ? getDistrictCodeCached(toCityCode, toDistrict) : null;
            
            System.out.println("[GoshipService] From: " + fromCity + " -> " + fromCityCode + "/" + fromDistrictCode);
            System.out.println("[GoshipService] To: " + toCity + " -> " + toCityCode + "/" + toDistrictCode);
            
            if (fromDistrictCode == null || toDistrictCode == null) {
                System.out.println("[GoshipService] Cannot get district codes, using default rates");
                return getDefaultRates();
            }
            
            // Mark API as available
            apiAvailable = true;
            
            JSONObject requestBody = new JSONObject();
            JSONObject shipment = new JSONObject();
            
            JSONObject addressFrom = new JSONObject();
            addressFrom.put("city", fromCityCode);
            addressFrom.put("district", fromDistrictCode);
            
            JSONObject addressTo = new JSONObject();
            addressTo.put("city", toCityCode);
            addressTo.put("district", toDistrictCode);
            
            JSONObject parcel = new JSONObject();
            parcel.put("cod", 0);
            parcel.put("weight", weight);
            parcel.put("width", 20);
            parcel.put("height", 10);
            parcel.put("length", 30);

            
            shipment.put("address_from", addressFrom);
            shipment.put("address_to", addressTo);
            shipment.put("parcel", parcel);
            requestBody.put("shipment", shipment);

            String response = callApi(GoshipConfig.ENDPOINT_RATES, "POST", requestBody.toString());
            
            if (response != null) {
                JSONObject json = new JSONObject(response);
                if (json.has("data")) {
                    JSONArray data = json.getJSONArray("data");
                    for (int i = 0; i < data.length(); i++) {
                        JSONObject item = data.getJSONObject(i);
                        ShippingRate rate = new ShippingRate();
                        rate.setRateId(i + 1);
                        rate.setCarrierName(item.optString("carrier_name", ""));
                        rate.setCarrierShortName(item.optString("carrier_short_name", ""));
                        rate.setCarrierLogo(item.optString("carrier_logo", ""));
                        rate.setServiceName(item.optString("service", ""));
                        
                        long totalFee = item.optLong("total_fee", 0);
                        if (totalFee == 0) {
                            totalFee = item.optLong("fee", 30000);
                        }
                        rate.setBasePrice(BigDecimal.valueOf(totalFee));
                        rate.setEstimatedDelivery(item.optString("expected", "2-3 ngày"));
                        rate.setActive(true);
                        rate.setCarrierId(item.optString("id", ""));
                        
                        rates.add(rate);
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("[GoshipService] Error getting rates: " + e.getMessage());
            e.printStackTrace();
        }
        
        if (rates.isEmpty()) {
            return getDefaultRates();
        }
        return rates;
    }

    private void markApiUnavailable() {
        apiAvailable = false;
        lastApiCheck = System.currentTimeMillis();
        System.out.println("[GoshipService] Marked API as unavailable for 5 minutes");
    }
    
    private String getCityCodeCached(String cityName) {
        // Check cache first
        String cached = cityCodeCache.get(cityName.toLowerCase());
        if (cached != null) {
            return cached;
        }
        
        String code = getCityCode(cityName);
        if (code != null) {
            cityCodeCache.put(cityName.toLowerCase(), code);
        }
        return code;
    }
    
    private String getDistrictCodeCached(String cityCode, String districtName) {
        String cacheKey = cityCode + "_" + districtName.toLowerCase();
        String cached = districtCodeCache.get(cacheKey);
        if (cached != null) {
            return cached;
        }
        
        String code = getDistrictCode(cityCode, districtName);
        if (code != null) {
            districtCodeCache.put(cacheKey, code);
        }
        return code;
    }

    private String getCityCode(String cityName) {
        try {
            String response = callApi(GoshipConfig.ENDPOINT_CITIES, "GET", null);
            if (response != null) {
                JSONObject json = new JSONObject(response);
                if (json.has("data")) {
                    JSONArray data = json.getJSONArray("data");
                    for (int i = 0; i < data.length(); i++) {
                        JSONObject city = data.getJSONObject(i);
                        String name = city.optString("name", "");
                        if (name.toLowerCase().contains(cityName.toLowerCase()) ||
                            cityName.toLowerCase().contains(name.toLowerCase())) {
                            return city.optString("id", "");
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("[GoshipService] Error getting city code: " + e.getMessage());
        }
        return null;
    }

    private String getDistrictCode(String cityCode, String districtName) {
        if (cityCode == null || cityCode.isEmpty()) return null;
        try {
            String response = callApi("/cities/" + cityCode + "/districts", "GET", null);
            if (response != null) {
                JSONObject json = new JSONObject(response);
                if (json.has("data")) {
                    JSONArray data = json.getJSONArray("data");
                    for (int i = 0; i < data.length(); i++) {
                        JSONObject district = data.getJSONObject(i);
                        String name = district.optString("name", "");
                        if (name.toLowerCase().contains(districtName.toLowerCase()) ||
                            districtName.toLowerCase().contains(name.toLowerCase())) {
                            return district.optString("id", "");
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("[GoshipService] Error getting district code: " + e.getMessage());
        }
        return null;
    }


    private String callApi(String endpoint, String method, String body) {
        HttpURLConnection conn = null;
        try {
            URL url = new URL(GoshipConfig.API_URL + endpoint);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod(method);
            conn.setRequestProperty("Authorization", "Bearer " + GoshipConfig.TOKEN);
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setRequestProperty("Accept", "application/json");
            // Giảm timeout xuống 3 giây để fail nhanh
            conn.setConnectTimeout(3000);
            conn.setReadTimeout(3000);
            
            if (body != null && !body.isEmpty()) {
                conn.setDoOutput(true);
                try (OutputStream os = conn.getOutputStream()) {
                    os.write(body.getBytes("UTF-8"));
                }
            }
            
            int responseCode = conn.getResponseCode();
            System.out.println("[GoshipService] API " + endpoint + " -> " + responseCode);
            
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
        } catch (java.net.SocketTimeoutException e) {
            System.err.println("[GoshipService] API timeout: " + endpoint);
        } catch (java.net.ConnectException e) {
            System.err.println("[GoshipService] Cannot connect to API: " + endpoint);
        } catch (Exception e) {
            System.err.println("[GoshipService] API call error: " + e.getMessage());
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }
        return null;
    }

    private List<ShippingRate> getDefaultRates() {
        List<ShippingRate> rates = new ArrayList<>();
        
        ShippingRate rate1 = new ShippingRate();
        rate1.setRateId(1);
        rate1.setCarrierName("Giao Hàng Tiết Kiệm");
        rate1.setCarrierShortName("GHTK");
        rate1.setServiceName("Giao Chuẩn");
        rate1.setBasePrice(BigDecimal.valueOf(30000));
        rate1.setEstimatedDelivery("2-3 ngày");
        rate1.setActive(true);
        rates.add(rate1);
        
        ShippingRate rate2 = new ShippingRate();
        rate2.setRateId(2);
        rate2.setCarrierName("Giao Hàng Nhanh");
        rate2.setCarrierShortName("GHN");
        rate2.setServiceName("Giao Nhanh");
        rate2.setBasePrice(BigDecimal.valueOf(45000));
        rate2.setEstimatedDelivery("1-2 ngày");
        rate2.setActive(true);
        rates.add(rate2);
        
        ShippingRate rate3 = new ShippingRate();
        rate3.setRateId(3);
        rate3.setCarrierName("Viettel Post");
        rate3.setCarrierShortName("VTP");
        rate3.setServiceName("Chuyển phát thường");
        rate3.setBasePrice(BigDecimal.valueOf(25000));
        rate3.setEstimatedDelivery("3-5 ngày");
        rate3.setActive(true);
        rates.add(rate3);
        
        return rates;
    }
    
    public boolean testConnection() {
        String response = callApi(GoshipConfig.ENDPOINT_CITIES, "GET", null);
        return response != null && response.contains("data");
    }
}
