package team.kalpeva.poc.shipping.service;

import java.util.List;

import team.kalpeva.poc.shipping.model.Album;

public interface AlbumService {
	public List<Album> getAlbums();
	public void save(Album album);
	public void deleteById(int albumId);
}