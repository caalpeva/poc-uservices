package team.kalpeva.poc.order.model;

import lombok.*;

import java.util.Date;

import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "ORDERS")
@NoArgsConstructor
@AllArgsConstructor
@Data
@Builder
@ToString
public class Order {
	//purchaseOrder.setPrice(PRODUCT_PRICE.get(purchaseOrder.getProductId()));

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private int id;
	private String reference;
	public Date purchaseDate;
	@Enumerated(EnumType.STRING)
	public OrderStatus status;
	private int userId;
	private int productId;
	public double price;
}