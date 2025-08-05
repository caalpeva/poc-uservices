package team.kalpeva.poc.order.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import team.kalpeva.poc.order.repository.OrderRepository;
import team.kalpeva.poc.order.model.Order;

@Service
public class OrderServiceImpl implements OrderService {

	@Autowired
	private OrderRepository orderRepository;
	
	@Override
	public List<Order> getAll() {
		return orderRepository.findAll();
	}

	@Override
	public void save(Order order) {
		orderRepository.save(order);
	}
}