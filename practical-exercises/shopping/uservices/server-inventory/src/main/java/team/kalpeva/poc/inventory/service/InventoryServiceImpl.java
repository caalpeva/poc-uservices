package team.kalpeva.poc.inventory.service;

import org.springframework.stereotype.Service;
import team.kalpeva.poc.inventory.model.InventoryRequest;
import team.kalpeva.poc.inventory.model.InventoryResponse;
import team.kalpeva.poc.inventory.model.InventoryStatus;

import javax.annotation.PostConstruct;
import java.util.HashMap;
import java.util.Map;

@Service
public class InventoryServiceImpl implements InventoryService {

	private Map<Integer, Integer> productInventoryMap;

	@PostConstruct
	private void init(){
		this.productInventoryMap = new HashMap<>();
		this.productInventoryMap.put(1, 5);
		this.productInventoryMap.put(2, 5);
		this.productInventoryMap.put(3, 5);
	}

	public InventoryResponse deductInventory(InventoryRequest request) {
		int quantity = this.productInventoryMap.getOrDefault(request.getProductId(), 0);
		InventoryResponse response = new InventoryResponse();
		response.setOrderId(request.getOrderId());
		response.setUserId(request.getUserId());
		response.setProductId(request.getProductId());
		response.setStatus(InventoryStatus.INVENTORY_UNAVAILABLE);
		if(quantity > 0){
			response.setStatus(InventoryStatus.INVENTORY_AVAILABLE);
			this.productInventoryMap.put(request.getProductId(), quantity - 1);
		}
		return response;
	}

	public void addInventory(final InventoryRequest requestDTO) {
		this.productInventoryMap
				.computeIfPresent(requestDTO.getProductId(), (k, v) -> v + 1);
	}
}