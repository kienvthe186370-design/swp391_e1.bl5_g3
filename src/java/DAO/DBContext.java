/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package DAO;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DBContext {
    private static final String URL = "jdbc:sqlserver://localhost:1433;databaseName=PickleballShop1";
    private static final String USER = "sa";
    private static final String PASSWORD = "123";
    public Connection getConnection() {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            return DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (ClassNotFoundException | SQLException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, null, ex);
            return null;
        }
    }
public static void main(String[] args) {
        // Tạo đối tượng DBContext
        DBContext dbContext = new DBContext();
        
        // Gọi hàm getConnection
        Connection conn = dbContext.getConnection();

        // Kiểm tra kết quả
        if (conn != null) {
            System.out.println("--------------------------------");
            System.out.println("KẾT NỐI THÀNH CÔNG! (Connection Successful)");
            System.out.println("Object Connection: " + conn);
            System.out.println("--------------------------------");
        } else {
            System.out.println("--------------------------------");
            System.out.println("KẾT NỐI THẤT BẠI! (Connection Failed)");
            System.out.println("Vui lòng kiểm tra lại Username, Password, tên Database hoặc TCP/IP config.");
            System.out.println("--------------------------------");
        }
    }
     
}
