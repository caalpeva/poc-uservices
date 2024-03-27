package team.kalpeva.poc.payment.model;

public class PaymentRequest {
	private int userId;
	public Double amount;
	private String orderId;

	public int getUserId() {
		return userId;
	}

	public void setUserId(int userId) {
		this.userId = userId;
	}

	public Double getAmount() {
		return amount;
	}

	public void setAmount(Double amount) {
		this.amount = amount;
	}

	public String getOrderId() {
		return orderId;
	}

	public void setOrderId(String orderId) {
		this.orderId = orderId;
	}

	@Override
	public String toString() {
		return "PaymentRequest{" +
				"userId=" + userId +
				", amount=" + amount +
				", orderId='" + orderId + '\'' +
				'}';
	}
}