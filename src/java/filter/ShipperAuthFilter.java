package filter;

import entity.Employee;
import utils.RolePermission;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Filter redirect /shipper/* về admin (đã tích hợp vào AdminLTE)
 */
@WebFilter(filterName = "ShipperAuthFilter", urlPatterns = {"/shipper/*"})
public class ShipperAuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        // Redirect tất cả /shipper/* về admin/orders?action=shipperOrders
        httpResponse.sendRedirect(httpRequest.getContextPath() + "/admin/orders?action=shipperOrders");
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void destroy() {}
}
