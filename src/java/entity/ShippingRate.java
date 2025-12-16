package entity;

import java.math.BigDecimal;

public class ShippingRate {

    private int rateID;           // DB RateID (int)
    private int carrierIDInt;     // DB CarrierID (int)
    private String carrierId;     // Goship rate ID (string)
    private String carrierName;
    private String serviceName;
    private BigDecimal basePrice;
    private String estimatedDelivery;
    private boolean isActive;

    // From Goship API
    private String carrierLogo;
    private String carrierShortName;

    // Related object for DB
    private ShippingCarrier carrier;

    public ShippingRate() {
    }

    // Getters and Setters - DB style (uppercase ID)
    public int getRateID() {
        return rateID;
    }

    public void setRateID(int rateID) {
        this.rateID = rateID;
    }

    public int getCarrierID() {
        return carrierIDInt;
    }

    public void setCarrierID(int carrierID) {
        this.carrierIDInt = carrierID;
    }

    // Getters and Setters - Goship API style (lowercase Id)
    public int getRateId() {
        return rateID;
    }

    public void setRateId(int rateId) {
        this.rateID = rateId;
    }

    public String getCarrierId() {
        return carrierId;
    }

    public void setCarrierId(String carrierId) {
        this.carrierId = carrierId;
    }

    public String getCarrierName() {
        return carrierName;
    }

    public void setCarrierName(String carrierName) {
        this.carrierName = carrierName;
    }

    public String getServiceName() {
        return serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }

    public BigDecimal getBasePrice() {
        return basePrice;
    }

    public void setBasePrice(BigDecimal basePrice) {
        this.basePrice = basePrice;
    }

    public String getEstimatedDelivery() {
        return estimatedDelivery;
    }

    public void setEstimatedDelivery(String estimatedDelivery) {
        this.estimatedDelivery = estimatedDelivery;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean isActive) {
        this.isActive = isActive;
    }

    public String getCarrierLogo() {
        return carrierLogo;
    }

    public void setCarrierLogo(String carrierLogo) {
        this.carrierLogo = carrierLogo;
    }

    public String getCarrierShortName() {
        return carrierShortName;
    }

    public void setCarrierShortName(String carrierShortName) {
        this.carrierShortName = carrierShortName;
    }

    // Carrier object for DB relations
    public ShippingCarrier getCarrier() {
        return carrier;
    }

    public void setCarrier(ShippingCarrier carrier) {
        this.carrier = carrier;
        if (carrier != null) {
            this.carrierName = carrier.getCarrierName();
        }
    }
}
