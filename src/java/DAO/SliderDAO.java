/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package DAO;

import entity.Slider;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
/**
 *
 * @author xuand
 */


public class SliderDAO extends DBContext {

    public List<Slider> getActiveSliders() {
        List<Slider> list = new ArrayList<>();

        String sql = """
            SELECT SliderID, Title, ImageURL, LinkURL, DisplayOrder, Status
            FROM Sliders
            WHERE Status = 'active'
            ORDER BY DisplayOrder ASC
        """;

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Slider s = new Slider();
                s.setSliderID(rs.getInt("SliderID"));
                s.setTitle(rs.getString("Title"));
                s.setImageURL(rs.getString("ImageURL"));
                s.setLinkURL(rs.getString("LinkURL"));
                s.setDisplayOrder(rs.getInt("DisplayOrder"));
                s.setStatus(rs.getString("Status"));
                

                list.add(s);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
    
    public List<Slider> getTop5Sliders() {
    List<Slider> list = new ArrayList<>();
    String sql = "SELECT TOP 5 * FROM Sliders WHERE Status = 'active' ORDER BY displayOrder ASC";

    try (Connection connection = getConnection();
            PreparedStatement ps = connection.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {

        while (rs.next()) {
            Slider s = new Slider();
                s.setSliderID(rs.getInt("SliderID"));
                s.setTitle(rs.getString("Title"));
                s.setImageURL(rs.getString("ImageURL"));
                s.setLinkURL(rs.getString("LinkURL"));
                s.setDisplayOrder(rs.getInt("DisplayOrder"));
                s.setStatus(rs.getString("Status"));
                

                list.add(s);
        }

    } catch (SQLException ex) {
        ex.printStackTrace();
    }

    return list;
}
    public void insertSlider(Slider s){
        String sql = "INSERT INTO Sliders (title, imageurl, linkurl, displayorder, status) VALUES (?, ?, ?, ?, ?)";
        try(Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)){
            ps.setString(1, s.getTitle());
ps.setString(2, s.getImageURL());
ps.setString(3, s.getLinkURL());
ps.setInt(4, s.getDisplayOrder());      
ps.setString(5, s.getStatus()); 
            ps.executeUpdate();
            
        }catch (SQLException ex) {
        System.out.println("Error in insertSlider: " + ex.getMessage());
    }

    }
    
    public void updateSlider(Slider s){
        String sql = "UPDATE Sliders SET title=?, imageurl=?, linkurl=?, displayOrder=?, status=? WHERE sliderID=?";

        try(Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)){
            ps.setString(1, s.getTitle());
            ps.setString(2, s.getImageURL());
            ps.setString(3, s.getLinkURL());
            ps.setString(4, s.getStatus());
            ps.setInt(5, s.getDisplayOrder());
            ps.setInt(6, s.getSliderID());
            ps.executeUpdate();
            
        }catch (SQLException ex) {
        System.out.println("Error in updateSlider: " + ex.getMessage());
    }
    }
    
    public void deleteSlider(int id){
        String sql = "DELETE FROM Sliders WHERE sliderID = ?";
        try(Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();

        }catch (SQLException ex) {
        System.out.println("Error in deleteSlider: " + ex.getMessage());
                
    }

}
    // Get all sliders with pagination and search
    public List<Slider> getAllSliders(String search, String status, int page, int pageSize) {
        List<Slider> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT SliderID, Title, ImageURL, LinkURL, DisplayOrder, Status FROM Sliders WHERE 1=1");
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND Title LIKE ?");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND Status = ?");
        }
        
        sql.append(" ORDER BY DisplayOrder ASC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            if (search != null && !search.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + search + "%");
            }
            if (status != null && !status.trim().isEmpty()) {
                ps.setString(paramIndex++, status);
            }
            ps.setInt(paramIndex++, (page - 1) * pageSize);
            ps.setInt(paramIndex++, pageSize);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Slider s = new Slider();
                s.setSliderID(rs.getInt("SliderID"));
                s.setTitle(rs.getString("Title"));
                s.setImageURL(rs.getString("ImageURL"));
                s.setLinkURL(rs.getString("LinkURL"));
                s.setDisplayOrder(rs.getInt("DisplayOrder"));
                s.setStatus(rs.getString("Status"));
                list.add(s);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    // Get total count for pagination
    public int getTotalSliders(String search, String status) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Sliders WHERE 1=1");
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND Title LIKE ?");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND Status = ?");
        }
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            if (search != null && !search.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + search + "%");
            }
            if (status != null && !status.trim().isEmpty()) {
                ps.setString(paramIndex++, status);
            }
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    // Get slider by ID
    public Slider getSliderById(int id) {
        String sql = "SELECT SliderID, Title, ImageURL, LinkURL, DisplayOrder, Status FROM Sliders WHERE SliderID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                Slider s = new Slider();
                s.setSliderID(rs.getInt("SliderID"));
                s.setTitle(rs.getString("Title"));
                s.setImageURL(rs.getString("ImageURL"));
                s.setLinkURL(rs.getString("LinkURL"));
                s.setDisplayOrder(rs.getInt("DisplayOrder"));
                s.setStatus(rs.getString("Status"));
                return s;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
    

