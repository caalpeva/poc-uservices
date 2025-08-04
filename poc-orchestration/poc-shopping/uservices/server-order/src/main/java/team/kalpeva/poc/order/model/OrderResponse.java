package team.kalpeva.poc.order.model;

import lombok.Builder;
import lombok.Data;
import lombok.ToString;

@Data
@Builder
@ToString
public class OrderResponse {
	private int userId;
	private String orderId;
	private OrderStatus status;
}