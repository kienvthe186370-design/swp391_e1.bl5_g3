package entity;

public class ShippingCarrier {

    private int carrierID;
    private String carrierName;
    private boolean isActive;

    public ShippingCarrier() {
    }

    // Getters and Setters
    public int getCarrierID() {
        return carrierID;
    }

    public void setCarrierID(int carrierID) {
        this.carrierID = carrierID;
    }

    public String getCarrierName() {
        return carrierName;
    }

    public void setCarrierName(String carrierName) {
        this.carrierName = carrierName;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }
}
