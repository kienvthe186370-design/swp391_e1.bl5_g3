package controller;

import DAO.*;
import entity.*;
import service.VNPayService;
import service.GoshipService;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "CheckoutServlet", urlPatterns = {"/checkout"})
public class CheckoutServlet extends HttpServlet {
    
    private CartDAO cartDAO = new CartDAO();
    private CustomerAddressDAO addressDAO = new CustomerAddressDAO();
    private VoucherDAO voucherDAO = new VoucherDAO();
    private OrderDAO orderDAO = new OrderDAO();
    private PaymentDAO paymentDAO = new PaymentDAO();
    private ShippingDAO shippingDAO = new ShippingDAO();
    private GoshipService goshipService = new GoshipService();
    private VNPayService vnPayService = new VNPayService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        long startTime = System.currentTimeMillis();
        System.out.println("[Checkout] === START doGet ===");
        
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        
        if (customer == null) {
            System.out.println("[Checkout] No customer in session, redirecting to login");
            response.sendRedirect("login.jsp?redirect=checkout");
            return;
        }
        
        int customerID = customer.getCustomerID();
        System.out.println("[Checkout] CustomerID: " + customerID);
        
        // Get cart
        System.out.println("[Checkout] Getting cart...");
        Cart cart = null;
        try {
            cart = cartDAO.getOrCreateCart(customerID);
        } catch (Exception e) {
            System.err.println("[Checkout] Error getting cart: " + e.getMessage());
            e.printStackTrace();
        }
        System.out.println("[Checkout] Cart loaded in " + (System.currentTimeMillis() - startTime) + "ms");
        
        if (cart == null || cart.getItems() == null || cart.getItems().isEmpty()) {
            System.out.println("[Checkout] Cart is empty, redirecting");
            response.sendRedirect("shopping-cart.jsp?error=empty");
            return;
        }
        
        // Check if cart has unavailable items (inactive products/variants)
        if (cart.hasUnavailableItems()) {
            System.out.println("[Checkout] Cart has unavailable items, cannot checkout");
            response.sendRedirect("cart?error=unavailable_items");
            return;
        }
        
        List<CartItem> cartItems = cart.getItems();
        BigDecimal subtotal = BigDecimal.ZERO;
        try {
            subtotal = cartDAO.getCartSubtotal(cart.getCartID());
        } catch (Exception e) {
            System.err.println("[Checkout] Error getting subtotal: " + e.getMessage());
            // Calculate manually
            for (CartItem item : cartItems) {
                subtotal = subtotal.add(item.getTotal());
            }
        }
        System.out.println("[Checkout] Subtotal: " + subtotal + " - Time: " + (System.currentTimeMillis() - startTime) + "ms");
        
        // Get addresses
        System.out.println("[Checkout] Getting addresses...");
        List<CustomerAddress> addresses = new ArrayList<>();
        CustomerAddress defaultAddress = null;
        try {
            addresses = addressDAO.getAddressesByCustomerId(customerID);
            defaultAddress = addressDAO.getDefaultAddress(customerID);
        } catch (Exception e) {
            System.err.println("[Checkout] Error getting addresses: " + e.getMessage());
        }
        System.out.println("[Checkout] Addresses loaded: " + addresses.size() + " - Time: " + (System.currentTimeMillis() - startTime) + "ms");
        
        // Get vouchers - skip if slow
        System.out.println("[Checkout] Getting vouchers...");
        List<Voucher> vouchers = new ArrayList<>();
        List<Integer> usedUpVoucherIds = new ArrayList<>();
        try {
            vouchers = voucherDAO.getActivePublicVouchers();
            // Get list of vouchers that customer has used up
            usedUpVoucherIds = voucherDAO.getUsedUpVoucherIdsForCustomer(customerID);
        } catch (Exception e) {
            System.err.println("[Checkout] Error getting vouchers: " + e.getMessage());
        }
        System.out.println("[Checkout] Vouchers loaded: " + vouchers.size() + ", Used up: " + usedUpVoucherIds.size() + " - Time: " + (System.currentTimeMillis() - startTime) + "ms");
        
        // Get shipping rates - Use default rates for fast loading
        List<ShippingRate> shippingRates = getDefaultShippingRates();
        System.out.println("[Checkout] Using default shipping rates");

        request.setAttribute("cart", cart);
        request.setAttribute("cartItems", cartItems);
        request.setAttribute("subtotal", subtotal);
        request.setAttribute("addresses", addresses);
        request.setAttribute("defaultAddress", defaultAddress);
        request.setAttribute("vouchers", vouchers);
        request.setAttribute("publicVouchers", vouchers); // For voucher modal
        request.setAttribute("usedUpVoucherIds", usedUpVoucherIds); // Vouchers customer has used up
        request.setAttribute("shippingRates", shippingRates);
        
