package controller;

import DAO.ReviewDAO;
import entity.Customer;
import entity.Review;
import utils.ImageValidator;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@WebServlet(name = "ReviewServlet", urlPatterns = {"/review"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,      // 1 MB
    maxFileSize = 1024 * 1024 * 2,        // 2 MB per file
    maxRequestSize = 1024 * 1024 * 12     // 12 MB total (5 images * 2MB + form data)
)
public class ReviewServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "/img/review/uploads";
    private static final int MAX_IMAGES = 5;
    private ReviewDAO reviewDAO;

    @Override
    public void init() throws ServletException {
        reviewDAO = new ReviewDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String orderDetailIdStr = request.getParameter("orderDetailId");
        if (orderDetailIdStr == null || orderDetailIdStr.isEmpty()) {
            session.setAttribute("error", "Thiếu thông tin đơn hàng");
            response.sendRedirect(request.getContextPath() + "/customer/orders");
            return;
        }
        
        try {
            int orderDetailId = Integer.parseInt(orderDetailIdStr);
            
            if (!reviewDAO.canReview(orderDetailId, customer.getCustomerID())) {
                session.setAttribute("error", "Bạn không thể đánh giá sản phẩm này");
                response.sendRedirect(request.getContextPath() + "/customer/orders");
                return;
            }
            
            Map<String, Object> orderDetail = reviewDAO.getOrderDetailForReview(orderDetailId, customer.getCustomerID());
            
            if (orderDetail == null) {
                session.setAttribute("error", "Không tìm thấy thông tin sản phẩm");
                response.sendRedirect(request.getContextPath() + "/customer/orders");
                return;
            }
            
            request.setAttribute("orderDetail", orderDetail);
            request.getRequestDispatcher("/review.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Thông tin không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/customer/orders");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        int orderDetailId = 0;
        try {
            orderDetailId = Integer.parseInt(request.getParameter("orderDetailId"));
            int productId = Integer.parseInt(request.getParameter("productId"));
            int rating = Integer.parseInt(request.getParameter("rating"));
            String reviewTitle = request.getParameter("reviewTitle");
            String reviewContent = request.getParameter("reviewContent");
            
            // Validate rating
            if (rating < 1 || rating > 5) {
                session.setAttribute("error", "Vui lòng chọn số sao đánh giá (1-5)");
                response.sendRedirect(request.getContextPath() + "/review?orderDetailId=" + orderDetailId);
                return;
            }
            
            // Kiểm tra quyền review
            if (!reviewDAO.canReview(orderDetailId, customer.getCustomerID())) {
                session.setAttribute("error", "Bạn không thể đánh giá sản phẩm này");
                response.sendRedirect(request.getContextPath() + "/customer/orders");
                return;
            }
            
            // Collect and validate images
            List<Part> validImageParts = new ArrayList<>();
            List<String> imageErrors = new ArrayList<>();
            
            for (Part part : request.getParts()) {
                if ("reviewImages".equals(part.getName()) && part.getSize() > 0) {
                    if (validImageParts.size() >= MAX_IMAGES) {
                        break; // Limit to MAX_IMAGES
                    }
                    ImageValidator.ValidationResult result = ImageValidator.validate(part);
                    if (result.isValid()) {
                        validImageParts.add(part);
                    } else {
                        imageErrors.add(result.getError());
                    }
                }
            }
            
            // If there are image validation errors, show first error
            if (!imageErrors.isEmpty() && validImageParts.isEmpty()) {
                session.setAttribute("error", imageErrors.get(0));
                response.sendRedirect(request.getContextPath() + "/review?orderDetailId=" + orderDetailId);
                return;
            }
            
            // Tạo review
            Review review = new Review();
            review.setOrderDetailId(orderDetailId);
            review.setCustomerId(customer.getCustomerID());
            review.setProductId(productId);
            review.setRating(rating);
            review.setReviewTitle(reviewTitle != null ? reviewTitle.trim() : null);
            review.setReviewContent(reviewContent != null ? reviewContent.trim() : null);
            
            int reviewId = reviewDAO.createReview(review);
            
            if (reviewId > 0) {
                // Save images and insert ReviewMedia records
                List<String> imageUploadErrors = new ArrayList<>();
                if (!validImageParts.isEmpty()) {
                    imageUploadErrors = saveReviewImages(reviewId, validImageParts);
                }
                
                if (imageUploadErrors.isEmpty()) {
                    session.setAttribute("success", "Đánh giá của bạn đã được gửi thành công!");
                } else {
                    session.setAttribute("success", "Đánh giá đã được gửi. Lỗi upload ảnh: " + String.join(", ", imageUploadErrors));
                }
                response.sendRedirect(request.getContextPath() + "/my-reviews");
            } else {
                session.setAttribute("error", "Có lỗi xảy ra, vui lòng thử lại");
                response.sendRedirect(request.getContextPath() + "/review?orderDetailId=" + orderDetailId);
            }
            
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Thông tin không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/customer/orders");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/review?orderDetailId=" + orderDetailId);
        }
    }
    
    /**
     * Save review images to server and insert ReviewMedia records
     * @return List of error messages (empty if all successful)
     */
    private List<String> saveReviewImages(int reviewId, List<Part> imageParts) {
        List<String> errors = new ArrayList<>();
        String uploadDir = getServletContext().getRealPath(UPLOAD_DIR);
        
        // Create upload directory if not exists
        File uploadDirFile = new File(uploadDir);
        if (!uploadDirFile.exists()) {
            uploadDirFile.mkdirs();
        }
        
        System.out.println("[ReviewServlet] Saving " + imageParts.size() + " images for reviewId: " + reviewId);
        System.out.println("[ReviewServlet] Upload directory: " + uploadDir);
        
        for (Part part : imageParts) {
            try {
                String imageUrl = saveImage(part, uploadDir);
                System.out.println("[ReviewServlet] Saved image URL: " + imageUrl);
                if (imageUrl != null) {
                    boolean inserted = reviewDAO.insertReviewMedia(reviewId, imageUrl, "photo");
                    System.out.println("[ReviewServlet] Insert to DB result: " + inserted);
                    if (!inserted) {
                        errors.add("Không thể lưu ảnh vào database");
                    }
                }
            } catch (IOException e) {
                errors.add("File: " + e.getMessage());
                System.out.println("[ReviewServlet] Error saving image: " + e.getMessage());
                e.printStackTrace();
            }
        }
        return errors;
    }
    
    /**
     * Save a single image file and return the URL path
     */
    private String saveImage(Part filePart, String uploadDir) throws IOException {
        if (filePart == null || filePart.getSize() == 0) return null;
        
        String originalName = ImageValidator.getFileName(filePart);
        String ext = ImageValidator.getFileExtension(originalName);
        if (!ext.isEmpty()) ext = "." + ext;
        
        String uniqueName = System.currentTimeMillis() + "_" + UUID.randomUUID().toString().substring(0, 8) + ext;
        
        String buildPath = uploadDir + File.separator + uniqueName;
        try (InputStream input = filePart.getInputStream()) {
            Files.copy(input, Paths.get(buildPath), StandardCopyOption.REPLACE_EXISTING);
        }
        
        // Also save to web/ source folder for development
        try {
            String webRoot = getServletContext().getRealPath("/");
            String sourcePath = webRoot.replace("build\\web", "web") + UPLOAD_DIR.substring(1);
            File sourceDir = new File(sourcePath);
            if (!sourceDir.exists()) sourceDir.mkdirs();
            
            try (InputStream input = filePart.getInputStream()) {
                Files.copy(input, Paths.get(sourcePath + File.separator + uniqueName), StandardCopyOption.REPLACE_EXISTING);
            }
        } catch (Exception e) {
            // Ignore errors when saving to source folder
        }
        
        return UPLOAD_DIR + "/" + uniqueName;
    }
}
