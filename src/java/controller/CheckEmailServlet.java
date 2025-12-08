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

@WebServlet(name = "CheckEmailServlet", urlPatterns = {"/check-email"})
public class CheckEmailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        String email = request.getParameter("email");
        JSONObject jsonResponse = new JSONObject();

        try {
            if (email == null || email.trim().isEmpty()) {
                jsonResponse.put("valid", false);
                jsonResponse.put("exists", false);
                jsonResponse.put("message", "Email không được để trống");
                sendJsonResponse(response, jsonResponse);
                return;
            }
            email = email.trim();

            if (!ValidationUtil.isValidEmail(email)) {
                jsonResponse.put("valid", false);
                jsonResponse.put("exists", false);
                jsonResponse.put("message", "Email không đúng định dạng");

                sendJsonResponse(response, jsonResponse);
                return;
            }

            CustomerDAO customerDAO = new CustomerDAO();
            boolean existsInCustomers = customerDAO.isEmailExists(email);

            EmployeeDAO employeeDAO = new EmployeeDAO();
            boolean existsInEmployees = employeeDAO.isEmailExists(email);

            if (existsInCustomers || existsInEmployees) {
                jsonResponse.put("valid", true);
                jsonResponse.put("exists", true);
                jsonResponse.put("message", "Email này đã được đăng ký");

                sendJsonResponse(response, jsonResponse);
                return;
            }

            jsonResponse.put("valid", true);
            jsonResponse.put("exists", false);
            jsonResponse.put("message", "Email hợp lệ");

            sendJsonResponse(response, jsonResponse);

        } catch (Exception e) {
            jsonResponse.put("valid", false);
            jsonResponse.put("exists", false);
            jsonResponse.put("message", "Lỗi kiểm tra email: " + e.getMessage());

            sendJsonResponse(response, jsonResponse);
            e.printStackTrace();
        }
    }

    private void sendJsonResponse(HttpServletResponse response, JSONObject jsonObject)
            throws IOException {
        PrintWriter out = response.getWriter();
        out.print(jsonObject.toString());
        out.flush();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
