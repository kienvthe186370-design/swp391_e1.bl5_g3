package controller;

import DAO.CustomerDAO;
import DAO.EmployeeDAO;
import utils.ValidationUtil;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;

/**
 * CheckEmailServlet - Servlet kiểm tra email đã tồn tại chưa
 * 
 * Servlet này được gọi qua AJAX để kiểm tra real-time
 * khi user đang nhập email trong form đăng ký
 * 
 * Flow:
 * 1. Nhận email từ request parameter
 * 2. Validate format email
 * 3. Kiểm tra email trong database (Customer và Employee)
 * 4. Trả về JSON response
 * 
 * Response format:
 * {
 *   "valid": true/false,
 *   "exists": true/false,
 *   "message": "Thông báo"
 * }
 */
@WebServlet(name = "CheckEmailServlet", urlPatterns = {"/check-email"})
public class CheckEmailServlet extends HttpServlet {

    /**
     * Xử lý GET request - Kiểm tra email
     * 
     * Parameters:
     * - email: Email cần kiểm tra
     * 
     * Response: JSON
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Set response type là JSON
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        // Lấy email từ parameter
        String email = request.getParameter("email");
        
        // Tạo JSON response object
        JSONObject jsonResponse = new JSONObject();
        
        try {
            // ============================================
            // BƯỚC 1: Validate email format
            // ============================================
            if (email == null || email.trim().isEmpty()) {
                jsonResponse.put("valid", false);
                jsonResponse.put("exists", false);
                jsonResponse.put("message", "Email không được để trống");
                
                sendJsonResponse(response, jsonResponse);
                return;
            }
            
            email = email.trim();
            
            // Kiểm tra format email
            if (!ValidationUtil.isValidEmail(email)) {
                jsonResponse.put("valid", false);
                jsonResponse.put("exists", false);
                jsonResponse.put("message", "Email không đúng định dạng");
                
                sendJsonResponse(response, jsonResponse);
                return;
            }
            
            // ============================================
            // BƯỚC 2: Kiểm tra email đã tồn tại chưa
            // ============================================
            
            // Kiểm tra trong bảng Customers
            CustomerDAO customerDAO = new CustomerDAO();
            boolean existsInCustomers = customerDAO.isEmailExists(email);
            
            // Kiểm tra trong bảng Employees
            EmployeeDAO employeeDAO = new EmployeeDAO();
            boolean existsInEmployees = employeeDAO.isEmailExists(email);
            
            // Nếu email đã tồn tại ở bất kỳ bảng nào
            if (existsInCustomers || existsInEmployees) {
                jsonResponse.put("valid", true);  // Format hợp lệ
                jsonResponse.put("exists", true); // Nhưng đã tồn tại
                jsonResponse.put("message", "Email này đã được đăng ký");
                
                sendJsonResponse(response, jsonResponse);
                return;
            }
            
            // ============================================
            // BƯỚC 3: Email hợp lệ và chưa tồn tại
            // ============================================
            jsonResponse.put("valid", true);
            jsonResponse.put("exists", false);
            jsonResponse.put("message", "Email hợp lệ");
            
            sendJsonResponse(response, jsonResponse);
            
        } catch (Exception e) {
            // Xử lý lỗi
            jsonResponse.put("valid", false);
            jsonResponse.put("exists", false);
            jsonResponse.put("message", "Lỗi kiểm tra email: " + e.getMessage());
            
            sendJsonResponse(response, jsonResponse);
            e.printStackTrace();
        }
    }
    
    /**
     * Gửi JSON response
     * 
     * @param response HttpServletResponse
     * @param jsonObject JSON object cần gửi
     * @throws IOException
     */
    private void sendJsonResponse(HttpServletResponse response, JSONObject jsonObject) 
            throws IOException {
        PrintWriter out = response.getWriter();
        out.print(jsonObject.toString());
        out.flush();
    }
    
    /**
     * POST request cũng xử lý giống GET
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
