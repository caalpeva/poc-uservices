package team.kalpeva.poc.inventory.model;

import javax.persistence.*;
import java.util.Date;

@Entity
@Table(name = "ORDERS")
public class Order {
	//purchaseOrder.setPrice(PRODUCT_PRICE.get(purchaseOrder.getProductId()));

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private int id;
	private String reference;
	public Date purchaseDate;
	private int userId;
	private int productId;
	public double price;

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getReference() {
		return reference;
	}

	public void setReference(String reference) {
		this.reference = reference;
	}

	public Date getPurchaseDate() {
		return purchaseDate;
	}

	public void setPurchaseDate(Date purchaseDate) {
		this.purchaseDate = purchaseDate;
	}

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

	public double getPrice() {
		return price;
	}

	public void setPrice(double price) {
		this.price = price;
	}

	@Override
	public String toString() {
		return "Order{" +
				"id=" + id +
				", reference='" + reference + '\'' +
				", purchaseDate=" + purchaseDate +
				", userId=" + userId +
				", productId=" + productId +
				", price=" + price +
				'}';
	}
}