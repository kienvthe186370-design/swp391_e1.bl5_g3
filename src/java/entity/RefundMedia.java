package entity;

/**
 * Entity cho hình ảnh/video đính kèm yêu cầu hoàn tiền
 */
public class RefundMedia {
    private int mediaID;
    private int refundRequestID;
    private String mediaURL;
    private String mediaType; // image, video

    public RefundMedia() {}

    // Getters and Setters
    public int getMediaID() { return mediaID; }
    public void setMediaID(int mediaID) { this.mediaID = mediaID; }

    public int getRefundRequestID() { return refundRequestID; }
    public void setRefundRequestID(int refundRequestID) { this.refundRequestID = refundRequestID; }

    public String getMediaURL() { return mediaURL; }
    public void setMediaURL(String mediaURL) { this.mediaURL = mediaURL; }

    public String getMediaType() { return mediaType; }
    public void setMediaType(String mediaType) { this.mediaType = mediaType; }
}
