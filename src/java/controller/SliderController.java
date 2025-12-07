package controller;

import DAO.SliderDAO;
import entity.Slider;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;

/**
 * Slider Management Controller
 * Handles CRUD operations for sliders
 */
@WebServlet(name="SliderController", urlPatterns={"/admin/slider"})
public class SliderController extends HttpServlet {
   
    private SliderDAO sliderDAO;
    
    @Override
    public void init() throws ServletException {
        sliderDAO = new SliderDAO();
        }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if (action == null) {
            action = "list";
    } 

        switch (action) {
            case "list":
                showSliderList(request, response);
                break;
            case "add":
                showAddForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                deleteSlider(request, response);
                break;
            default:
                showSliderList(request, response);
                break;
        }
    } 

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        
        if ("add".equals(action)) {
            addSlider(request, response);
        } else if ("update".equals(action)) {
            updateSlider(request, response);
        }
    }
    
    // Show slider list with pagination and search
    private void showSliderList(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        String search = request.getParameter("search");
        String status = request.getParameter("status");
        String pageStr = request.getParameter("page");
        
        int page = 1;
        int pageSize = 10;
        
        if (pageStr != null) {
            try {
                page = Integer.parseInt(pageStr);
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        
        List<Slider> sliders = sliderDAO.getAllSliders(search, status, page, pageSize);
        int totalSliders = sliderDAO.getTotalSliders(search, status);
        int totalPages = (int) Math.ceil((double) totalSliders / pageSize);
        
        request.setAttribute("sliders", sliders);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("search", search);
        request.setAttribute("status", status);
        
        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-slider-list.jsp").forward(request, response);
    }
    
    // Show add slider form
    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        request.getRequestDispatcher("/AdminLTE-3.2.0/admin-slider-detail.jsp").forward(request, response);
    }
    
    // Show edit slider form
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Slider slider = sliderDAO.getSliderById(id);
        
        if (slider != null) {
            request.setAttribute("slider", slider);
            request.getRequestDispatcher("/AdminLTE-3.2.0/admin-slider-detail.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/slider?error=notfound");
        }
    }
    
    // Add new slider
    private void addSlider(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        String title = request.getParameter("title");
        String imageURL = request.getParameter("imageURL");
        String linkURL = request.getParameter("linkURL");
        int displayOrder = Integer.parseInt(request.getParameter("displayOrder"));
        String status = request.getParameter("status");
        
        Slider slider = new Slider();
        slider.setTitle(title);
        slider.setImageURL(imageURL);
        slider.setLinkURL(linkURL);
        slider.setDisplayOrder(displayOrder);
        slider.setStatus(status);
        
        sliderDAO.insertSlider(slider);
        
        response.sendRedirect(request.getContextPath() + "/admin/slider?success=added");
    }
    
    // Update slider
    private void updateSlider(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        String title = request.getParameter("title");
        String imageURL = request.getParameter("imageURL");
        String linkURL = request.getParameter("linkURL");
        int displayOrder = Integer.parseInt(request.getParameter("displayOrder"));
        String status = request.getParameter("status");
        
        Slider slider = new Slider();
        slider.setSliderID(id);
        slider.setTitle(title);
        slider.setImageURL(imageURL);
        slider.setLinkURL(linkURL);
        slider.setDisplayOrder(displayOrder);
        slider.setStatus(status);
        
        sliderDAO.updateSlider(slider);
        
        response.sendRedirect(request.getContextPath() + "/admin/slider?success=updated");
    }
    
    // Delete slider
    private void deleteSlider(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        sliderDAO.deleteSlider(id);
        
        response.sendRedirect(request.getContextPath() + "/admin/slider?success=deleted");
    }

    @Override
    public String getServletInfo() {
        return "Slider Management Controller";
}
}
