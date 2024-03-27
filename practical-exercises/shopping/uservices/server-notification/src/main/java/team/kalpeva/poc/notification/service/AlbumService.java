package team.kalpeva.poc.notification.service;

import java.util.List;

import team.kalpeva.poc.notification.model.Album;

public interface AlbumService {
	public List<Album> getAlbums();
	public void save(Album album);
	public void deleteById(int albumId);
}