package com.itserviceflow.dtos;

public class ServiceOptionDTO {
    private int serviceId;
    private String serviceName;
    private String serviceCode;
    private Integer estimatedDeliveryDay;

    public ServiceOptionDTO() {
    }

    public int getServiceId() {
        return serviceId;
    }

    public void setServiceId(int serviceId) {
        this.serviceId = serviceId;
    }

    public String getServiceName() {
        return serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }

    public String getServiceCode() {
        return serviceCode;
    }

    public void setServiceCode(String serviceCode) {
        this.serviceCode = serviceCode;
    }

    public Integer getEstimatedDeliveryDay() {
        return estimatedDeliveryDay;
    }

    public void setEstimatedDeliveryDay(Integer estimatedDeliveryDay) {
        this.estimatedDeliveryDay = estimatedDeliveryDay;
    }
}