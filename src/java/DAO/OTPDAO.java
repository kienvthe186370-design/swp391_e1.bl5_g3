package DAO;

import entity.OTPCode;
import java.sql.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class OTPDAO extends DBContext {

    public boolean saveOTP(String email, String otpCode, String otpType, Timestamp expiry) {
        String sql = "INSERT INTO OTPCodes (Email, OTPCode, OTPType, ExpiresAt, IsUsed, Attempts) "
                + "VALUES (?, ?, ?, ?, 0, 0)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, otpCode);
            ps.setString(3, otpType);
            ps.setTimestamp(4, expiry);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            Logger.getLogger(OTPDAO.class.getName()).log(Level.SEVERE, null, e);
            return false;
        }
    }

    public OTPCode getOTP(String email, String otpType) {
        String sql = "SELECT TOP 1 * FROM OTPCodes "
                + "WHERE Email = ? AND OTPType = ? AND IsUsed = 0 "
                + "ORDER BY CreatedAt DESC";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, otpType);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapResultSetToOTPCode(rs);
            }
        } catch (SQLException e) {
            Logger.getLogger(OTPDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return null;
    }

    public OTPCode getOTPById(int otpId) {
        String sql = "SELECT * FROM OTPCodes WHERE OTPID = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, otpId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapResultSetToOTPCode(rs);
            }
        } catch (SQLException e) {
            Logger.getLogger(OTPDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return null;
    }

    public boolean markAsUsed(int otpId) {
        String sql = "UPDATE OTPCodes SET IsUsed = 1 WHERE OTPID = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, otpId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            Logger.getLogger(OTPDAO.class.getName()).log(Level.SEVERE, null, e);
            return false;
        }
    }

    public boolean incrementAttempts(int otpId) {
        String sql = "UPDATE OTPCodes SET Attempts = Attempts + 1 WHERE OTPID = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, otpId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            Logger.getLogger(OTPDAO.class.getName()).log(Level.SEVERE, null, e);
            return false;
        }
    }

    public boolean invalidateOldOTPs(String email, String otpType) {
        String sql = "UPDATE OTPCodes SET IsUsed = 1 WHERE Email = ? AND OTPType = ? AND IsUsed = 0";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, otpType);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            Logger.getLogger(OTPDAO.class.getName()).log(Level.SEVERE, null, e);
            return false;
        }
    }

    public Timestamp getLastOTPTime(String email, String otpType) {
        String sql = "SELECT TOP 1 CreatedAt FROM OTPCodes "
                + "WHERE Email = ? AND OTPType = ? "
                + "ORDER BY CreatedAt DESC";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, otpType);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getTimestamp("CreatedAt");
            }
        } catch (SQLException e) {
            Logger.getLogger(OTPDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return null;
    }

    private OTPCode mapResultSetToOTPCode(ResultSet rs) throws SQLException {
        OTPCode otp = new OTPCode();
        otp.setOtpId(rs.getInt("OTPID"));
        otp.setEmail(rs.getString("Email"));
        otp.setOtpCode(rs.getString("OTPCode"));
        otp.setOtpType(rs.getString("OTPType"));
        otp.setCreatedAt(rs.getTimestamp("CreatedAt"));
        otp.setExpiresAt(rs.getTimestamp("ExpiresAt"));
        otp.setUsed(rs.getBoolean("IsUsed"));
        otp.setAttempts(rs.getInt("Attempts"));
        return otp;
    }
}
