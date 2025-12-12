package controller;

import entity.Customer;
import entity.CustomerAddress;
import DAO.CustomerAddressDAO;
import java.io.IOException;
import java.net.URLEncoder;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "AddressServlet", urlPatterns = {"/address"})
public class AddressServlet extends HttpServlet {

    private CustomerAddressDAO addressDAO = new CustomerAddressDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        String redirectUrl = request.getContextPath() + "/profile?tab=addresses";
        
        try {
            if ("setDefault".equals(action)) {
                int addressId = Integer.parseInt(request.getParameter("addressId"));
                boolean success = addressDAO.setDefaultAddress(customer.getCustomerID(), addressId);
                if (success) {
                    redirectUrl += "&success=" + URLEncoder.encode("Đã đặt địa chỉ mặc định", "UTF-8");
                } else {
                    redirectUrl += "&error=" + URLEncoder.encode("Không thể đặt địa chỉ mặc định", "UTF-8");
                }
            } else if ("delete".equals(action)) {
                int addressId = Integer.parseInt(request.getParameter("addressId"));
                // Verify ownership
                CustomerAddress addr = addressDAO.getAddressById(addressId);
                if (addr != null && addr.getCustomerID() == customer.getCustomerID()) {
                    boolean success = addressDAO.deleteAddress(addressId);
                    if (success) {
                        redirectUrl += "&success=" + URLEncoder.encode("Đã xóa địa chỉ", "UTF-8");
                    } else {
                        redirectUrl += "&error=" + URLEncoder.encode("Không thể xóa địa chỉ", "UTF-8");
                    }
                } else {
                    redirectUrl += "&error=" + URLEncoder.encode("Địa chỉ không hợp lệ", "UTF-8");
                }
            }
        } catch (Exception e) {
            redirectUrl += "&error=" + URLEncoder.encode("Có lỗi xảy ra: " + e.getMessage(), "UTF-8");
        }
        
        response.sendRedirect(redirectUrl);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        String redirectUrl = request.getContextPath() + "/profile?tab=addresses";
        
        try {
            if ("add".equals(action)) {
                CustomerAddress address = new CustomerAddress();
                address.setCustomerID(customer.getCustomerID());
                address.setRecipientName(request.getParameter("recipientName"));
                address.setPhone(request.getParameter("phone"));
                address.setStreet(request.getParameter("street"));
                address.setWard(request.getParameter("ward"));
                address.setDistrict(request.getParameter("district"));
                address.setCity(request.getParameter("city"));
                address.setDefault("on".equals(request.getParameter("isDefault")));
                
                int newId = addressDAO.addAddress(address);
                if (newId > 0) {
                    redirectUrl += "&success=" + URLEncoder.encode("Đã thêm địa chỉ mới", "UTF-8");
                } else {
                    redirectUrl += "&error=" + URLEncoder.encode("Không thể thêm địa chỉ", "UTF-8");
                }
            } else if ("update".equals(action)) {
                int addressId = Integer.parseInt(request.getParameter("addressId"));
                CustomerAddress address = addressDAO.getAddressById(addressId);
                
                if (address != null && address.getCustomerID() == customer.getCustomerID()) {
                    address.setRecipientName(request.getParameter("recipientName"));
                    address.setPhone(request.getParameter("phone"));
                    address.setStreet(request.getParameter("street"));
                    address.setWard(request.getParameter("ward"));
                    address.setDistrict(request.getParameter("district"));
                    address.setCity(request.getParameter("city"));
                    address.setDefault("on".equals(request.getParameter("isDefault")));
                    
                    boolean success = addressDAO.updateAddress(address);
                    if (success) {
                        redirectUrl += "&success=" + URLEncoder.encode("Đã cập nhật địa chỉ", "UTF-8");
                    } else {
                        redirectUrl += "&error=" + URLEncoder.encode("Không thể cập nhật địa chỉ", "UTF-8");
                    }
                } else {
                    redirectUrl += "&error=" + URLEncoder.encode("Địa chỉ không hợp lệ", "UTF-8");
                }
            }
        } catch (Exception e) {
            redirectUrl += "&error=" + URLEncoder.encode("Có lỗi xảy ra: " + e.getMessage(), "UTF-8");
        }
        
        response.sendRedirect(redirectUrl);
    }
}
