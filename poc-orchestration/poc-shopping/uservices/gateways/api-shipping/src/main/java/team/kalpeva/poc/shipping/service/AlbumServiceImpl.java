package team.kalpeva.poc.shipping.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import team.kalpeva.poc.shipping.model.Album;
import team.kalpeva.poc.shipping.repository.AlbumRepository;

@Service
public class AlbumServiceImpl implements AlbumService {

	@Autowired
	private AlbumRepository albumRepository;
	
	@Override
	public List<Album> getAlbums() {
		return albumRepository.findAll();
	}

	@Override
	public void save(Album album) {
		albumRepository.save(album);
	}

	@Override
	public void deleteById(int albumId) {
		albumRepository.deleteById(albumId);
	}

}