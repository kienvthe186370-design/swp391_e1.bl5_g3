package DAO;

import entity.BlogPost;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho quản lý Blog (F21).
 */
public class BlogPostDAO {

    private final DBContext db = new DBContext();

    public List<BlogPost> search(String keyword, String status) throws SQLException {
        List<BlogPost> list = new ArrayList<>();
        String sql = """
                SELECT  p.PostID, p.Title, p.Slug, p.FeaturedImage, p.Summary, p.Status, p.PublishedDate,
                        p.ViewCount, p.CreatedDate, p.UpdatedDate,
                        e.FullName AS AuthorName
                FROM    BlogPosts p
                JOIN    Employees e ON p.AuthorID = e.EmployeeID
                WHERE   (? IS NULL OR p.Status = ?)
                  AND   (? IS NULL OR p.Title LIKE '%' + ? + '%')
                ORDER BY p.PublishedDate DESC, p.CreatedDate DESC
                """;
        try (Connection con = db.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            int idx = 1;

            if (status == null || status.isBlank()) {
                ps.setObject(idx++, null);
                ps.setObject(idx++, null);
            } else {
                ps.setString(idx++, status);
                ps.setString(idx++, status);
            }

            if (keyword == null || keyword.isBlank()) {
                ps.setObject(idx++, null);
                ps.setObject(idx++, null);
            } else {
                ps.setString(idx++, keyword.trim());
                ps.setString(idx++, keyword.trim());
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BlogPost p = new BlogPost();
                    p.setPostId(rs.getInt("PostID"));
                    p.setTitle(rs.getString("Title"));
                    p.setSlug(rs.getString("Slug"));
                    p.setFeaturedImage(rs.getString("FeaturedImage"));
                    p.setSummary(rs.getString("Summary"));
                    p.setStatus(rs.getString("Status"));
                    p.setViewCount(rs.getInt("ViewCount"));
                    Timestamp pub = rs.getTimestamp("PublishedDate");
                    if (pub != null) {
                        p.setPublishedDate(pub.toLocalDateTime());
                    }
                    Timestamp c = rs.getTimestamp("CreatedDate");
                    if (c != null) {
                        p.setCreatedDate(c.toLocalDateTime());
                    }
                    Timestamp u = rs.getTimestamp("UpdatedDate");
                    if (u != null) {
                        p.setUpdatedDate(u.toLocalDateTime());
                    }
                    p.setAuthorName(rs.getString("AuthorName"));
                    list.add(p);
                }
            }
        }
        return list;
    }

    public BlogPost findById(int id) throws SQLException {
        String sql = """
                SELECT  p.*, e.FullName AS AuthorName
                FROM    BlogPosts p
                JOIN    Employees e ON p.AuthorID = e.EmployeeID
                WHERE   p.PostID = ?
                """;
        try (Connection con = db.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    private BlogPost mapRow(ResultSet rs) throws SQLException {
        BlogPost p = new BlogPost();
        p.setPostId(rs.getInt("PostID"));
        p.setTitle(rs.getString("Title"));
        p.setSlug(rs.getString("Slug"));
        p.setContent(rs.getString("Content"));
        p.setFeaturedImage(rs.getString("FeaturedImage"));
        p.setSummary(rs.getString("Summary"));
        p.setStatus(rs.getString("Status"));
        p.setAuthorId(rs.getInt("AuthorID"));
        p.setViewCount(rs.getInt("ViewCount"));
        Timestamp pub = rs.getTimestamp("PublishedDate");
        if (pub != null) {
            p.setPublishedDate(pub.toLocalDateTime());
        }
        Timestamp c = rs.getTimestamp("CreatedDate");
        if (c != null) {
            p.setCreatedDate(c.toLocalDateTime());
        }
        Timestamp u = rs.getTimestamp("UpdatedDate");
        if (u != null) {
            p.setUpdatedDate(u.toLocalDateTime());
        }
        try {
            p.setAuthorName(rs.getString("AuthorName"));
        } catch (SQLException ignore) {
            // cột này chỉ có trong một số query
        }
        return p;
    }

    public void insert(BlogPost post) throws SQLException {
        String sql = """
                INSERT INTO BlogPosts
                    (Title, Slug, Content, FeaturedImage, Summary,
                     Status, PublishedDate, AuthorID, ViewCount,
                     CreatedDate, UpdatedDate)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0, ?, ?)
                """;
        try (Connection con = db.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            LocalDateTime now = LocalDateTime.now();
            LocalDateTime published = null;
            if ("published".equalsIgnoreCase(post.getStatus())) {
                published = now;
            }

            ps.setString(1, post.getTitle());
            ps.setString(2, post.getSlug());
            ps.setString(3, post.getContent());
            ps.setString(4, post.getFeaturedImage());
            ps.setString(5, post.getSummary());
            ps.setString(6, post.getStatus());
            if (published == null) {
                ps.setObject(7, null);
            } else {
                ps.setTimestamp(7, Timestamp.valueOf(published));
            }
            ps.setInt(8, post.getAuthorId());
            ps.setTimestamp(9, Timestamp.valueOf(now));
            ps.setTimestamp(10, Timestamp.valueOf(now));
            ps.executeUpdate();
        }
    }

    public void update(BlogPost post) throws SQLException {
        String sql = """
                UPDATE BlogPosts
                SET Title = ?, Slug = ?, Content = ?, FeaturedImage = ?, Summary = ?,
                    Status = ?, PublishedDate = ?, UpdatedDate = ?
                WHERE PostID = ?
                """;
        try (Connection con = db.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            LocalDateTime now = LocalDateTime.now();
            LocalDateTime published = post.getPublishedDate();
            if ("published".equalsIgnoreCase(post.getStatus()) && published == null) {
                published = now;
            }

            ps.setString(1, post.getTitle());
            ps.setString(2, post.getSlug());
            ps.setString(3, post.getContent());
            ps.setString(4, post.getFeaturedImage());
            ps.setString(5, post.getSummary());
            ps.setString(6, post.getStatus());
            if (published == null) {
                ps.setObject(7, null);
            } else {
                ps.setTimestamp(7, Timestamp.valueOf(published));
            }
            ps.setTimestamp(8, Timestamp.valueOf(now));
            ps.setInt(9, post.getPostId());
            ps.executeUpdate();
        }
    }
}



