package entity;

public class Brand {
    private int brandID;
    private String brandName;
    private String logo;
    private String description;
    private boolean isActive;

    public Brand() {
    }

    public Brand(int brandID, String brandName, String logo, String description, boolean isActive) {
        this.brandID = brandID;
        this.brandName = brandName;
        this.logo = logo;
        this.description = description;
        this.isActive = isActive;
    }

    public int getBrandID() {
        return brandID;
    }

    public void setBrandID(int brandID) {
        this.brandID = brandID;
    }

    public String getBrandName() {
        return brandName;
    }

    public void setBrandName(String brandName) {
        this.brandName = brandName;
    }

    public String getLogo() {
        return logo;
    }

    public void setLogo(String logo) {
        this.logo = logo;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isIsActive() {
        return isActive;
    }

    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
    }
}
