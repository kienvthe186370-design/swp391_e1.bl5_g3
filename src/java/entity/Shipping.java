package entity;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Shipping {

    private int shippingID;
    private int orderID;
    private Integer carrierID;
    private Integer rateID;
    private String trackingCode;
    private BigDecimal shippingFee;
    private String estimatedDelivery;
    private Timestamp shippedDate;
    private Timestamp deliveredDate;
    private String goshipOrderCode;
    private String goshipStatus;
    private String goshipCarrierId;  // Carrier ID từ Goship mà khách đã chọn khi checkout
    private String carrierName;      // Tên đơn vị vận chuyển
    private Integer shipperID;       // ID của shipper được phân công

    // Related objects
    private ShippingCarrier carrier;
    private ShippingRate rate;
    private Employee shipper;        // Shipper được phân công
    
    // Temporary fields for display (from JOIN queries)
    private String orderCode;
    private String orderStatus;
    private BigDecimal totalAmount;
    private String paymentMethod;
    private String paymentStatus;
    private CustomerAddress address;  // Địa chỉ giao hàng
    private String shipperName;       // Tên shipper (từ JOIN)

    public Shipping() {
    }

    // Getters and Setters
    public int getShippingID() {
        return shippingID;
    }

    public void setShippingID(int shippingID) {
        this.shippingID = shippingID;
    }

    public int getOrderID() {
        return orderID;
    }

    public void setOrderID(int orderID) {
        this.orderID = orderID;
    }

    public Integer getCarrierID() {
        return carrierID;
    }

    public void setCarrierID(Integer carrierID) {
        this.carrierID = carrierID;
    }

    public Integer getRateID() {
        return rateID;
    }

    public void setRateID(Integer rateID) {
        this.rateID = rateID;
    }

    public String getTrackingCode() {
        return trackingCode;
    }

    public void setTrackingCode(String trackingCode) {
        this.trackingCode = trackingCode;
    }

    public BigDecimal getShippingFee() {
        return shippingFee;
    }

    public void setShippingFee(BigDecimal shippingFee) {
        this.shippingFee = shippingFee;
    }

    public String getEstimatedDelivery() {
        return estimatedDelivery;
    }

    public void setEstimatedDelivery(String estimatedDelivery) {
        this.estimatedDelivery = estimatedDelivery;
    }

    public Timestamp getShippedDate() {
        return shippedDate;
    }

    public void setShippedDate(Timestamp shippedDate) {
        this.shippedDate = shippedDate;
    }

    public Timestamp getDeliveredDate() {
        return deliveredDate;
    }

    public void setDeliveredDate(Timestamp deliveredDate) {
        this.deliveredDate = deliveredDate;
    }

    public ShippingCarrier getCarrier() {
        return carrier;
    }

    public void setCarrier(ShippingCarrier carrier) {
        this.carrier = carrier;
    }

    public ShippingRate getRate() {
        return rate;
    }

    public void setRate(ShippingRate rate) {
        this.rate = rate;
    }

    public String getGoshipOrderCode() {
        return goshipOrderCode;
    }

    public void setGoshipOrderCode(String goshipOrderCode) {
        this.goshipOrderCode = goshipOrderCode;
    }

    public String getGoshipStatus() {
        return goshipStatus;
    }

    public void setGoshipStatus(String goshipStatus) {
        this.goshipStatus = goshipStatus;
    }

    public String getGoshipCarrierId() {
        return goshipCarrierId;
    }

    public void setGoshipCarrierId(String goshipCarrierId) {
        this.goshipCarrierId = goshipCarrierId;
    }

    public String getCarrierName() {
        return carrierName;
    }

    public void setCarrierName(String carrierName) {
        this.carrierName = carrierName;
    }

    public Integer getShipperID() {
        return shipperID;
    }

    public void setShipperID(Integer shipperID) {
        this.shipperID = shipperID;
    }

    public Employee getShipper() {
        return shipper;
    }

    public void setShipper(Employee shipper) {
        this.shipper = shipper;
    }
    
    // Temporary getters/setters for display
    public String getOrderCode() {
        return orderCode;
    }

    public void setOrderCode(String orderCode) {
        this.orderCode = orderCode;
    }

    public String getOrderStatus() {
        return orderStatus;
    }

    public void setOrderStatus(String orderStatus) {
        this.orderStatus = orderStatus;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public CustomerAddress getAddress() {
        return address;
    }

    public void setAddress(CustomerAddress address) {
        this.address = address;
    }

    public String getShipperName() {
        return shipperName;
    }

    public void setShipperName(String shipperName) {
        this.shipperName = shipperName;
    }
}
