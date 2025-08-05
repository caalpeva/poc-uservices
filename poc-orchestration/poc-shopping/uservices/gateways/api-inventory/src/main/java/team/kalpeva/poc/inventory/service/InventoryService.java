package team.kalpeva.poc.inventory.service;

import team.kalpeva.poc.inventory.model.InventoryResponse;
import team.kalpeva.poc.inventory.model.InventoryRequest;

public interface InventoryService {
	public InventoryResponse deductInventory(final InventoryRequest request);
	public void addInventory(final InventoryRequest request);
}