package team.kalpeva.poc.shopping;

public enum TransformFlow {

  MOBILE_PREPAID_NEW("flags.mobile-prepaid.new"),
  MOBILE_POSTPAID_NEW("flags.mobile-postpaid.new");

  private String configKey;

  TransformFlow(String configKey) {
    this.configKey = configKey;
  }

  public boolean isActivated() {
    return true;
  }
}