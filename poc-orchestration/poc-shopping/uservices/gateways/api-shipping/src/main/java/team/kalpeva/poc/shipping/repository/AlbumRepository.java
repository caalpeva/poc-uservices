package team.kalpeva.poc.shipping.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import team.kalpeva.poc.shipping.model.Album;

@Repository
public interface AlbumRepository extends JpaRepository<Album, Integer> {

}
