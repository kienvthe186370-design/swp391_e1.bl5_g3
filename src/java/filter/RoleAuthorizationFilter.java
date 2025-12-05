package filter;

import entity.Customer;
import entity.Employee;
import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebFilter(filterName = "RoleAuthorizationFilter", urlPatterns = {
    "/customer/*",
    "/seller/*",
    "/seller-manager/*",
    "/admin/*",
    "/AdminLTE-3.2.0/*",
    "/marketer/*",
    "/staff/*"
})
public class RoleAuthorizationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);
        
        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String path = requestURI.substring(contextPath.length());
        
        // Kiểm tra đăng nhập
        if (session == null || (session.getAttribute("customer") == null && session.getAttribute("employee") == null)) {
            httpResponse.sendRedirect(contextPath + "/login");
            return;
        }
        
        // Kiểm tra quyền truy cập
        boolean hasAccess = false;
        
        if (path.startsWith("/customer/")) {
            // Chỉ customer mới được truy cập
            Customer customer = (Customer) session.getAttribute("customer");
            hasAccess = (customer != null);
        } else if (path.startsWith("/seller/")) {
            // Chỉ Seller mới được truy cập
            Employee employee = (Employee) session.getAttribute("employee");
            hasAccess = (employee != null && "Seller".equalsIgnoreCase(employee.getRole()));
        } else if (path.startsWith("/seller-manager/")) {
            // Chỉ SellerManager mới được truy cập
            Employee employee = (Employee) session.getAttribute("employee");
            hasAccess = (employee != null && "SellerManager".equalsIgnoreCase(employee.getRole()));
        } else if (path.startsWith("/admin/") || path.startsWith("/AdminLTE-3.2.0/")) {
            // Chỉ Admin mới được truy cập admin pages và AdminLTE
            Employee employee = (Employee) session.getAttribute("employee");
            hasAccess = (employee != null && "Admin".equalsIgnoreCase(employee.getRole()));
        } else if (path.startsWith("/marketer/")) {
            // Chỉ Marketer mới được truy cập
            Employee employee = (Employee) session.getAttribute("employee");
            hasAccess = (employee != null && "Marketer".equalsIgnoreCase(employee.getRole()));
        } else if (path.startsWith("/staff/")) {
            // Chỉ Staff mới được truy cập
            Employee employee = (Employee) session.getAttribute("employee");
            hasAccess = (employee != null && "Staff".equalsIgnoreCase(employee.getRole()));
        }
        
        if (hasAccess) {
            chain.doFilter(request, response);
        } else {
            // Không có quyền truy cập
            httpResponse.sendRedirect(contextPath + "/access-denied.jsp");
        }
    }

    @Override
    public void destroy() {
    }
}
