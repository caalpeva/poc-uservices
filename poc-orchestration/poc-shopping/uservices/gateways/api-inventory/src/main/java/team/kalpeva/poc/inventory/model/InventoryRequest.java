package team.kalpeva.poc.inventory.model;

public class InventoryRequest {
	private int userId;
	public int productId;
	private String orderId;

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

	@Override
	public String toString() {
		return "InventoryRequest{" +
				"userId=" + userId +
				", productId=" + productId +
				", orderId='" + orderId + '\'' +
				'}';
	}
}