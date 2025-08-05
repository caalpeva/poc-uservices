package team.kalpeva.poc.shipping.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import team.kalpeva.poc.shipping.model.Album;
import team.kalpeva.poc.shipping.service.AlbumService;

@RestController
@RequestMapping("/api")
public class AlbumController {
	
	@Autowired
	private AlbumService albumService;
	
	@GetMapping("/albums")
	public List<Album> getAlbums() {
		return albumService.getAlbums();
	}
	
	@PostMapping("/albums")
	public Album save(@RequestBody Album album) {
		albumService.save(album);
		return album;
	}
	
	@PutMapping("/albums")
	public Album edit(@RequestBody Album album) {
		albumService.save(album);
		return album;
	}
	
	@DeleteMapping("/albums/{id}")
	public String delete(@PathVariable("id") Integer albumId) {
		albumService.deleteById(albumId);
		return "Registro eliminado";
	}

}