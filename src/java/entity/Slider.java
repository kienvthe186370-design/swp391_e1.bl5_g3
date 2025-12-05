/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package entity;

/**
 *
 * @author xuand
 */
public class Slider {
    private int SliderID;
    private String Title;
    private String ImageURL;
    private String LinkURL;
    private int DisplayOrder;
    private String Status;

    public Slider() {
    }

    public Slider(int SliderID, String Title, String ImageURL, String LinkURL, int DisplayOrder, String Status) {
        this.SliderID = SliderID;
        this.Title = Title;
        this.ImageURL = ImageURL;
        this.LinkURL = LinkURL;
        this.DisplayOrder = DisplayOrder;
        this.Status = Status;
    }

    public int getSliderID() {
        return SliderID;
    }

    public void setSliderID(int SliderID) {
        this.SliderID = SliderID;
    }

    public String getTitle() {
        return Title;
    }

    public void setTitle(String Title) {
        this.Title = Title;
    }

    public String getImageURL() {
        return ImageURL;
    }

    public void setImageURL(String ImageURL) {
        this.ImageURL = ImageURL;
    }

    public String getLinkURL() {
        return LinkURL;
    }

    public void setLinkURL(String LinkURL) {
        this.LinkURL = LinkURL;
    }

    public int getDisplayOrder() {
        return DisplayOrder;
    }

    public void setDisplayOrder(int DisplayOrder) {
        this.DisplayOrder = DisplayOrder;
    }

    public String getStatus() {
        return Status;
    }

    public void setStatus(String Status) {
        this.Status = Status;
    }

    @Override
    public String toString() {
        return "Slider{" + "SliderID=" + SliderID + ", Title=" + Title + ", ImageURL=" + ImageURL + ", LinkURL=" + LinkURL + ", DisplayOrder=" + DisplayOrder + ", Status=" + Status + '}';
    }

    
    
}
