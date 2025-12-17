/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package DAO;

import entity.Cart;
import entity.CartItem;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Cart and CartItems
 * @author xuand
 */
public class CartDAO extends DBContext {
    
    /**
     * Get or create cart for a customer
     * If customer doesn't have a cart, create one
     * @param customerID Customer ID
     * @return Cart object
     */
    public Cart getOrCreateCart(int customerID) {
        Cart cart = getCartByCustomerID(customerID);
        
        if (cart == null) {
            // Create new cart
            int cartID = createCart(customerID);
            if (cartID > 0) {
                cart = getCartByID(cartID);
            }
        }
        
        return cart;
    }
    
    /**
     * Get cart by customer ID
     * @param customerID Customer ID
     * @return Cart object or null if not found
     */
    public Cart getCartByCustomerID(int customerID) {
        String sql = "SELECT CartID, CustomerID, CreatedDate, UpdatedDate " +
                    "FROM Carts WHERE CustomerID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, customerID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                Cart cart = new Cart();
                cart.setCartID(rs.getInt("CartID"));
                cart.setCustomerID(rs.getInt("CustomerID"));
                cart.setCreatedDate(rs.getTimestamp("CreatedDate"));
                cart.setUpdatedDate(rs.getTimestamp("UpdatedDate"));
                
                // Load cart items
                List<CartItem> items = getCartItems(cart.getCartID());
                cart.setItems(items);
                
                return cart;
            }
        } catch (SQLException e) {
            System.err.println("Error in getCartByCustomerID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Get cart by cart ID
     * @param cartID Cart ID
     * @return Cart object or null if not found
     */
    public Cart getCartByID(int cartID) {
        String sql = "SELECT CartID, CustomerID, CreatedDate, UpdatedDate " +
                    "FROM Carts WHERE CartID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, cartID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                Cart cart = new Cart();
                cart.setCartID(rs.getInt("CartID"));
                cart.setCustomerID(rs.getInt("CustomerID"));
                cart.setCreatedDate(rs.getTimestamp("CreatedDate"));
                cart.setUpdatedDate(rs.getTimestamp("UpdatedDate"));
                
                // Load cart items
                List<CartItem> items = getCartItems(cart.getCartID());
                cart.setItems(items);
                
                return cart;
            }
        } catch (SQLException e) {
            System.err.println("Error in getCartByID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Create new cart for customer
     * @param customerID Customer ID
     * @return Cart ID of newly created cart, or -1 if failed
     */
    public int createCart(int customerID) {
        String sql = "INSERT INTO Carts (CustomerID, CreatedDate, UpdatedDate) " +
                    "VALUES (?, GETDATE(), GETDATE())";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, customerID);
            int rowsAffected = ps.executeUpdate();
            
            if (rowsAffected > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    int cartID = rs.getInt(1);
                    System.out.println("✅ Created cart ID: " + cartID + " for customer: " + customerID);
                    return cartID;
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Error in createCart: " + e.getMessage());
            e.printStackTrace();
        }
        
        return -1;
    }
    
    /**
     * Get all items in a cart with product details
     * @param cartID Cart ID
     * @return List of CartItem objects
     */
    public List<CartItem> getCartItems(int cartID) {
        List<CartItem> items = new ArrayList<>();
        
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ci.CartItemID, ci.CartID, ci.ProductID, ci.VariantID, ");
        sql.append("ci.Quantity, ci.Price, ci.AddedDate, ");
        sql.append("p.ProductName, p.IsActive AS ProductIsActive, ");
        sql.append("c.CategoryName, ");
        sql.append("b.BrandName, ");
        sql.append("(SELECT TOP 1 ImageURL FROM ProductImages WHERE ProductID = p.ProductID AND ImageType = 'main') AS ProductImage, ");
        sql.append("CASE WHEN ci.VariantID IS NOT NULL THEN pv.SKU ELSE NULL END AS VariantSKU, ");
        sql.append("CASE WHEN ci.VariantID IS NOT NULL THEN pv.IsActive ELSE 1 END AS VariantIsActive, ");
        sql.append("CASE WHEN ci.VariantID IS NOT NULL THEN pv.Stock ELSE (SELECT ISNULL(SUM(Stock), 0) FROM ProductVariants WHERE ProductID = p.ProductID AND IsActive = 1) END AS AvailableStock ");
        sql.append("FROM CartItems ci ");
        sql.append("INNER JOIN Products p ON ci.ProductID = p.ProductID ");
        sql.append("LEFT JOIN Categories c ON p.CategoryID = c.CategoryID ");
        sql.append("LEFT JOIN Brands b ON p.BrandID = b.BrandID ");
        sql.append("LEFT JOIN ProductVariants pv ON ci.VariantID = pv.VariantID ");
        sql.append("WHERE ci.CartID = ? ");
        sql.append("ORDER BY ci.AddedDate DESC");
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            ps.setInt(1, cartID);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                CartItem item = new CartItem();
                item.setCartItemID(rs.getInt("CartItemID"));
                item.setCartID(rs.getInt("CartID"));
                item.setProductID(rs.getInt("ProductID"));
                
                Integer variantID = (Integer) rs.getObject("VariantID");
                item.setVariantID(variantID);
                
                item.setQuantity(rs.getInt("Quantity"));
                item.setPrice(rs.getBigDecimal("Price"));
                item.setAddedDate(rs.getTimestamp("AddedDate"));
                
                // Product details
                item.setProductName(rs.getString("ProductName"));
                item.setProductImage(rs.getString("ProductImage"));
                item.setCategoryName(rs.getString("CategoryName"));
                item.setBrandName(rs.getString("BrandName"));
                item.setVariantSKU(rs.getString("VariantSKU"));
                item.setAvailableStock(rs.getInt("AvailableStock"));
                item.setProductActive(rs.getBoolean("ProductIsActive"));
                item.setVariantActive(rs.getBoolean("VariantIsActive"));
                
                items.add(item);
            }
        } catch (SQLException e) {
            System.err.println("Error in getCartItems: " + e.getMessage());
            e.printStackTrace();
        }
        
        return items;
    }
    
    /**
     * Add item to cart or update quantity if already exists
     * @param cartID Cart ID
     * @param productID Product ID
     * @param variantID Variant ID (can be null)
     * @param quantity Quantity to add
     * @param price Price per unit
     * @return true if successful
     */
    public boolean addItem(int cartID, int productID, Integer variantID, int quantity, BigDecimal price) {
        // Check if item already exists
        CartItem existingItem = findItem(cartID, productID, variantID);
        
        if (existingItem != null) {
            // Update quantity
            int newQuantity = existingItem.getQuantity() + quantity;
            return updateQuantity(existingItem.getCartItemID(), newQuantity);
        } else {
            // Insert new item
            String sql = "INSERT INTO CartItems (CartID, ProductID, VariantID, Quantity, Price, AddedDate) " +
                        "VALUES (?, ?, ?, ?, ?, GETDATE())";
            
            try (Connection conn = getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                
                ps.setInt(1, cartID);
                ps.setInt(2, productID);
                
                if (variantID != null) {
                    ps.setInt(3, variantID);
                } else {
                    ps.setNull(3, Types.INTEGER);
                }
                
                ps.setInt(4, quantity);
                ps.setBigDecimal(5, price);
                
                int rowsAffected = ps.executeUpdate();
                System.out.println("✅ Added item to cart: ProductID=" + productID + ", Quantity=" + quantity);
                return rowsAffected > 0;
                
            } catch (SQLException e) {
                System.err.println("❌ Error in addItem: " + e.getMessage());
                e.printStackTrace();
                return false;
            }
        }
    }
    
    /**
     * Find specific item in cart
     * @param cartID Cart ID
     * @param productID Product ID
     * @param variantID Variant ID (can be null)
     * @return CartItem if found, null otherwise
     */
    public CartItem findItem(int cartID, int productID, Integer variantID) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT CartItemID, CartID, ProductID, VariantID, Quantity, Price, AddedDate ");
        sql.append("FROM CartItems ");
        sql.append("WHERE CartID = ? AND ProductID = ? ");
        
        if (variantID != null) {
            sql.append("AND VariantID = ?");
        } else {
            sql.append("AND VariantID IS NULL");
        }
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            ps.setInt(1, cartID);
            ps.setInt(2, productID);
            
            if (variantID != null) {
                ps.setInt(3, variantID);
            }
            
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                CartItem item = new CartItem();
                item.setCartItemID(rs.getInt("CartItemID"));
                item.setCartID(rs.getInt("CartID"));
                item.setProductID(rs.getInt("ProductID"));
                item.setVariantID((Integer) rs.getObject("VariantID"));
                item.setQuantity(rs.getInt("Quantity"));
                item.setPrice(rs.getBigDecimal("Price"));
                item.setAddedDate(rs.getTimestamp("AddedDate"));
                return item;
            }
        } catch (SQLException e) {
            System.err.println("Error in findItem: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Update quantity of cart item
     * @param cartItemID Cart Item ID
     * @param newQuantity New quantity
     * @return true if successful
     */
    public boolean updateQuantity(int cartItemID, int newQuantity) {
        if (newQuantity <= 0) {
            return removeItem(cartItemID);
        }
        
        String sql = "UPDATE CartItems SET Quantity = ? WHERE CartItemID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, newQuantity);
            ps.setInt(2, cartItemID);
            
            int rowsAffected = ps.executeUpdate();
            System.out.println("✅ Updated cart item " + cartItemID + " quantity to " + newQuantity);
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ Error in updateQuantity: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Remove item from cart
     * @param cartItemID Cart Item ID
     * @return true if successful
     */
    public boolean removeItem(int cartItemID) {
        String sql = "DELETE FROM CartItems WHERE CartItemID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, cartItemID);
            int rowsAffected = ps.executeUpdate();
            System.out.println("✅ Removed cart item: " + cartItemID);
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ Error in removeItem: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Clear all items from cart
     * @param cartID Cart ID
     * @return true if successful
     */
    public boolean clearCart(int cartID) {
        String sql = "DELETE FROM CartItems WHERE CartID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, cartID);
            int rowsAffected = ps.executeUpdate();
            System.out.println("✅ Cleared cart: " + cartID + " (" + rowsAffected + " items removed)");
            return true;
            
        } catch (SQLException e) {
            System.err.println("❌ Error in clearCart: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Get total number of items in cart
     * @param cartID Cart ID
     * @return Total quantity
     */
    public int getCartItemCount(int cartID) {
        String sql = "SELECT ISNULL(SUM(Quantity), 0) AS TotalCount FROM CartItems WHERE CartID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, cartID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("TotalCount");
            }
        } catch (SQLException e) {
            System.err.println("Error in getCartItemCount: " + e.getMessage());
            e.printStackTrace();
        }
        
        return 0;
    }
    
    /**
     * Get cart subtotal
     * @param cartID Cart ID
     * @return Subtotal amount
     */
    public BigDecimal getCartSubtotal(int cartID) {
        String sql = "SELECT ISNULL(SUM(Price * Quantity), 0) AS Subtotal FROM CartItems WHERE CartID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, cartID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getBigDecimal("Subtotal");
            }
        } catch (SQLException e) {
            System.err.println("Error in getCartSubtotal: " + e.getMessage());
            e.printStackTrace();
        }
        
        return BigDecimal.ZERO;
    }
    
    /**
     * Delete cart (usually after order is placed)
     * @param cartID Cart ID
     * @return true if successful
     */
    public boolean deleteCart(int cartID) {
        // CartItems will be deleted automatically due to CASCADE
        String sql = "DELETE FROM Carts WHERE CartID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, cartID);
            int rowsAffected = ps.executeUpdate();
            System.out.println("✅ Deleted cart: " + cartID);
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ Error in deleteCart: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}

