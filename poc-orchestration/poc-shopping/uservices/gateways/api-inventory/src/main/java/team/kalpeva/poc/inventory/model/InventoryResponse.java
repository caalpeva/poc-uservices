package team.kalpeva.poc.inventory.model;

public class InventoryResponse {
	private int userId;
	public int productId;
	private String orderId;
	private InventoryStatus status;

	public int getUserId() {
		return userId;
	}

	public void setUserId(int userId) {
		this.userId = userId;
	}

	public int getProductId() {
		return productId;
	}

	public void setProductId(int productId) {
		this.productId = productId;
	}

	public String getOrderId() {
		return orderId;
	}

	public void setOrderId(String orderId) {
		this.orderId = orderId;
	}

	public InventoryStatus getStatus() {
		return status;
	}

	public void setStatus(InventoryStatus status) {
		this.status = status;
	}

	@Override
	public String toString() {
		return "InventoryResponse{" +
				"userId=" + userId +
				", productId=" + productId +
				", orderId='" + orderId + '\'' +
				", status=" + status +
				'}';
	}
}