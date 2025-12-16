/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;

import DAO.CartDAO;
import DAO.ProductDAO;
import DAO.DiscountCampaignDAO;
import entity.Cart;
import entity.CartItem;
import entity.Customer;
import entity.DiscountCampaign;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Controller for Shopping Cart Management
 * @author xuand
 */
@WebServlet(name="CartController", urlPatterns={"/cart", "/cart/*"})
public class CartController extends HttpServlet {
    
    private CartDAO cartDAO;
    private ProductDAO productDAO;
    private DiscountCampaignDAO discountDAO;
    
    @Override
    public void init() throws ServletException {
        cartDAO = new CartDAO();
        productDAO = new ProductDAO();
        discountDAO = new DiscountCampaignDAO();
    }
    
    /**
     * Extract action from request (supports both path and query parameter)
     */
    private String getAction(HttpServletRequest request, String defaultAction) {
        String pathInfo = request.getPathInfo();
        if (pathInfo != null && pathInfo.length() > 1) {
            return pathInfo.substring(1);
        }
        String actionParam = request.getParameter("action");
        return (actionParam != null && !actionParam.isEmpty()) ? actionParam : defaultAction;
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        String action = getAction(request, "view");
        
        switch (action) {
            case "view":
                viewCart(request, response);
                break;
            case "add":
                addToCart(request, response);
                break;
            case "remove":
                removeCartItem(request, response);
                break;
            case "count":
                getCartCount(request, response);
                break;
            default:
                viewCart(request, response);
                break;
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        String action = getAction(request, "");
        
        switch (action) {
            case "add":
                addToCart(request, response);
                break;
            case "update":
                updateCartItem(request, response);
                break;
            case "remove":
                removeCartItem(request, response);
                break;
            case "clear":
                clearCart(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
                break;
        }
    }
    
    /**
     * View shopping cart page
     */
    private void viewCart(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        
        if (customer == null) {
            // Guest user - show empty cart
            request.setAttribute("cartItems", new java.util.ArrayList<>());
            request.setAttribute("subtotal", BigDecimal.ZERO);
            request.setAttribute("total", BigDecimal.ZERO);
            request.setAttribute("itemCount", 0);
            session.setAttribute("cartCount", 0);
            session.setAttribute("cartTotal", BigDecimal.ZERO);
            request.getRequestDispatcher("/shopping-cart.jsp").forward(request, response);
            return;
        }
        
        try {
            // Get or create cart for customer
            Cart cart = cartDAO.getOrCreateCart(customer.getCustomerID());
            
            if (cart != null) {
                List<CartItem> items = cart.getItems();
                BigDecimal subtotal = cart.getSubtotal();
                int itemCount = cart.getTotalItems();
                
                // Store in session for quick access (important for header display)
                session.setAttribute("cartCount", itemCount);
                session.setAttribute("cartTotal", subtotal);
                
                // Set attributes for JSP
                request.setAttribute("cart", cart);
                request.setAttribute("cartItems", items);
                request.setAttribute("subtotal", subtotal);
                request.setAttribute("total", subtotal); // Will be updated with shipping/discount later
                request.setAttribute("itemCount", itemCount);
                
                System.out.println("✅ Loaded cart: " + itemCount + " items, Subtotal: " + subtotal);
            } else {
                request.setAttribute("cartItems", new java.util.ArrayList<>());
                request.setAttribute("subtotal", BigDecimal.ZERO);
                request.setAttribute("total", BigDecimal.ZERO);
                request.setAttribute("itemCount", 0);
                session.setAttribute("cartCount", 0);
                session.setAttribute("cartTotal", BigDecimal.ZERO);
            }
            
            request.getRequestDispatcher("/shopping-cart.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.err.println("❌ Error in viewCart: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi tải giỏ hàng");
            request.getRequestDispatcher("/shopping-cart.jsp").forward(request, response);
        }
    }
    
    /**
     * Add product to cart
     */
    private void addToCart(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        
        if (customer == null) {
            // Redirect to login
            response.sendRedirect(request.getContextPath() + "/login.jsp?redirect=cart");
            return;
        }
        
        try {
            // Get parameters
            int productID = Integer.parseInt(request.getParameter("productId"));
            String variantIdStr = request.getParameter("variantId");
            Integer variantID = (variantIdStr != null && !variantIdStr.isEmpty()) 
                ? Integer.parseInt(variantIdStr) : null;
            
            // Default quantity to 1 if not provided
            String quantityStr = request.getParameter("quantity");
            int quantity = (quantityStr != null && !quantityStr.isEmpty()) 
                ? Integer.parseInt(quantityStr) : 1;
            
            // Validate quantity
            if (quantity <= 0) {
                response.sendRedirect(request.getContextPath() + "/cart?error=invalid_quantity");
                return;
            }
            
            // Get product details
            Map<String, Object> product = productDAO.getProductById(productID);
            if (product == null) {
                response.sendRedirect(request.getContextPath() + "/cart?error=product_not_found");
                return;
            }
            
            // Check if product is active
            Boolean isActive = (Boolean) product.get("isActive");
            if (isActive == null || !isActive) {
                response.sendRedirect(request.getContextPath() + "/cart?error=product_inactive");
                return;
            }
            
            // Get price
            BigDecimal price;
            Integer selectedVariantID = variantID; // Create a new variable for lambda
            
            // Get all variants for this product
            List<Map<String, Object>> variants = productDAO.getProductVariants(productID);
            
            if (variants == null || variants.isEmpty()) {
                System.err.println("❌ Product has no variants: " + productID);
                response.sendRedirect(request.getContextPath() + "/cart?error=no_variants");
                return;
            }
            
            if (selectedVariantID != null) {
                // Get specific variant price
                final Integer finalVariantID = selectedVariantID; // Make it final for lambda
                Map<String, Object> selectedVariant = variants.stream()
                    .filter(v -> ((Integer) v.get("variantID")).equals(finalVariantID))
                    .findFirst()
                    .orElse(null);
                
                if (selectedVariant == null) {
                    System.err.println("❌ Variant not found: " + selectedVariantID);
                    response.sendRedirect(request.getContextPath() + "/cart?error=variant_not_found");
                    return;
                }
                
                price = (BigDecimal) selectedVariant.get("sellingPrice");
                
                if (price == null) {
                    System.err.println("❌ Variant has no price: " + selectedVariantID);
                    response.sendRedirect(request.getContextPath() + "/cart?error=no_price");
                    return;
                }
                
                // Check stock
                Integer stock = (Integer) selectedVariant.get("stock");
                if (stock == null || stock < quantity) {
                    response.sendRedirect(request.getContextPath() + "/cart?error=insufficient_stock");
                    return;
                }
            } else {
                // No variant specified - get first active variant with stock
                Map<String, Object> firstVariant = variants.stream()
                    .filter(v -> {
                        Boolean variantActive = (Boolean) v.get("isActive");
                        Integer variantStock = (Integer) v.get("stock");
                        return (variantActive != null && variantActive) && (variantStock != null && variantStock > 0);
                    })
                    .findFirst()
                    .orElse(null);
                
                if (firstVariant == null) {
                    System.err.println("❌ No active variant with stock for product: " + productID);
                    response.sendRedirect(request.getContextPath() + "/cart?error=no_available_variant");
                    return;
                }
                
                // Use first variant's ID and price
                selectedVariantID = (Integer) firstVariant.get("variantID");
                price = (BigDecimal) firstVariant.get("sellingPrice");
                
                if (price == null) {
                    System.err.println("❌ First variant has no price: " + selectedVariantID);
                    response.sendRedirect(request.getContextPath() + "/cart?error=no_price");
                    return;
                }
                
                // Check stock
                Integer stock = (Integer) firstVariant.get("stock");
                if (stock == null || stock < quantity) {
                    response.sendRedirect(request.getContextPath() + "/cart?error=insufficient_stock");
                    return;
                }
                
                System.out.println("✅ Auto-selected variant: " + selectedVariantID + " with price: " + price);
            }
            
            // Check for active promotion and apply discount
            Integer categoryId = (Integer) product.get("categoryID");
            Integer brandId = (Integer) product.get("brandID");
            BigDecimal finalPrice = price;
            
            DiscountCampaign bestCampaign = discountDAO.getBestCampaignForProduct(
                productID, categoryId, brandId, price
            );
            
            if (bestCampaign != null) {
                finalPrice = discountDAO.calculateFinalPrice(bestCampaign, price);
                System.out.println("🎉 Promotion applied! Original: " + price + " → Final: " + finalPrice + 
                                 " (Campaign: " + bestCampaign.getCampaignName() + ")");
            }
            
            // Get or create cart
            Cart cart = cartDAO.getOrCreateCart(customer.getCustomerID());
            
            if (cart == null) {
                response.sendRedirect(request.getContextPath() + "/cart?error=cart_creation_failed");
                return;
            }
            
            // Add item to cart with promotion price (use selectedVariantID instead of variantID)
            boolean success = cartDAO.addItem(cart.getCartID(), productID, selectedVariantID, quantity, finalPrice);
            
            if (success) {
                // Update session cart count
                int newCount = cartDAO.getCartItemCount(cart.getCartID());
                session.setAttribute("cartCount", newCount);
                
                // Redirect based on source
                String source = request.getParameter("source");
                if ("product-detail".equals(source)) {
                    response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productID + "&success=added_to_cart");
                } else if ("shop".equals(source)) {
    // Stay on shop page with success message
    String referer = request.getHeader("Referer");
    if (referer != null && referer.contains("/shop")) {
        response.sendRedirect(referer + (referer.contains("?") ? "&" : "?") + "success=added_to_cart");
    } else {
        response.sendRedirect(request.getContextPath() + "/shop?success=added_to_cart");
    }


                } else {
                    response.sendRedirect(request.getContextPath() + "/cart?success=added");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/cart?error=add_failed");
            }
            
        } catch (NumberFormatException e) {
            System.err.println("❌ Invalid parameter: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/cart?error=invalid_parameter");
        } catch (Exception e) {
            System.err.println("❌ Error in addToCart: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/cart?error=add_failed");
        }
    }
    
    /**
     * Update cart item quantity (AJAX)
     */
    private void updateCartItem(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        
        try (PrintWriter out = response.getWriter()) {
            if (customer == null) {
                out.print("{\"success\": false, \"message\": \"Chưa đăng nhập\"}");
                return;
            }
            
            int cartItemID = Integer.parseInt(request.getParameter("cartItemId"));
            int newQuantity = Integer.parseInt(request.getParameter("quantity"));
            
            if (newQuantity < 0) {
                out.print("{\"success\": false, \"message\": \"Số lượng không hợp lệ\"}");
                return;
            }
            
            // Get cart item to check stock
            Cart cart = cartDAO.getOrCreateCart(customer.getCustomerID());
            CartItem item = null;
            for (CartItem ci : cart.getItems()) {
                if (ci.getCartItemID() == cartItemID) {
                    item = ci;
                    break;
                }
            }
            
            if (item == null) {
                out.print("{\"success\": false, \"message\": \"Không tìm thấy sản phẩm trong giỏ hàng\"}");
                return;
            }
            
            // Check if new quantity exceeds available stock
            int availableStock = item.getAvailableStock();
            if (newQuantity > availableStock) {
                out.print("{\"success\": false, \"message\": \"Chỉ còn " + availableStock + " sản phẩm trong kho\", \"maxStock\": " + availableStock + "}");
                return;
            }
            
            // Update quantity
            boolean success = cartDAO.updateQuantity(cartItemID, newQuantity);
            
            if (success) {
                // Reload cart to get updated totals
                cart = cartDAO.getOrCreateCart(customer.getCustomerID());
                int newCount = cart.getTotalItems();
                BigDecimal newSubtotal = cart.getSubtotal();
                
                // Calculate item total
                BigDecimal itemTotal = item.getPrice().multiply(new BigDecimal(newQuantity));
                
                // Update session
                session.setAttribute("cartCount", newCount);
                session.setAttribute("cartTotal", newSubtotal);
                
                // Return JSON response with updated values
                out.print("{\"success\": true, " +
                         "\"itemCount\": " + newCount + ", " +
                         "\"subtotal\": " + newSubtotal.longValue() + ", " +
                         "\"itemTotal\": " + itemTotal.longValue() + ", " +
                         "\"quantity\": " + newQuantity + "}");
            } else {
                out.print("{\"success\": false, \"message\": \"Cập nhật thất bại\"}");
            }
            
        } catch (Exception e) {
            System.err.println("❌ Error in updateCartItem: " + e.getMessage());
            e.printStackTrace();
            response.getWriter().print("{\"success\": false, \"message\": \"Lỗi: " + e.getMessage() + "\"}");
        }
    }
    
    /**
     * Remove item from cart
     */
    private void removeCartItem(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        try {
            int cartItemID = Integer.parseInt(request.getParameter("cartItemId"));
            
            boolean success = cartDAO.removeItem(cartItemID);
            
            if (success) {
                // Update session cart count
                Cart cart = cartDAO.getOrCreateCart(customer.getCustomerID());
                int newCount = cart.getTotalItems();
                session.setAttribute("cartCount", newCount);
                
                response.sendRedirect(request.getContextPath() + "/cart?success=removed");
            } else {
                response.sendRedirect(request.getContextPath() + "/cart?error=remove_failed");
            }
            
        } catch (Exception e) {
            System.err.println("❌ Error in removeCartItem: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/cart?error=remove_failed");
        }
    }
    
    /**
     * Clear all items from cart
     */
    private void clearCart(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        try {
            Cart cart = cartDAO.getOrCreateCart(customer.getCustomerID());
            
            if (cart != null) {
                boolean success = cartDAO.clearCart(cart.getCartID());
                
                if (success) {
                    session.setAttribute("cartCount", 0);
                    session.setAttribute("cartTotal", BigDecimal.ZERO);
                    response.sendRedirect(request.getContextPath() + "/cart?success=cleared");
                } else {
                    response.sendRedirect(request.getContextPath() + "/cart?error=clear_failed");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/cart");
            }
            
        } catch (Exception e) {
            System.err.println("❌ Error in clearCart: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/cart?error=clear_failed");
        }
    }
    
    /**
     * Get cart count (AJAX)
     */
    private void getCartCount(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        
        try (PrintWriter out = response.getWriter()) {
            if (customer == null) {
                out.print("{\"count\": 0, \"total\": 0}");
                return;
            }
            
            Cart cart = cartDAO.getOrCreateCart(customer.getCustomerID());
            int count = (cart != null) ? cart.getTotalItems() : 0;
            BigDecimal total = (cart != null) ? cart.getSubtotal() : BigDecimal.ZERO;
            
            // Update session
            session.setAttribute("cartCount", count);
            session.setAttribute("cartTotal", total);
            
            out.print("{\"count\": " + count + ", \"total\": " + total.longValue() + "}");
            
        } catch (Exception e) {
            System.err.println("❌ Error in getCartCount: " + e.getMessage());
            e.printStackTrace();
            response.getWriter().print("{\"count\": 0, \"total\": 0}");
        }
    }
    
    @Override
    public String getServletInfo() {
        return "Shopping Cart Controller";
    }
}
