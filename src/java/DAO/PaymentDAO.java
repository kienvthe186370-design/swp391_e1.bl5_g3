package DAO;

import entity.Payment;
import java.math.BigDecimal;
import java.sql.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class PaymentDAO extends DBContext {

    /**
     * Tạo bản ghi payment mới
     */
    public int createPayment(Payment payment) {
        String sql = "INSERT INTO Payments (OrderID, TransactionCode, Amount, PaymentGateway, PaymentStatus, PaymentDate) " +
                     "VALUES (?, ?, ?, ?, ?, GETDATE())";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, payment.getOrderID());
            ps.setString(2, payment.getTransactionCode());
            ps.setBigDecimal(3, payment.getAmount());
            ps.setString(4, payment.getPaymentGateway());
            ps.setString(5, payment.getPaymentStatus());
            
            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            Logger.getLogger(PaymentDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return -1;
    }

    /**
     * Cập nhật trạng thái payment
     */
    public boolean updatePaymentStatus(int paymentID, String status, String transactionCode) {
        String sql = "UPDATE Payments SET PaymentStatus = ?, TransactionCode = ? WHERE PaymentID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ps.setString(2, transactionCode);
            ps.setInt(3, paymentID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            Logger.getLogger(PaymentDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return false;
    }

    /**
     * Lấy payment theo OrderID
     */
    public Payment getPaymentByOrderId(int orderID) {
        String sql = "SELECT * FROM Payments WHERE OrderID = ? ORDER BY PaymentDate DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, orderID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToPayment(rs);
            }
        } catch (SQLException e) {
            Logger.getLogger(PaymentDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return null;
    }

    /**
     * Lấy payment theo TransactionCode
     */
    public Payment getPaymentByTransactionCode(String transactionCode) {
        String sql = "SELECT * FROM Payments WHERE TransactionCode = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, transactionCode);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToPayment(rs);
            }
        } catch (SQLException e) {
            Logger.getLogger(PaymentDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return null;
    }

    private Payment mapResultSetToPayment(ResultSet rs) throws SQLException {
        Payment payment = new Payment();
        payment.setPaymentID(rs.getInt("PaymentID"));
        payment.setOrderID(rs.getInt("OrderID"));
        payment.setTransactionCode(rs.getString("TransactionCode"));
        payment.setAmount(rs.getBigDecimal("Amount"));
        payment.setPaymentGateway(rs.getString("PaymentGateway"));
        payment.setPaymentStatus(rs.getString("PaymentStatus"));
        payment.setPaymentDate(rs.getTimestamp("PaymentDate"));
        return payment;
    }
}
