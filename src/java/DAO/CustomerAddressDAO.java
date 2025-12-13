package DAO;

import entity.CustomerAddress;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CustomerAddressDAO extends DBContext {

    /**
     * Lấy tất cả địa chỉ của customer
     */
    public List<CustomerAddress> getAddressesByCustomerId(int customerID) {
        List<CustomerAddress> addresses = new ArrayList<>();
        String sql = "SELECT * FROM CustomerAddresses WHERE CustomerID = ? AND IsActive = 1 ORDER BY IsDefault DESC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, customerID);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                addresses.add(mapResultSetToAddress(rs));
            }
        } catch (SQLException e) {
            Logger.getLogger(CustomerAddressDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return addresses;
    }

    /**
     * Lấy địa chỉ theo ID
     */
    public CustomerAddress getAddressById(int addressID) {
        String sql = "SELECT * FROM CustomerAddresses WHERE AddressID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, addressID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToAddress(rs);
            }
        } catch (SQLException e) {
            Logger.getLogger(CustomerAddressDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return null;
    }

    /**
     * Lấy địa chỉ mặc định của customer
     */
    public CustomerAddress getDefaultAddress(int customerID) {
        String sql = "SELECT * FROM CustomerAddresses WHERE CustomerID = ? AND IsDefault = 1 AND IsActive = 1";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, customerID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToAddress(rs);
            }
        } catch (SQLException e) {
            Logger.getLogger(CustomerAddressDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return null;
    }

    /**
     * Thêm địa chỉ mới
     */
    public int addAddress(CustomerAddress address) {
        String sql = "INSERT INTO CustomerAddresses (CustomerID, RecipientName, Phone, Street, Ward, District, City, PostalCode, IsDefault, IsActive) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 1)";
        
        try (Connection conn = getConnection()) {
            // If this is default, unset other defaults first
            if (address.isDefault()) {
                unsetDefaultAddress(conn, address.getCustomerID());
            }
            
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, address.getCustomerID());
                ps.setString(2, address.getRecipientName());
                ps.setString(3, address.getPhone());
                ps.setString(4, address.getStreet());
                ps.setString(5, address.getWard());
                ps.setString(6, address.getDistrict());
                ps.setString(7, address.getCity());
                ps.setString(8, address.getPostalCode());
                ps.setBoolean(9, address.isDefault());
                
                int affectedRows = ps.executeUpdate();
                if (affectedRows > 0) {
                    ResultSet generatedKeys = ps.getGeneratedKeys();
                    if (generatedKeys.next()) {
                        return generatedKeys.getInt(1);
                    }
                }
            }
        } catch (SQLException e) {
            Logger.getLogger(CustomerAddressDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return -1;
    }

    /**
     * Cập nhật địa chỉ
     */
    public boolean updateAddress(CustomerAddress address) {
        String sql = "UPDATE CustomerAddresses SET RecipientName = ?, Phone = ?, Street = ?, Ward = ?, " +
                     "District = ?, City = ?, PostalCode = ?, IsDefault = ? WHERE AddressID = ?";
        
        try (Connection conn = getConnection()) {
            // If this is default, unset other defaults first
            if (address.isDefault()) {
                unsetDefaultAddress(conn, address.getCustomerID());
            }
            
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, address.getRecipientName());
                ps.setString(2, address.getPhone());
                ps.setString(3, address.getStreet());
                ps.setString(4, address.getWard());
                ps.setString(5, address.getDistrict());
                ps.setString(6, address.getCity());
                ps.setString(7, address.getPostalCode());
                ps.setBoolean(8, address.isDefault());
                ps.setInt(9, address.getAddressID());
                
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            Logger.getLogger(CustomerAddressDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return false;
    }

    /**
     * Xóa địa chỉ (soft delete)
     */
    public boolean deleteAddress(int addressID) {
        String sql = "UPDATE CustomerAddresses SET IsActive = 0 WHERE AddressID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, addressID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            Logger.getLogger(CustomerAddressDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return false;
    }

    /**
     * Set địa chỉ làm mặc định
     */
    public boolean setDefaultAddress(int customerID, int addressID) {
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Unset all defaults
                unsetDefaultAddress(conn, customerID);
                
                // Set new default
                String sql = "UPDATE CustomerAddresses SET IsDefault = 1 WHERE AddressID = ? AND CustomerID = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, addressID);
                    ps.setInt(2, customerID);
                    ps.executeUpdate();
                }
                
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            Logger.getLogger(CustomerAddressDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return false;
    }

    private void unsetDefaultAddress(Connection conn, int customerID) throws SQLException {
        String sql = "UPDATE CustomerAddresses SET IsDefault = 0 WHERE CustomerID = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerID);
            ps.executeUpdate();
        }
    }

    private CustomerAddress mapResultSetToAddress(ResultSet rs) throws SQLException {
        CustomerAddress address = new CustomerAddress();
        address.setAddressID(rs.getInt("AddressID"));
        address.setCustomerID(rs.getInt("CustomerID"));
        address.setRecipientName(rs.getString("RecipientName"));
        address.setPhone(rs.getString("Phone"));
        address.setStreet(rs.getString("Street"));
        address.setWard(rs.getString("Ward"));
        address.setDistrict(rs.getString("District"));
        address.setCity(rs.getString("City"));
        address.setPostalCode(rs.getString("PostalCode"));
        address.setDefault(rs.getBoolean("IsDefault"));
        address.setActive(rs.getBoolean("IsActive"));
        return address;
    }
}
