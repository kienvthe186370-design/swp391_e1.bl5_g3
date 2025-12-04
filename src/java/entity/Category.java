package entity;

public class Category {
    private int categoryID;
    private String categoryName;
    private String description;
    private String icon;
    private int displayOrder;
    private boolean isActive;

    public Category() {
    }

    public Category(int categoryID, String categoryName, String description, String icon, int displayOrder, boolean isActive) {
        this.categoryID = categoryID;
        this.categoryName = categoryName;
        this.description = description;
        this.icon = icon;
        this.displayOrder = displayOrder;
        this.isActive = isActive;
    }

    public int getCategoryID() {
        return categoryID;
    }

    public void setCategoryID(int categoryID) {
        this.categoryID = categoryID;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getIcon() {
        return icon;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public int getDisplayOrder() {
        return displayOrder;
    }

    public void setDisplayOrder(int displayOrder) {
        this.displayOrder = displayOrder;
    }

    public boolean isIsActive() {
        return isActive;
    }

    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
    }
}
