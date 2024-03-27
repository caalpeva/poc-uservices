package team.kalpeva.poc.order.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import team.kalpeva.poc.order.model.Order;
import team.kalpeva.poc.order.model.OrderRequest;
import team.kalpeva.poc.order.model.OrderResponse;

import team.kalpeva.poc.order.service.OrderService;

@RestController
@RequestMapping("/api")
public class OrderController {
	
	@Autowired
	private OrderService orderService;

	@GetMapping("/all")
	public List<Order> getAll() {
		return orderService.getAll();
	}

	@PostMapping("/create")
	public OrderResponse save() {
		return save(null);
	}

	@PostMapping("/create")
	public OrderResponse save(@RequestBody OrderRequest request) {
		Order order = new Order();
		order.setReference(String.valueOf(UUID.randomUUID()));
		orderService.save(new Order());
		return null;
	}
}