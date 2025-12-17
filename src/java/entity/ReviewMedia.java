package entity;

/**
 * Entity class for ReviewMedia table.
 * Stores images attached to product reviews.
 */
public class ReviewMedia {
    
    private int mediaId;
    private int reviewId;
    private String mediaUrl;
    private String mediaType;
    
    // Constructors
    public ReviewMedia() {}
    
    public ReviewMedia(int reviewId, String mediaUrl, String mediaType) {
        this.reviewId = reviewId;
        this.mediaUrl = mediaUrl;
        this.mediaType = mediaType;
    }
    
    public ReviewMedia(int mediaId, int reviewId, String mediaUrl, String mediaType) {
        this.mediaId = mediaId;
        this.reviewId = reviewId;
        this.mediaUrl = mediaUrl;
        this.mediaType = mediaType;
    }
    
    // Getters and Setters
    public int getMediaId() {
        return mediaId;
    }
    
    public void setMediaId(int mediaId) {
        this.mediaId = mediaId;
    }
    
    public int getReviewId() {
        return reviewId;
    }
    
    public void setReviewId(int reviewId) {
        this.reviewId = reviewId;
    }
    
    public String getMediaUrl() {
        return mediaUrl;
    }
    
    public void setMediaUrl(String mediaUrl) {
        this.mediaUrl = mediaUrl;
    }
    
    public String getMediaType() {
        return mediaType;
    }
    
    public void setMediaType(String mediaType) {
        this.mediaType = mediaType;
    }
    
    @Override
    public String toString() {
        return "ReviewMedia{" +
                "mediaId=" + mediaId +
                ", reviewId=" + reviewId +
                ", mediaUrl='" + mediaUrl + '\'' +
                ", mediaType='" + mediaType + '\'' +
                '}';
    }
}
