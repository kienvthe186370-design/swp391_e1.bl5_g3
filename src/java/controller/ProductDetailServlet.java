package controller;

import DAO.ProductDAO;
import DAO.DiscountCampaignDAO;
import DAO.ReviewDAO;
import entity.Customer;
import entity.DiscountCampaign;
import entity.Review;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;
import java.util.Map;

@WebServlet(name = "ProductDetailServlet", urlPatterns = {"/product-detail"})
public class ProductDetailServlet extends HttpServlet {
    
    private ProductDAO productDAO;
    private DiscountCampaignDAO discountDAO;
    private ReviewDAO reviewDAO;
    
    @Override
    public void init() throws ServletException {
        productDAO = new ProductDAO();
        discountDAO = new DiscountCampaignDAO();
        reviewDAO = new ReviewDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // Get product ID
            String productIdStr = request.getParameter("id");
            
            if (productIdStr == null || productIdStr.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/shop");
                return;
            }
            
            int productId = Integer.parseInt(productIdStr);
            
            // Get product details
            Map<String, Object> product = productDAO.getProductById(productId);
            
            // Check if product exists and is active
            if (product == null || !((Boolean) product.get("isActive"))) {
                response.sendRedirect(request.getContextPath() + "/shop");
                return;
            }
            
            // Get product images
            List<Map<String, Object>> images = productDAO.getProductImages(productId);
            
            // Get product variants
            List<Map<String, Object>> variants = productDAO.getProductVariants(productId);
            
            // Get product attribute groups for variant selection
            List<Map<String, Object>> attributeGroups = productDAO.getProductAttributeGroups(productId);
            
            // Check for active promotion
            Integer categoryId = (Integer) product.get("categoryID");
            Integer brandId = (Integer) product.get("brandID");
            BigDecimal minPrice = (BigDecimal) product.get("minPrice");
            
            System.out.println("🔍 Checking promotion for Product ID: " + productId);
            System.out.println("   Category: " + categoryId + ", Brand: " + brandId + ", Price: " + minPrice);
            
            // Always initialize hasPromotion to false
            product.put("hasPromotion", false);
            
            if (minPrice != null && minPrice.compareTo(BigDecimal.ZERO) > 0) {
                DiscountCampaign bestCampaign = discountDAO.getBestCampaignForProduct(
                    productId, categoryId, brandId, minPrice
                );
                
                if (bestCampaign != null) {
                    System.out.println("🎉 Found promotion: " + bestCampaign.getCampaignName());
                    
                    BigDecimal discountAmount = discountDAO.calculateDiscount(bestCampaign, minPrice);
                    BigDecimal finalPrice = discountDAO.calculateFinalPrice(bestCampaign, minPrice);
                    
                    System.out.println("   Original: " + minPrice + " → Final: " + finalPrice);
                    
                    product.put("hasPromotion", true);
                    product.put("promotionCampaign", bestCampaign);
                    product.put("discountAmount", discountAmount);
                    product.put("originalPrice", minPrice);
                    product.put("promotionPrice", finalPrice);
                    
                    // Calculate discount percentage
                    if ("percentage".equals(bestCampaign.getDiscountType())) {
                        product.put("discountPercent", bestCampaign.getDiscountValue().intValue());
                    } else {
                        BigDecimal percent = discountAmount.multiply(new BigDecimal("100"))
                                                          .divide(minPrice, 0, BigDecimal.ROUND_HALF_UP);
                        product.put("discountPercent", percent.intValue());
                    }
                    
                    // Apply promotion to all variants
                    if (variants != null && !variants.isEmpty()) {
                        for (Map<String, Object> variant : variants) {
                            BigDecimal variantPrice = (BigDecimal) variant.get("sellingPrice");
                            if (variantPrice != null) {
                                BigDecimal variantDiscount = discountDAO.calculateDiscount(bestCampaign, variantPrice);
                                BigDecimal variantFinalPrice = discountDAO.calculateFinalPrice(bestCampaign, variantPrice);
                                variant.put("originalPrice", variantPrice);
                                variant.put("promotionPrice", variantFinalPrice);
                                variant.put("hasPromotion", true);
                            }
                        }
                    }
                } else {
                    System.out.println("❌ No active promotion found for this product");
                }
            } else {
                System.out.println("⚠️ Product has no price or price is zero");
            }
            
            // Get related products (same category, limit 8)
            List<Map<String, Object>> relatedProducts = productDAO.getProducts(
                null, categoryId, null, true, "date", "desc", 1, 8
            );
            
            // Remove current product from related products
            relatedProducts.removeIf(p -> ((Integer) p.get("productID")) == productId);
            
            // Get same category products (limit to 4)
            if (relatedProducts.size() > 4) {
                relatedProducts = relatedProducts.subList(0, 4);
            }
            
            // Add promotion to related products
            for (Map<String, Object> relatedProduct : relatedProducts) {
                Integer relProdId = (Integer) relatedProduct.get("productID");
                Integer relCatId = (Integer) relatedProduct.get("categoryID");
                Integer relBrandId = (Integer) relatedProduct.get("brandID");
                BigDecimal relMinPrice = (BigDecimal) relatedProduct.get("minPrice");
                
                if (relProdId != null && relMinPrice != null) {
                    DiscountCampaign relCampaign = discountDAO.getBestCampaignForProduct(
                        relProdId, relCatId, relBrandId, relMinPrice
                    );
                    
                    if (relCampaign != null) {
                        BigDecimal relDiscount = discountDAO.calculateDiscount(relCampaign, relMinPrice);
                        BigDecimal relFinalPrice = discountDAO.calculateFinalPrice(relCampaign, relMinPrice);
                        
                        relatedProduct.put("hasPromotion", true);
                        relatedProduct.put("finalPrice", relFinalPrice);
                        
                        if ("percentage".equals(relCampaign.getDiscountType())) {
                            relatedProduct.put("discountPercent", relCampaign.getDiscountValue().intValue());
                        } else {
                            BigDecimal percent = relDiscount.multiply(new BigDecimal("100"))
                                                            .divide(relMinPrice, 0, BigDecimal.ROUND_HALF_UP);
                            relatedProduct.put("discountPercent", percent.intValue());
                        }
                    } else {
                        relatedProduct.put("hasPromotion", false);
                    }
                }
            }
            
            // ========== REVIEWS SECTION ==========
            // Get current customer ID for showing hidden reviews
            Integer currentCustomerId = null;
            Customer customer = (Customer) request.getSession().getAttribute("customer");
            if (customer != null) {
                currentCustomerId = customer.getCustomerID();
            }
            
            // Get review filter rating
            Integer filterRating = null;
            String filterRatingStr = request.getParameter("filterRating");
            if (filterRatingStr != null && !filterRatingStr.isEmpty()) {
                try {
                    filterRating = Integer.parseInt(filterRatingStr);
                    if (filterRating < 1 || filterRating > 5) filterRating = null;
                } catch (NumberFormatException ignored) {}
            }
            
            // Get review page
            int reviewPage = 1;
            String reviewPageStr = request.getParameter("reviewPage");
            if (reviewPageStr != null) {
                try {
                    reviewPage = Integer.parseInt(reviewPageStr);
                    if (reviewPage < 1) reviewPage = 1;
                } catch (NumberFormatException ignored) {}
            }
            int reviewPageSize = 7;
            
            // Get review stats
            Map<String, Object> reviewStats = reviewDAO.getProductReviewStats(productId);
            
            // Get reviews
            List<Review> reviews = reviewDAO.getProductReviews(productId, currentCustomerId, filterRating, reviewPage, reviewPageSize);
            int totalReviews = reviewDAO.countProductReviews(productId, currentCustomerId, filterRating);
            int totalReviewPages = (int) Math.ceil((double) totalReviews / reviewPageSize);
            
            request.setAttribute("reviewStats", reviewStats);
            request.setAttribute("reviews", reviews);
            request.setAttribute("totalReviewCount", totalReviews);
            request.setAttribute("reviewPage", reviewPage);
            request.setAttribute("totalReviewPages", totalReviewPages);
            request.setAttribute("filterRating", filterRating);
            request.setAttribute("currentCustomerId", currentCustomerId);
            // ========== END REVIEWS SECTION ==========
            
            // Set attributes
            request.setAttribute("product", product);
            request.setAttribute("images", images);
            request.setAttribute("variants", variants);
            request.setAttribute("attributeGroups", attributeGroups);
            request.setAttribute("relatedProducts", relatedProducts);
            
            // Forward to JSP
            request.getRequestDispatcher("product-detail.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/shop");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/shop");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
