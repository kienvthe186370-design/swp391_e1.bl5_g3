package filter;

import entity.Employee;
import utils.RolePermission;
import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebFilter(filterName = "AdminAuthFilter", urlPatterns = {"/admin/*"})
public class AdminAuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        if (session == null) {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
            return;
        }

        Employee employee = (Employee) session.getAttribute("employee");
        if (employee == null) {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
            return;
        }

        // Chuẩn hóa path cho phân quyền: phần sau "/admin"
        String uri = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String base = contextPath + "/admin";
        String path = uri.startsWith(base) ? uri.substring(base.length()) : httpRequest.getPathInfo();
        if (path == null || path.isEmpty()) {
            path = "/dashboard";
        }

        String role = employee.getRole();
        
        // Shipper được vào admin dashboard và các trang shipper
        // Không cần redirect riêng nữa
        
        if (!RolePermission.hasPermission(role, path)) {
            session.setAttribute("accessDeniedMessage", "Bạn không có quyền truy cập chức năng này");
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/admin/dashboard");
            return;
        }
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
