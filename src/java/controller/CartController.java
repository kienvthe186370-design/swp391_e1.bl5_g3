/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;

import DAO.CartDAO;
import DAO.ProductDAO;
import entity.Cart;
import entity.CartItem;
import entity.Customer;
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
    
    @Override
    public void init() throws ServletException {
        cartDAO = new CartDAO();
        productDAO = new ProductDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        // Support both /cart/add and /cart?action=add
        String pathInfo = request.getPathInfo();
        String actionParam = request.getParameter("action");
        
        String action;
        if (pathInfo != null && pathInfo.length() > 1) {
            action = pathInfo.substring(1);
        } else if (actionParam != null && !actionParam.isEmpty()) {
            action = actionParam;
        } else {
            action = "view";
        }
        
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
        // Support both /cart/add and /cart?action=add
        String pathInfo = request.getPathInfo();
        String actionParam = request.getParameter("action");
        
        String action;
        if (pathInfo != null && pathInfo.length() > 1) {
            action = pathInfo.substring(1);
        } else if (actionParam != null && !actionParam.isEmpty()) {
            action = actionParam;
        } else {
            action = "";
        }
        
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
            // Guest user - redirect to login or show empty cart
            request.setAttribute("cartItems", new java.util.ArrayList<>());
            request.setAttribute("subtotal", BigDecimal.ZERO);
            request.setAttribute("total", BigDecimal.ZERO);
            request.setAttribute("itemCount", 0);
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
                
                // Store in session for quick access
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
            if (variantID != null) {
                // Get variant price
                List<Map<String, Object>> variants = productDAO.getProductVariants(productID);
                Map<String, Object> selectedVariant = variants.stream()
                    .filter(v -> ((Integer) v.get("variantID")).equals(variantID))
                    .findFirst()
                    .orElse(null);
                
                if (selectedVariant == null) {
                    response.sendRedirect(request.getContextPath() + "/cart?error=variant_not_found");
                    return;
                }
                
                price = (BigDecimal) selectedVariant.get("sellingPrice");
                
                // Check stock
                int stock = (Integer) selectedVariant.get("stock");
                if (stock < quantity) {
                    response.sendRedirect(request.getContextPath() + "/cart?error=insufficient_stock");
                    return;
                }
            } else {
                // Get product price (min price)
                price = (BigDecimal) product.get("minPrice");
                
                if (price == null) {
                    response.sendRedirect(request.getContextPath() + "/cart?error=no_price");
                    return;
                }
                
                // Check total stock
                int totalStock = (Integer) product.get("totalStock");
                if (totalStock < quantity) {
                    response.sendRedirect(request.getContextPath() + "/cart?error=insufficient_stock");
                    return;
                }
            }
            
            // Get or create cart
            Cart cart = cartDAO.getOrCreateCart(customer.getCustomerID());
            
            if (cart == null) {
                response.sendRedirect(request.getContextPath() + "/cart?error=cart_creation_failed");
                return;
            }
            
            // Add item to cart
            boolean success = cartDAO.addItem(cart.getCartID(), productID, variantID, quantity, price);
            
            if (success) {
                // Update session cart count
                int newCount = cartDAO.getCartItemCount(cart.getCartID());
                session.setAttribute("cartCount", newCount);
                
                // Redirect based on source
                String source = request.getParameter("source");
                if ("product-detail".equals(source)) {
                    response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productID + "&success=added_to_cart");
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
                out.print("{\"success\": false, \"message\": \"Not logged in\"}");
                return;
            }
            
            int cartItemID = Integer.parseInt(request.getParameter("cartItemId"));
            int newQuantity = Integer.parseInt(request.getParameter("quantity"));
            
            if (newQuantity < 0) {
                out.print("{\"success\": false, \"message\": \"Invalid quantity\"}");
                return;
            }
            
            boolean success = cartDAO.updateQuantity(cartItemID, newQuantity);
            
            if (success) {
                // Get updated cart info
                Cart cart = cartDAO.getOrCreateCart(customer.getCustomerID());
                int newCount = cart.getTotalItems();
                BigDecimal newSubtotal = cart.getSubtotal();
                
                // Update session
                session.setAttribute("cartCount", newCount);
                session.setAttribute("cartTotal", newSubtotal);
                
                // Return JSON response
                out.print("{\"success\": true, \"itemCount\": " + newCount + 
                         ", \"subtotal\": " + newSubtotal.longValue() + "}");
            } else {
                out.print("{\"success\": false, \"message\": \"Update failed\"}");
            }
            
        } catch (Exception e) {
            System.err.println("❌ Error in updateCartItem: " + e.getMessage());
            e.printStackTrace();
            response.getWriter().print("{\"success\": false, \"message\": \"Error: " + e.getMessage() + "\"}");
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
                out.print("{\"count\": 0}");
                return;
            }
            
            Cart cart = cartDAO.getOrCreateCart(customer.getCustomerID());
            int count = (cart != null) ? cart.getTotalItems() : 0;
            
            out.print("{\"count\": " + count + "}");
            
        } catch (Exception e) {
            System.err.println("❌ Error in getCartCount: " + e.getMessage());
            e.printStackTrace();
            response.getWriter().print("{\"count\": 0}");
        }
    }
    
    @Override
    public String getServletInfo() {
        return "Shopping Cart Controller";
    }
}
