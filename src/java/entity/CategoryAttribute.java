package entity;

public class CategoryAttribute {
    private int categoryAttributeID;
    private int categoryID;
    private int attributeID;
    private boolean isRequired;
    private int displayOrder;

    public CategoryAttribute() {
    }

    public CategoryAttribute(int categoryAttributeID, int categoryID, int attributeID, boolean isRequired, int displayOrder) {
        this.categoryAttributeID = categoryAttributeID;
        this.categoryID = categoryID;
        this.attributeID = attributeID;
        this.isRequired = isRequired;
        this.displayOrder = displayOrder;
    }

    public int getCategoryAttributeID() {
        return categoryAttributeID;
    }

    public void setCategoryAttributeID(int categoryAttributeID) {
        this.categoryAttributeID = categoryAttributeID;
    }

    public int getCategoryID() {
        return categoryID;
    }

    public void setCategoryID(int categoryID) {
        this.categoryID = categoryID;
    }

    public int getAttributeID() {
        return attributeID;
    }

    public void setAttributeID(int attributeID) {
        this.attributeID = attributeID;
    }

    public boolean isIsRequired() {
        return isRequired;
    }

    public void setIsRequired(boolean isRequired) {
        this.isRequired = isRequired;
    }

    public int getDisplayOrder() {
        return displayOrder;
    }

    public void setDisplayOrder(int displayOrder) {
        this.displayOrder = displayOrder;
    }
}
