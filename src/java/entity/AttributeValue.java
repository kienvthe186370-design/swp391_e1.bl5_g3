package entity;

public class AttributeValue {
    private int valueID;
    private int attributeID;
    private String valueName;
    private boolean isActive;

    public AttributeValue() {
    }

    public AttributeValue(int valueID, int attributeID, String valueName, boolean isActive) {
        this.valueID = valueID;
        this.attributeID = attributeID;
        this.valueName = valueName;
        this.isActive = isActive;
    }

    public int getValueID() {
        return valueID;
    }

    public void setValueID(int valueID) {
        this.valueID = valueID;
    }

    public int getAttributeID() {
        return attributeID;
    }

    public void setAttributeID(int attributeID) {
        this.attributeID = attributeID;
    }

    public String getValueName() {
        return valueName;
    }

    public void setValueName(String valueName) {
        this.valueName = valueName;
    }

    public boolean isIsActive() {
        return isActive;
    }

    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
    }
}
