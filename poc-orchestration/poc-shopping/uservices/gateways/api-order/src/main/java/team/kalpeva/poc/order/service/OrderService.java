package team.kalpeva.poc.order.service;

import java.util.List;

import team.kalpeva.poc.order.model.Order;

public interface OrderService {
	public List<Order> getAll();
	public void save(Order order);
}