package team.kalpeva.poc.shopping.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ShoppingRequest {
    //@JsonProperty("orderId")
    private String id;
    private String type;
}
