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
    
}
    

