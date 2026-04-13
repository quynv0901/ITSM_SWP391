/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.itserviceflow.models;
import java.time.LocalDateTime;
import java.util.Date;

/**
 *
 * @author Admin
 */
public class User {

    private Integer userId;
    private String username;
    private String email;
    private String passwordHash;
    private String fullName;
    private String phone;
    private Integer departmentId;
    private Integer roleId;
    private Boolean isActive;
    private String resetToken;
    private LocalDateTime resetTokenExpires;
    private Boolean resetTokenUsed;
    private LocalDateTime updatedAt;
    private LocalDateTime lastLogin;

    private String roleName;
    private String departmentName;

    public User() {
    }

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public Integer getDepartmentId() { return departmentId; }
    public void setDepartmentId(Integer departmentId) { this.departmentId = departmentId; }
    public Integer getRoleId() { return roleId; }
    public void setRoleId(Integer roleId) { this.roleId = roleId; }
    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean isActive) { this.isActive = isActive; }
    public String getResetToken() { return resetToken; }
    public void setResetToken(String resetToken) { this.resetToken = resetToken; }
    public LocalDateTime getResetTokenExpires() { return resetTokenExpires; }
    public void setResetTokenExpires(LocalDateTime resetTokenExpires) { this.resetTokenExpires = resetTokenExpires; }
    public Boolean getResetTokenUsed() { return resetTokenUsed; }
    public void setResetTokenUsed(Boolean resetTokenUsed) { this.resetTokenUsed = resetTokenUsed; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    public LocalDateTime getLastLogin() { return lastLogin; }
    public void setLastLogin(LocalDateTime lastLogin) { this.lastLogin = lastLogin; }
    public String getRoleName() { return roleName; }
    public void setRoleName(String roleName) { this.roleName = roleName; }
    public String getDepartmentName() { return departmentName; }
    public void setDepartmentName(String departmentName) { this.departmentName = departmentName; }
}
