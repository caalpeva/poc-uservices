package team.kalpeva.poc.shopping.model;

public class Line {
    private String type;
    private String phoneNumber;
    private String portabilityType;

    public String getType() {
        return type;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    @Override
    public String toString() {
        return "Line{" +
                "type='" + type + '\'' +
                ", phoneNumber='" + phoneNumber + '\'' +
                ", portabilityType='" + portabilityType + '\'' +
                '}';
    }

    public String getPortabilityType() {
        return portabilityType;
    }
}
