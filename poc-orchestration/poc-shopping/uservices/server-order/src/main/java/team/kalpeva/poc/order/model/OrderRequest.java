package team.kalpeva.poc.order.model;

import lombok.Builder;
import lombok.Data;
import lombok.ToString;

@Data
@Builder
@ToString
public class OrderRequest {
	private int userId;
	public Double amount;
}