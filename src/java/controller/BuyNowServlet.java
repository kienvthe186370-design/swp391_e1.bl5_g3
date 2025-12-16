package controller;

import DAO.*;
import entity.*;
import service.GoshipService;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.math.BigDecimal;
import java.util.*;

/**
 * Servlet xử lý chức năng "Mua ngay" - checkout trực tiếp từ trang product detail
 * mà không cần thêm vào giỏ hàng
 */
@WebServlet(name = "BuyNowServlet", urlPatterns = {"/buy-now"})
public class BuyNowServlet extends HttpServlet {
    
    private ProductDAO productDAO = new ProductDAO();
    private CustomerAddressDAO addressDAO = new CustomerAddressDAO();
    private VoucherDAO voucherDAO = new VoucherDAO();
    private DiscountCampaignDAO discountDAO = new DiscountCampaignDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        
        // Kiểm tra đăng nhập
        if (customer == null) {
            // Lưu thông tin sản phẩm để redirect sau khi đăng nhập
            String productId = request.getParameter("productId");
            String variantId = request.getParameter("variantId");
            String quantity = request.getParameter("quantity");
            String redirectUrl = "buy-now?productId=" + productId + "&variantId=" + variantId + "&quantity=" + quantity;
            response.sendRedirect("login.jsp?redirect=" + java.net.URLEncoder.encode(redirectUrl, "UTF-8"));
            return;
        }
        
        try {
            // Lấy thông tin từ request
            int productId = Integer.parseInt(request.getParameter("productId"));
            int variantId = Integer.parseInt(request.getParameter("variantId"));
            int quantity = 1;
            try {
                quantity = Integer.parseInt(request.getParameter("quantity"));
                if (quantity <= 0) quantity = 1;
            } catch (Exception e) {
                quantity = 1;
            }
            
            // Lấy thông tin sản phẩm
            Map<String, Object> product = productDAO.getProductById(productId);
            if (product == null) {
                response.sendRedirect("shop?error=product_not_found");
                return;
            }
            
            // Lấy thông tin variant
            List<Map<String, Object>> variants = productDAO.getProductVariants(productId);
            Map<String, Object> selectedVariant = null;
            
            for (Map<String, Object> v : variants) {
                if (((Integer) v.get("variantID")).equals(variantId)) {
                    selectedVariant = v;
                    break;
                }
            }
            
            if (selectedVariant == null) {
                response.sendRedirect("product-detail?id=" + productId + "&error=variant_not_found");
                return;
            }
            
            // Kiểm tra tồn kho
            Integer stock = (Integer) selectedVariant.get("stock");
            if (stock == null || stock < quantity) {
                response.sendRedirect("product-detail?id=" + productId + "&error=insufficient_stock");
                return;
            }
            
            // Lấy giá và áp dụng khuyến mãi nếu có
            BigDecimal originalPrice = (BigDecimal) selectedVariant.get("sellingPrice");
            BigDecimal finalPrice = originalPrice;
            
            Integer categoryId = (Integer) product.get("categoryID");
            Integer brandId = (Integer) product.get("brandID");
            
            DiscountCampaign bestCampaign = discountDAO.getBestCampaignForProduct(
                productId, categoryId, brandId, originalPrice
            );
            
            if (bestCampaign != null) {
                finalPrice = discountDAO.calculateFinalPrice(bestCampaign, originalPrice);
            }
            
            // Tạo BuyNowItem để lưu vào session
            BuyNowItem buyNowItem = new BuyNowItem();
            buyNowItem.setProductId(productId);
            buyNowItem.setVariantId(variantId);
            buyNowItem.setProductName((String) product.get("productName"));
            buyNowItem.setVariantName((String) selectedVariant.get("sku"));
            buyNowItem.setPrice(finalPrice);
            buyNowItem.setOriginalPrice(originalPrice);
            buyNowItem.setQuantity(quantity);
            buyNowItem.setImageUrl((String) product.get("imageURL"));
            
            // Lưu vào session
            session.setAttribute("buyNowItem", buyNowItem);
            
            // Lấy địa chỉ khách hàng
            int customerID = customer.getCustomerID();
            List<CustomerAddress> addresses = addressDAO.getAddressesByCustomerId(customerID);
            
            // Lấy voucher công khai
            List<Voucher> vouchers = new ArrayList<>();
            try {
                vouchers = voucherDAO.getActivePublicVouchers();
            } catch (Exception e) {
                System.err.println("[BuyNow] Error getting vouchers: " + e.getMessage());
            }
            
            // Tính tổng tiền
            BigDecimal subtotal = finalPrice.multiply(new BigDecimal(quantity));
            
            // Shipping rates mặc định
            List<ShippingRate> shippingRates = getDefaultShippingRates();
            
            // Set attributes
            request.setAttribute("buyNowMode", true);
            request.setAttribute("buyNowItem", buyNowItem);
            request.setAttribute("subtotal", subtotal);
            request.setAttribute("addresses", addresses);
            request.setAttribute("publicVouchers", vouchers);
            request.setAttribute("shippingRates", shippingRates);
            
            // Forward đến trang checkout
            request.getRequestDispatcher("checkout.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect("shop?error=invalid_parameter");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("shop?error=system_error");
        }
    }
    
    private List<ShippingRate> getDefaultShippingRates() {
        List<ShippingRate> rates = new ArrayList<>();
        
        ShippingRate rate1 = new ShippingRate();
        rate1.setRateId(1);
        rate1.setCarrierName("Giao Hàng Tiết Kiệm");
        rate1.setServiceName("Giao Chuẩn");
        rate1.setBasePrice(new BigDecimal("30000"));
        rate1.setEstimatedDelivery("3-5 ngày");
        rate1.setActive(true);
        rates.add(rate1);
        
        ShippingRate rate2 = new ShippingRate();
        rate2.setRateId(2);
        rate2.setCarrierName("Giao Hàng Nhanh");
        rate2.setServiceName("Giao Nhanh");
        rate2.setBasePrice(new BigDecimal("45000"));
        rate2.setEstimatedDelivery("1-2 ngày");
        rate2.setActive(true);
        rates.add(rate2);
        
        ShippingRate rate3 = new ShippingRate();
        rate3.setRateId(3);
        rate3.setCarrierName("Viettel Post");
        rate3.setServiceName("Chuyển phát thường");
        rate3.setBasePrice(new BigDecimal("25000"));
        rate3.setEstimatedDelivery("3-5 ngày");
        rate3.setActive(true);
        rates.add(rate3);
        
        return rates;
    }
}
