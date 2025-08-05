package team.kalpeva.poc.order.model;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@ToString
public class OrderRequest {
	private int userId;
	public Double amount;
}