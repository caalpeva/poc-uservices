package team.kalpeva.poc.inventory.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import team.kalpeva.poc.inventory.model.Order;

@Repository
public interface AlbumRepository extends JpaRepository<Order, Integer> {

}
