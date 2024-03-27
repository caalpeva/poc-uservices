package team.kalpeva.poc.order.model;

public class OrderResponse {
	private int userId;
	public Double amount;
	private String orderId;
	private OrderStatus status;

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

	public OrderStatus getStatus() {
		return status;
	}

	public void setStatus(OrderStatus status) {
		this.status = status;
	}

	@Override
	public String toString() {
		return "PaymentResponse{" +
				"userId=" + userId +
				", amount=" + amount +
				", orderId='" + orderId + '\'' +
				", status=" + status +
				'}';
	}
}