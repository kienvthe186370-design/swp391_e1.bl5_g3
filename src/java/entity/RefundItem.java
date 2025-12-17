package entity;

/**
 * Entity cho chi tiết sản phẩm trong yêu cầu hoàn tiền
 */
public class RefundItem {
    private int refundItemID;
    private int refundRequestID;
    private int orderDetailID;
    private int quantity;
    private String itemReason;
    
    // Relationship
    private OrderDetail orderDetail;

    public RefundItem() {}

    // Getters and Setters
    public int getRefundItemID() { return refundItemID; }
    public void setRefundItemID(int refundItemID) { this.refundItemID = refundItemID; }

    public int getRefundRequestID() { return refundRequestID; }
    public void setRefundRequestID(int refundRequestID) { this.refundRequestID = refundRequestID; }

    public int getOrderDetailID() { return orderDetailID; }
    public void setOrderDetailID(int orderDetailID) { this.orderDetailID = orderDetailID; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public String getItemReason() { return itemReason; }
    public void setItemReason(String itemReason) { this.itemReason = itemReason; }

    public OrderDetail getOrderDetail() { return orderDetail; }
    public void setOrderDetail(OrderDetail orderDetail) { this.orderDetail = orderDetail; }
}
