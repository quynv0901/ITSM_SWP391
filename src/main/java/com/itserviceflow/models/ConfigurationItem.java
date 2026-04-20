package com.itserviceflow.models;

import java.sql.Timestamp;

/**
 * CMDB configuration item. Fields {@code ciName}, {@code ciTypeId}, … align with
 * {@code configuration_item} in {@code context/database.md} and {@link com.itserviceflow.daos.CmdbDAO}.
 * Fields {@code name}, {@code type}, {@code version} are kept for {@link com.itserviceflow.daos.ConfigurationItemDAO}.
 */
public class ConfigurationItem {

    private int ciId;

    // Schema theo CMDB (ci_name, ci_type_id, …)
    private String ciName;
    private int ciTypeId;
    private String ciCode;
    private String status;
    private String location;
    private Integer ownerId;
    private String manufacturer;
    private String model;
    private String serialNumber;
    private String ipAddress;
    private String description;
    private Timestamp updatedAt;

    /** Từ JOIN user.full_name */
    private String ownerName;
    /** Từ JOIN ci_type.type_name */
    private String ciTypeName;

    // Dùng bởi ConfigurationItemDAO (bảng / cột khác hoặc bản rút gọn)
    private String name;
    private String type;
    private String version;
    private Integer vendorId;
    private String vendorName;
    private Timestamp createdAt;

    public ConfigurationItem() {
    }

    public ConfigurationItem(int ciId, String name, String type, String version, String description, String status,
            Timestamp createdAt, Timestamp updatedAt) {
        this.ciId = ciId;
        this.name = name;
        this.type = type;
        this.version = version;
        this.description = description;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getCiId() {
        return ciId;
    }

    public void setCiId(int ciId) {
        this.ciId = ciId;
    }

    public String getCiName() {
        return ciName;
    }

    public void setCiName(String ciName) {
        this.ciName = ciName;
    }

    public int getCiTypeId() {
        return ciTypeId;
    }

    public void setCiTypeId(int ciTypeId) {
        this.ciTypeId = ciTypeId;
    }

    public String getCiCode() {
        return ciCode;
    }

    public void setCiCode(String ciCode) {
        this.ciCode = ciCode;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public Integer getOwnerId() {
        return ownerId;
    }

    public void setOwnerId(Integer ownerId) {
        this.ownerId = ownerId;
    }

    public String getManufacturer() {
        return manufacturer;
    }

    public void setManufacturer(String manufacturer) {
        this.manufacturer = manufacturer;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }

    public String getSerialNumber() {
        return serialNumber;
    }

    public void setSerialNumber(String serialNumber) {
        this.serialNumber = serialNumber;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }

    public String getOwnerName() {
        return ownerName;
    }

    public void setOwnerName(String ownerName) {
        this.ownerName = ownerName;
    }

    public String getCiTypeName() {
        return ciTypeName;
    }

    public void setCiTypeName(String ciTypeName) {
        this.ciTypeName = ciTypeName;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getVersion() {
        return version;
    }

    public void setVersion(String version) {
        this.version = version;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Integer getVendorId() {
        return vendorId;
    }

    public void setVendorId(Integer vendorId) {
        this.vendorId = vendorId;
    }

    public String getVendorName() {
        return vendorName;
    }

    public void setVendorName(String vendorName) {
        this.vendorName = vendorName;
    }
}
