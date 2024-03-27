package team.kalpeva.poc.inventory.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import team.kalpeva.poc.inventory.service.InventoryService;
import team.kalpeva.poc.inventory.model.InventoryResponse;
import team.kalpeva.poc.inventory.model.InventoryRequest;

import javax.persistence.*;
import java.util.Date;

@RestController
@RequestMapping("/api")
public class InventoryController {
	@Autowired
	private InventoryService service;

	@PostMapping("/deduct")
	public InventoryResponse deduct(@RequestBody final InventoryRequest requestDTO){
		return this.service.deductInventory(requestDTO);
	}

	@PostMapping("/add")
	public void add(@RequestBody final InventoryRequest requestDTO){
		this.service.addInventory(requestDTO);
	}
}