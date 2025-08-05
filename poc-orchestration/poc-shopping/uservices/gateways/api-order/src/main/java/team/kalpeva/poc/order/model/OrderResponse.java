package team.kalpeva.poc.order.model;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@ToString
public class OrderResponse {
	private int userId;
	private String orderId;
	private OrderStatus status;
}