package entity;

public class ProductAttribute {

    private int attributeID;
    private String attributeName;
    private boolean isActive;

    public ProductAttribute() {
    }

    public ProductAttribute(int attributeID, String attributeName, boolean isActive) {
        this.attributeID = attributeID;
        this.attributeName = attributeName;
        this.isActive = isActive;
    }

    public int getAttributeID() {
        return attributeID;
    }

    public void setAttributeID(int attributeID) {
        this.attributeID = attributeID;
    }

    public String getAttributeName() {
        return attributeName;
    }

    public void setAttributeName(String attributeName) {
        this.attributeName = attributeName;
    }

    public boolean isIsActive() {
        return isActive;
    }

    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
    }
}
