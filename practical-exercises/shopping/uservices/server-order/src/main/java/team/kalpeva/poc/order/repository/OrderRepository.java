package team.kalpeva.poc.order.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import team.kalpeva.poc.order.model.Order;

@Repository
public interface OrderRepository extends JpaRepository<Order, Integer> {

}