        System.out.println("[Checkout] === FORWARDING to checkout.jsp === Total time: " + (System.currentTimeMillis() - startTime) + "ms");
        request.getRequestDispatcher("checkout.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        
        if (customer == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        int customerID = customer.getCustomerID();
        
        // Kiểm tra chế độ Mua ngay
        String buyNowModeStr = request.getParameter("buyNowMode");
        boolean isBuyNowMode = "true".equals(buyNowModeStr);
        
        Cart cart = null;
        List<CartItem> cartItems = null;
        
        if (isBuyNowMode) {
            // Chế độ Mua ngay - tạo cart items từ thông tin sản phẩm
            BuyNowItem buyNowItem = (BuyNowItem) session.getAttribute("buyNowItem");
            if (buyNowItem == null) {
                response.sendRedirect("shop?error=buy_now_expired");
                return;
            }
            
            // Tạo CartItem từ BuyNowItem
            CartItem item = new CartItem();
            item.setProductID(buyNowItem.getProductId());
            item.setVariantID(buyNowItem.getVariantId());
            item.setProductName(buyNowItem.getProductName());
            item.setVariantName(buyNowItem.getVariantName());
            item.setVariantSKU(buyNowItem.getVariantName());
            item.setQuantity(buyNowItem.getQuantity());
            item.setPrice(buyNowItem.getPrice());
            
            cartItems = new ArrayList<>();
            cartItems.add(item);
        } else {
            // Chế độ checkout từ giỏ hàng
            cart = cartDAO.getOrCreateCart(customerID);
            
            if (cart == null || cart.getItems() == null || cart.getItems().isEmpty()) {
                response.sendRedirect("shopping-cart.jsp?error=empty");
                return;
            }
            
            // Check if cart has unavailable items
            if (cart.hasUnavailableItems()) {
                response.sendRedirect("cart?error=unavailable_items");
                return;
            }
            
            cartItems = cart.getItems();
        }
        
        try {
            // Get form data
            int addressID = Integer.parseInt(request.getParameter("addressId"));
            String paymentMethod = request.getParameter("paymentMethod");
            String voucherCode = request.getParameter("voucherCode");
            String shippingFeeStr = request.getParameter("shippingFee");
            String carrierIdStr = request.getParameter("carrierId");
            String carrierName = request.getParameter("carrierName");
            String estimatedDelivery = request.getParameter("estimatedDelivery");
            String notes = request.getParameter("notes");
            
            BigDecimal shippingFee = new BigDecimal(shippingFeeStr != null ? shippingFeeStr : "30000");
            Integer rateID = null;
            String goshipCarrierId = null;
            
            if (carrierIdStr != null && !carrierIdStr.isEmpty()) {
                try {
                    rateID = Integer.parseInt(carrierIdStr);
                } catch (NumberFormatException e) {
                    // Goship returns string ID, save as goshipCarrierId
                    goshipCarrierId = carrierIdStr;
                }
            }
            
            // Default values
            if (carrierName == null || carrierName.isEmpty()) {
                carrierName = "Giao Hàng Tiết Kiệm";
            }
            if (estimatedDelivery == null || estimatedDelivery.isEmpty()) {
                estimatedDelivery = "2-3 ngày";
            }

            
            // Calculate totals
            BigDecimal subtotal = BigDecimal.ZERO;
            if (isBuyNowMode) {
                // Tính subtotal từ BuyNowItem
                for (CartItem item : cartItems) {
                    subtotal = subtotal.add(item.getPrice().multiply(new BigDecimal(item.getQuantity())));
                }
            } else {
                subtotal = cartDAO.getCartSubtotal(cart.getCartID());
            }
            
            BigDecimal voucherDiscount = BigDecimal.ZERO;
            Integer voucherID = null;
            
            // Apply voucher if provided
            if (voucherCode != null && !voucherCode.trim().isEmpty()) {
                // Validate voucher for this customer
                Voucher voucher = voucherDAO.validateVoucherForCustomer(voucherCode.trim(), customerID, subtotal);
                if (voucher != null) {
                    voucherDiscount = voucher.calculateDiscount(subtotal);
                    voucherID = voucher.getVoucherID();
                    System.out.println("✅ Voucher validated: " + voucherCode + ", Discount: " + voucherDiscount);
                } else {
                    System.out.println("❌ Voucher validation failed for customer: " + customerID);
                }
            }
            
            BigDecimal totalAmount = subtotal.subtract(voucherDiscount).add(shippingFee);
            
            // Convert CartItems to OrderDetails
            List<OrderDetail> orderDetails = new ArrayList<>();
            for (CartItem item : cartItems) {
                OrderDetail detail = new OrderDetail();
                detail.setVariantID(item.getVariantID() != null ? item.getVariantID() : 0);
                detail.setProductName(item.getProductName());
                detail.setSku(item.getVariantSKU() != null ? item.getVariantSKU() : "N/A");
                detail.setQuantity(item.getQuantity());
                detail.setCostPrice(item.getPrice());
                detail.setUnitPrice(item.getPrice());
                detail.setDiscountAmount(BigDecimal.ZERO);
                detail.setFinalPrice(item.getPrice());
                orderDetails.add(detail);
            }
            
            // Create order
            Order order = new Order();
            order.setOrderCode(orderDAO.generateOrderCode());
            order.setCustomerID(customerID);
            order.setAddressID(addressID);
            order.setSubtotalAmount(subtotal);
            order.setDiscountAmount(BigDecimal.ZERO);
            order.setVoucherDiscount(voucherDiscount);
            order.setShippingFee(shippingFee);
            order.setTotalAmount(totalAmount);
            order.setTotalCost(subtotal);
            order.setTotalProfit(BigDecimal.ZERO);
            order.setVoucherID(voucherID);
            order.setPaymentMethod(paymentMethod);
            order.setNotes(notes);
            order.setPaymentStatus("Unpaid");
            order.setOrderStatus("Pending");

            // Create order in database
            int orderID = orderDAO.createOrder(order, orderDetails);
            
            if (orderID <= 0) {
                request.setAttribute("error", "Không thể tạo đơn hàng. Vui lòng thử lại.");
                doGet(request, response);
                return;
            }
            
            // Record voucher usage and increment used count if voucher was applied
            if (voucherID != null && voucherDiscount.compareTo(BigDecimal.ZERO) > 0) {
                try {
                    // Record usage history
                    boolean historyRecorded = voucherDAO.recordVoucherUsage(voucherID, customerID, orderID, voucherDiscount);
                    
                    // Increment used count
                    boolean countIncremented = voucherDAO.incrementUsedCount(voucherID);
                    
                    if (historyRecorded && countIncremented) {
                        System.out.println("✅ Voucher usage recorded successfully for OrderID: " + orderID);
                    } else {
                        System.err.println("⚠️ Failed to record voucher usage for OrderID: " + orderID);
                    }
                } catch (Exception e) {
                    System.err.println("❌ Error recording voucher usage: " + e.getMessage());
                    e.printStackTrace();
                    // Don't fail the order, just log the error
                }
            }
            
            // Create Shipping record with carrier info from checkout
            Shipping shipping = new Shipping();
            shipping.setOrderID(orderID);
            shipping.setRateID(rateID);
            shipping.setShippingFee(shippingFee);
            shipping.setEstimatedDelivery(estimatedDelivery);
            shipping.setGoshipCarrierId(goshipCarrierId);  // Lưu Goship carrier ID để dùng khi tạo vận đơn
            shipping.setCarrierName(carrierName);          // Lưu tên đơn vị vận chuyển
            shippingDAO.createShipping(shipping);
            
            // ===== TỰ ĐỘNG PHÂN CÔNG SELLER =====
            try {
                Employee seller = orderDAO.getSellerWithLeastActiveOrders();
                if (seller != null) {
                    // assignedById = 0 vì là hệ thống tự động phân công
                    orderDAO.assignOrderToSeller(orderID, seller.getEmployeeID(), 0);
                    System.out.println("[Checkout] Auto-assigned order " + orderID + " to seller: " + seller.getFullName());
                }
            } catch (Exception e) {
                System.err.println("[Checkout] Auto-assign seller failed: " + e.getMessage());
            }
            
            // Clear cart after order created (chỉ khi không phải chế độ mua ngay)
            if (!isBuyNowMode && cart != null) {
                cartDAO.clearCart(cart.getCartID());
            }
            
            // Xóa buyNowItem khỏi session nếu là chế độ mua ngay
            if (isBuyNowMode) {
                session.removeAttribute("buyNowItem");
            }

            
            if ("VNPay".equals(paymentMethod)) {
                // Create Payment record with Pending status
                Payment payment = new Payment();
                payment.setOrderID(orderID);
                payment.setAmount(totalAmount);
                payment.setPaymentGateway("VNPay");
                payment.setPaymentStatus("Pending");
                int paymentID = paymentDAO.createPayment(payment);
                
                // Store paymentID in session for callback
                session.setAttribute("pendingPaymentID", paymentID);
                
                // Create VNPay URL
                String returnUrl = config.VNPayConfig.getReturnUrl(request);
                String orderInfo = "Thanh toan don hang " + order.getOrderCode();
                String paymentUrl = vnPayService.createPaymentUrl(
                    request, 
                    order.getOrderCode(), 
                    totalAmount, 
                    orderInfo, 
                    returnUrl
                );
                
                System.out.println("[Checkout] Redirecting to VNPay: " + paymentUrl);
                response.sendRedirect(paymentUrl);
                return;
                
            } else {
                // COD payment - Create Payment record
                Payment payment = new Payment();
                payment.setOrderID(orderID);
                payment.setAmount(totalAmount);
                payment.setPaymentGateway("COD");
                payment.setPaymentStatus("Pending");
                paymentDAO.createPayment(payment);
                
                // Redirect to success page
                response.sendRedirect("checkout-result.jsp?orderCode=" + order.getOrderCode() + "&status=success&method=COD");
                return;
            }
            
        } catch (NumberFormatException e) {
            e.printStackTrace();
            request.setAttribute("error", "Dữ liệu không hợp lệ: " + e.getMessage());
            doGet(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            doGet(request, response);
        }
    }
    
    /**
     * Get default shipping rates when DB/API is unavailable
     */
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
