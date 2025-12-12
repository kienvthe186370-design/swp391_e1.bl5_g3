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
    
    // Related objects
    private ShippingCarrier carrier;
    private ShippingRate rate;

    public Shipping() {
    }

    // Getters and Setters
    public int getShippingID() { return shippingID; }
    public void setShippingID(int shippingID) { this.shippingID = shippingID; }

    public int getOrderID() { return orderID; }
    public void setOrderID(int orderID) { this.orderID = orderID; }

    public Integer getCarrierID() { return carrierID; }
    public void setCarrierID(Integer carrierID) { this.carrierID = carrierID; }

    public Integer getRateID() { return rateID; }
    public void setRateID(Integer rateID) { this.rateID = rateID; }

    public String getTrackingCode() { return trackingCode; }
    public void setTrackingCode(String trackingCode) { this.trackingCode = trackingCode; }

    public BigDecimal getShippingFee() { return shippingFee; }
    public void setShippingFee(BigDecimal shippingFee) { this.shippingFee = shippingFee; }

    public String getEstimatedDelivery() { return estimatedDelivery; }
    public void setEstimatedDelivery(String estimatedDelivery) { this.estimatedDelivery = estimatedDelivery; }

    public Timestamp getShippedDate() { return shippedDate; }
    public void setShippedDate(Timestamp shippedDate) { this.shippedDate = shippedDate; }

    public Timestamp getDeliveredDate() { return deliveredDate; }
    public void setDeliveredDate(Timestamp deliveredDate) { this.deliveredDate = deliveredDate; }

    public ShippingCarrier getCarrier() { return carrier; }
    public void setCarrier(ShippingCarrier carrier) { this.carrier = carrier; }

    public ShippingRate getRate() { return rate; }
    public void setRate(ShippingRate rate) { this.rate = rate; }
}
