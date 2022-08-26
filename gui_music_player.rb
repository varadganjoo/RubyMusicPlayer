require 'rubygems'
require 'gosu'

module ZOrder
  BACKGROUND, PLAYER, UI = *0..2
end

module Genre
  POP, CLASSIC, JAZZ, ROCK, HIPHOP = *1..5
end

GENRE_NAMES = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock', 'HIPHOP']

class Album
	attr_accessor :title, :artist, :artwork, :genre, :track

	def initialize (title, artist, artwork, genre, track)
		@title = title
		@artwork = artwork
		@genre = genre
		@artist = artist
		@track = track 
	end

end

class Track
	attr_accessor :name, :location

	def initialize (name, location)
		@name = name
		@location = location
	end

end

class ArtWork
	attr_accessor :imgLocation, :x, :y, :page

	def initialize (imgLocation, x, y, page)
		@imgLocation = imgLocation
		@x = x
		@y = y
		@page = page
	end
end

class Playlist
	attr_accessor :name, :location
	
	def initialize (name, location)
		@name = name
		@location = location
	end
end

def read_albums(music_file)
	count = music_file.gets().to_i
	albums = Array.new
	while count != 0
		album = read_album(music_file)
		albums << album
		count = count - 1
	end
	albums
end

def read_album(music_file)
	album_title = music_file.gets().chomp.to_s
	album_artist = music_file.gets().chomp.to_s
	album_artwork = music_file.gets().chomp.to_s
	album_genre = music_file.gets().to_i
	track = read_tracks(music_file)
	album = Album.new(album_title, album_artist, album_artwork, album_genre, track)
	album
end

def read_playlists(playlist_file)
	count = playlist_file.gets().to_i
	playlists = Array.new
	while count != 0
		playlist = read_each_playlist(playlist_file)
		playlists << playlist
		count = count - 1
	end
	playlists
end

def read_each_playlist(playlist_file)
	playlist_name = playlist_file.gets().chomp.to_s
	playlist_location = playlist_file.gets().chomp.to_s
	playlist = Playlist.new(playlist_name, playlist_location)
	playlist
end

def read_tracks(music_file)
	count = music_file.gets().to_i
	tracks = Array.new
	while count != 0
		track = read_track(music_file)
		tracks << track
		count = count - 1
	end
	tracks
end


def read_track(music_file)
	track_name = music_file.gets().chomp.to_s
	track_location = music_file.gets().chomp.to_s
	track = Track.new(track_name, track_location)
	track
end

# Put your record definitions here
WIN_WIDTH = 1200
WIN_HEIGHT = 700
ALBUM_FILE = File.new("album.txt", "r")
if File.exist?("playlists.txt")
	PLAYLIST_FILE = File.new("playlists.txt", "r")
else
	PLAYLIST_FILE = File.new("playlists.txt", "w+")
	PLAYLIST_FILE = File.new("playlists.txt", "r")
end


class MusicPlayerMain < Gosu::Window

	def initialize
	    super WIN_WIDTH, WIN_HEIGHT
	    self.caption = "Music Player"
		@background = Gosu::Color::WHITE
		@albums = read_albums(ALBUM_FILE)
		ALBUM_FILE.close
		@albums_artist = nil
		@albums_genre = nil
		@button_font = Gosu::Font.new(30)
		@track_font = Gosu::Font.new(15)
		@app_title = Gosu::Font.new(30)
		@clicked_index = -1
		@clicked_index_track = -1
		@track_x = 1000
		@track_y = 1000
		@track_color = Gosu::Color::WHITE
		@play_pause_file = "Media/Pause.png"
		@total_pages = @albums.length / 4
		@current_page = 0
		@state = "menu"
		@clicked_playlist = nil
		@playlist_tracks = nil
		@click_color =  Gosu::Color::WHITE
		@current_playlist_page = 0
		@all_tracks = nil
		@playlist_pages = nil
		@temp_playlist_arr = Array.new
		@clicked_counter = 0
		@playlists = read_playlists(PLAYLIST_FILE)
		# Reads in an array of albums from a file and then prints all the albums in the
		# array to the terminal
	end

  # Put in your code here to load albums and tracks
	
  # Draws the artwork on the screen for all the albums

	def draw_albums(albums, start, finish)
		album_count = 0
		album_placement = Array.new
		while album_count < albums.length
			placement = draw_album(albums, album_count, start, finish)
			album_placement << placement
			album_count += 1
		end
		@album_button = album_placement
	end

	def draw_album(albums, album_count, start, finish)
			y_initial = 55
			if album_count % 2 == 0
				x_album = 50
			else
				x_album = 350
			end
			fourth_album = album_count % 4
			if fourth_album == 0 || (album_count - 1) % 4 == 0
				y_album = y_initial
			elsif fourth_album > 1
				if album_count % 2 != 0
					previous_album = album_count - 1
					scaled_coefficient = 135 * previous_album 
					y_album = y_initial + scaled_coefficient + 20
					y_album_text = y_album + 20
				else
					scaled_coefficient = 135 * album_count
					y_album = y_initial + scaled_coefficient + 20
				end
			end		
			x_album_text = x_album + 50
			y_album_text = y_album + 260
			if album_count < 4
				page_number = 0
			elsif album_count % 4 == 0 && album_count > 4
				page_number = album_count / 4 && album_count > 4
			elsif (album_count - 1) % 4 == 0
				page_number = (album_count - 1) / 4 && album_count > 4
			elsif (album_count - 2) % 4 == 0
				page_number = (album_count - 2) / 4 && album_count > 4
			elsif (album_count + 1) % 4 == 0
				page_number = (album_count - 1) / 4 && album_count > 4
			end
			album_button = ArtWork.new(albums[album_count].artwork, x_album, y_album, page_number)
			if @state == "menu"
				button_text = albums[album_count].title
			elsif @state == "artist"
				button_text = albums[album_count].artist + " - " + albums[album_count].title
			elsif @state == "genre"
				genre = GENRE_NAMES[albums[album_count].genre] + " - " + albums[album_count].title
				button_text = genre
			end
			if album_count >= start && album_count <= finish
				Gosu::Image.new(albums[album_count].artwork).draw(x_album, y_album, z = ZOrder::UI)
				@button_font.draw("#{button_text}", x_album_text, y_album_text, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
			end
			album_button
	end
	
	def area_clicked(leftX, topY, rightX, bottomY)
		mouse_over_button = false
		if(mouse_x > leftX && mouse_x < rightX)
			if(mouse_y > topY && mouse_y < bottomY)
				mouse_over_button = true
			end
		end
		mouse_over_button
	end
	
	def read_from_playlist
		if @clicked_playlist != nil
			music_file = File.new(@playlists[@clicked_playlist].location, "r")
			count = music_file.gets().to_i
			tracks = Array.new
			while count != 0
				track = read_track(music_file)
				tracks << track
				count = count - 1
			end
			tracks
		end
	end
	
	def display_tracks(array, index, ypos)
		track_counter = 0
		if index != -1
			while track_counter < array[index].track.length
				text = array[index].track[track_counter].name
				display_track(text, 700, ypos)
				ypos += 30
				track_counter += 1
			end
		end
	end
	
	def display_track(text, xpos, ypos)
		@track_font.draw(text, xpos, ypos, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
	end

	def playTrack(albums, album_index, track_index, text_space_dim, start_pos)
		if track_index >= albums[@current_page * 4 + album_index].track.length
			track_index = 0
		elsif track_index < 0
			track_index = albums[@current_page * 4 + album_index].track.length - 1
		end
		@clicked_index_track = track_index
		total_prev_button_area = @clicked_index_track * text_space_dim
		total_y = start_pos + total_prev_button_area
		@track_y = total_y - 10
		@track_x = 690
		@track_color = Gosu::Color::YELLOW
		@song = Gosu::Song.new(albums[@current_page * 4 + album_index].track[track_index].location)
		@song.play(false)
		if Gosu::Song.current_song == nil
			@clicked_index_track += 1
		end
	end
	
	def playTrack_from_playlist(track_index, text_space_dim, start_pos)
		if track_index >= @playlist_tracks.length
			track_index = 0
		elsif track_index < 0
			track_index = @playlist_tracks.length - 1
		end
		@clicked_index_track = track_index
		total_prev_button_area = @clicked_index_track * text_space_dim
		total_y = start_pos + total_prev_button_area
		@track_y = start_pos - 10
		@track_x = 40
		@track_color = Gosu::Color::YELLOW
		@song = Gosu::Song.new(@playlist_tracks[track_index].location)
		@song.play(false)
		if @song.playing? == false
			@clicked_index_track += 1
		end
	end

	def draw_background
		Gosu.draw_rect(0, 0, WIN_WIDTH, WIN_HEIGHT, @background, ZOrder::BACKGROUND, mode=:default)
	end
	
	def update
		if @song && @clicked_index_track == -1
			@song.stop
		end
		if @state != "Add playlist"
			@temp_playlist_arr = Array.new
			@clicked_counter = 0
			@current_playlist_page = 0
		end
	end
	
	def draw_buttons
		if @play_pause_file
			Gosu::Image.new(@play_pause_file).draw(300, 630, z = ZOrder::UI)
			Gosu::Image.new("Media/Next.png").draw(400, 630, z = ZOrder::UI)
			Gosu::Image.new("Media/Previous.png").draw(200, 630, z = ZOrder::UI)
			Gosu::Image.new("Media/Stop.png").draw(100, 630, z = ZOrder::UI)
		end
	end
 
	def draw_playlist
		count = 0
		ypos = 100
		xpos = 50
		while count < @playlists.length
			@track_font.draw(@playlists[count].name, xpos, ypos, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
			ypos += 50
			count += 1
		end
	end
	
 
	def	draw_playlists
		if File.exist?("playlists.txt") && File.size("playlists.txt") > 0
			#puts "file exists"
			draw_playlist
			Gosu.draw_rect(1000, 610, 100, 40, Gosu::Color::BLUE, ZOrder::BACKGROUND, mode=:default)
			Gosu.draw_rect(1030, 580, 40, 100, Gosu::Color::BLUE, ZOrder::BACKGROUND, mode=:default)
		else
			#puts "file doesn't exist"
			Gosu.draw_rect(330, 335, 100, 40, Gosu::Color::GREEN, ZOrder::BACKGROUND, mode=:default)
			Gosu.draw_rect(360, 300, 40, 100, Gosu::Color::GREEN, ZOrder::BACKGROUND, mode=:default)
		end
	end
	
	def display_playlist_tracks(array, index, ypos)
		track_counter = 0
		if index != -1
			while track_counter < array.length
				text = array[track_counter].name
				display_playlist_track(text, 50, ypos)
				ypos += 40
				track_counter += 1
			end
		end
	end
	
	def display_playlist_track(text, xpos, ypos)
		@track_font.draw(text, xpos, ypos, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
	end
	
	def display_all_tracks 
		count_album = 0
		ypos = 150
		xpos = 300
		all_tracks = Array.new
		while count_album < @albums.length
			count_track = 0
			while count_track < @albums[count_album].track.length
				all_tracks << @albums[count_album].track[count_track]
				count_track += 1
			end
			count_album += 1
		end
		@all_tracks = all_tracks
		@playlist_pages = all_tracks.length / 18
		count_track = 0
		while count_track < all_tracks.length
			if count_track % 18 == 0
				ypos = 150
			else
				ypos += 30
			end
			if count_track >=(@current_playlist_page * 18)	&& count_track <(@current_playlist_page * 18 + 18)
				display_track(all_tracks[count_track].name, xpos, ypos)
			end
			count_track += 1
		end
	end
	
	def draw_sort_buttons(state)
		if state == "artist"
			count = 0
			temp_artist = Array.new
			while count < @albums.length
				temp_artist << @albums[count]
				count += 1
			end
			@albums_artist = temp_artist.sort{ |a,b| a.artist <=> b.artist}
			draw_albums(@albums_artist, @current_page * 4, (@current_page * 4) + 3)
		elsif state == "genre"
			count = 0
			temp_genre = Array.new
			while count < @albums.length
				temp_genre << @albums[count]
				count += 1
			end
			@albums_genre = temp_genre.sort{ |a,b| a.genre <=> b.genre}
			draw_albums(@albums_genre, @current_page * 4, (@current_page * 4) + 3)
		end
	end
	
	def add_track_to_array(index)
		song = @all_tracks[(@current_playlist_page * 18) + index]
		@temp_playlist_arr << song
	end
	
	def create_new_playlist(tracks_array)
		count = @playlists.length + 1
		playlist_location = "playlist_" + count.to_s + ".txt"
		@playlists << Playlist.new("playlist " + count.to_s, playlist_location)
		add_playlists(@playlists)
		add_to_playlist(tracks_array, playlist_location)
	end
	
	def add_to_playlist(tracks_array, playlist_location)
		playlist_write = File.new(playlist_location, "w+")
		playlist_write.puts tracks_array.count
		count = 0
		while count < tracks_array.length
			#puts tracks_array[count].name
			add_song(tracks_array[count], playlist_write)
			count += 1
		end
		playlist_write.close
	end
	
	def add_song(track, file)
		file.puts track.name
		file.puts track.location
	end
	
	def add_playlists(playlists)
		playlists_write = File.new("playlists.txt", "w+")
		playlists_write.puts playlists.length.to_s
		x = 0
		while x < playlists.length.to_i
			add_playlist(playlists_write, playlists[x])
			x += 1
		end
		playlists_write.close
	end
	
	def add_playlist(playlists_write, playlist)
		playlists_write.puts playlist.name
		playlists_write.puts playlist.location
	end
	
	def draw
		draw_background
		@app_title.draw("Music Player", 450, 20, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
		@app_title.draw(@state, 700, 20, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
		
		if @state == "menu"
			draw_albums(@albums, @current_page * 4, (@current_page * 4) + 3)
			@button_font = Gosu::Font.new(30)
			display_tracks(@albums[@current_page * 4..@current_page * 4 + 3], @clicked_index, 55)
			Gosu.draw_rect(1100, 200, 100, 40, Gosu::Color::GREEN, ZOrder::BACKGROUND, mode=:default)
			Gosu::Font.new(25).draw("Artist", 1110, 210, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
			Gosu.draw_rect(1100, 100, 100, 40, Gosu::Color::GREEN, ZOrder::BACKGROUND, mode=:default)
			Gosu::Font.new(25).draw("Playlists", 1110, 110, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
			Gosu.draw_rect(1100, 300, 100, 40, Gosu::Color::GREEN, ZOrder::BACKGROUND, mode=:default)
			Gosu::Font.new(25).draw("Genre", 1110, 310, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
			if @albums.length > 4
				Gosu.draw_rect(510, 630, 70, 40, Gosu::Color::GREEN, ZOrder::BACKGROUND, mode=:default)
				Gosu::Font.new(25).draw("Next", 520, 635, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
				Gosu.draw_rect(20, 630, 70, 40, Gosu::Color::GREEN, ZOrder::BACKGROUND, mode=:default)
				Gosu::Font.new(25).draw("Prev.", 30, 635, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
			end
			Gosu::Font.new(25).draw((@current_page + 1).to_s, 300, 635, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
			if @clicked_index_track > -1
				Gosu.draw_rect(@track_x, @track_y, 400, 30, @track_color, ZOrder::BACKGROUND, mode=:default)
				draw_buttons
			end
		elsif @state == "playlists"
			@background = Gosu::Color::WHITE
			Gosu.draw_rect(60, 40, 100, 40, Gosu::Color::GREEN, ZOrder::BACKGROUND, mode=:default)
			Gosu::Font.new(30).draw("Back", 70, 50, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
			draw_playlists
		elsif @state == "Add playlist"
			@app_title.draw("Select the songs you would like to add", 200, 100, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
			display_all_tracks
			Gosu.draw_rect(60, 40, 100, 40, Gosu::Color::GREEN, ZOrder::BACKGROUND, mode=:default)
			Gosu::Font.new(30).draw("Back", 70, 50, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
			if @all_tracks.length > 18
				Gosu.draw_rect(600, 630, 70, 40, Gosu::Color::GREEN, ZOrder::BACKGROUND, mode=:default)
				Gosu::Font.new(25).draw("Next", 610, 635, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
				Gosu.draw_rect(110, 630, 70, 40, Gosu::Color::GREEN, ZOrder::BACKGROUND, mode=:default)
				Gosu::Font.new(25).draw("Prev.", 120, 635, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
			end
			if @clicked_counter > 0
				Gosu.draw_rect(800, 630, 100, 40, Gosu::Color::BLUE, ZOrder::BACKGROUND, mode=:default)
				Gosu::Font.new(25).draw("Create", 810, 635, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::WHITE)
			end
		elsif @state == "playlist tracks"
			@playlist_tracks = read_from_playlist
			display_playlist_tracks(@playlist_tracks, @clicked_playlist, 100)
			Gosu.draw_rect(60, 40, 100, 40, Gosu::Color::GREEN, ZOrder::BACKGROUND, mode=:default)
			Gosu::Font.new(30).draw("Back", 70, 50, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
			if @clicked_index_track > -1 && @song
				Gosu.draw_rect(@track_x, @track_y, 400, 40, @track_color, ZOrder::BACKGROUND, mode=:default)
				draw_buttons
			end
		elsif @state == "genre"
			Gosu.draw_rect(60, 10, 100, 40, Gosu::Color::GREEN, ZOrder::BACKGROUND, mode=:default)
			Gosu::Font.new(30).draw("Back", 70, 20, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)	
			@button_font = Gosu::Font.new(20)
			draw_sort_buttons(@state)
			display_tracks(@albums_genre[@current_page * 4..@current_page * 4 + 3], @clicked_index, 55)
			if @albums.length > 4 
				Gosu.draw_rect(510, 630, 70, 40, Gosu::Color::GREEN, ZOrder::BACKGROUND, mode=:default)
				Gosu::Font.new(25).draw("Next", 520, 635, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
				Gosu.draw_rect(20, 630, 70, 40, Gosu::Color::GREEN, ZOrder::BACKGROUND, mode=:default)
				Gosu::Font.new(25).draw("Prev.", 30, 635, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
			end
			Gosu::Font.new(25).draw((@current_page + 1).to_s, 300, 635, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
			if @clicked_index_track > -1 && @song
				Gosu.draw_rect(@track_x, @track_y, 400, 30, @track_color, ZOrder::BACKGROUND, mode=:default)
				draw_buttons
			end
		elsif @state == "artist"
			Gosu.draw_rect(60, 10, 100, 40, Gosu::Color::GREEN, ZOrder::BACKGROUND, mode=:default)
			Gosu::Font.new(30).draw("Back", 70, 20, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
			@button_font = Gosu::Font.new(20)
			draw_sort_buttons(@state)
			display_tracks(@albums_artist[@current_page * 4..@current_page * 4 + 3], @clicked_index, 55)
			if @albums.length > 4
				Gosu.draw_rect(510, 630, 70, 40, Gosu::Color::GREEN, ZOrder::BACKGROUND, mode=:default)
				Gosu::Font.new(25).draw("Next", 520, 635, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
				Gosu.draw_rect(20, 630, 70, 40, Gosu::Color::GREEN, ZOrder::BACKGROUND, mode=:default)
				Gosu::Font.new(25).draw("Prev.", 30, 635, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
			end
			Gosu::Font.new(25).draw((@current_page + 1).to_s, 300, 635, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
			if @clicked_index_track > -1 && @song
				Gosu.draw_rect(@track_x, @track_y, 400, 30, @track_color, ZOrder::BACKGROUND, mode=:default)
				draw_buttons
			end
		end 
	end

 	def needs_cursor?; true; end

	def button_down(id)
		case id
	    when Gosu::MsLeft
			if @state == "menu"
				@albums[@current_page * 4..@current_page * 4 + 3].each_with_index do | album, index |
					if area_clicked(@album_button[index].x, @album_button[index].y, @album_button[index].x + 256, @album_button[index].y + 270)
						@clicked_index = index
						@clicked_index_track = -1
						if @song && @clicked_index_track == -1
							@song.stop
						end
					end
				end
				start_pos = 55
				text_space_dim = 30
				@albums[@clicked_index].track.each_with_index do | track, index |
					total_prev_button_area = index * text_space_dim
					total_y = start_pos + total_prev_button_area
					
					if area_clicked(700, total_y, 1000, total_y + 20) && @clicked_index > -1
						@clicked_index_track = index
						@play_pause_file = "Media/Pause.png"
						playTrack(@albums, @clicked_index, @clicked_index_track, text_space_dim, start_pos)
					end
				end
					
				if area_clicked(300, 630, 392, 703) && @play_pause_file == "Media/Pause.png" && @clicked_index != -1
					@song.pause
					@play_pause_file = "Media/Play.png"
				elsif area_clicked(300, 630, 392, 703) && @play_pause_file == "Media/Play.png" && @clicked_index != -1
					@song.play(false)
					@play_pause_file = "Media/Pause.png"
				end
				
				if area_clicked(100, 630, 182,701) && @clicked_index != -1
					@song.stop
					@clicked_index = -1
					@clicked_index_track = -1
					@track_color = @background
				end			
				
				if area_clicked(400, 630, 472, 703) && @clicked_index != -1
					@clicked_index_track += 1
					@song.stop
					playTrack(@albums, @clicked_index, @clicked_index_track, text_space_dim, start_pos)
					if @song.playing?
						@play_pause_file = "Media/Pause.png"
					end
				end
				
				if area_clicked(200, 630, 272, 703) && @clicked_index != -1
					@clicked_index_track -= 1
					@song.stop
					playTrack(@albums, @clicked_index, @clicked_index_track, text_space_dim, start_pos)
					if @song.playing?
						@play_pause_file = "Media/Pause.png"
					end
				end
				
				if area_clicked(1100, 100, 1200, 140)
					if @song && @song.playing?
						@song.stop
					end
					@state = "playlists"
					if @song && @clicked_index_track == -1
						@song.stop
					end
					@current_page = 0
					@clicked_index = -1
					@clicked_index_track = -1
				end
				
				if area_clicked(1100, 200, 1200, 240)
					if @song && @song.playing?
						@song.stop
					end
					@state = "artist"
					if @song && @clicked_index_track == -1
						@song.stop
					end
					@current_page = 0
					@clicked_index = -1
					@clicked_index_track = -1
				end
				
				if area_clicked(1100, 300, 1200, 340)
					if @song && @song.playing?
						@song.stop
					end
					@state = "genre"
					if @song && @clicked_index_track == -1
						@song.stop
					end
					@current_page = 0
					@clicked_index = -1
					@clicked_index_track = -1
				end
				
				if area_clicked(510, 630, 580,670) && @clicked_index != -1
					if @song
						@song.stop
					end
					@clicked_index = -1
					@clicked_index_track = -1
					if @current_page <= 0 && @current_page > @total_pages
						@current_page += 1
					elsif @current_page == @total_pages
						@current_page = 0
					end
				end
				
				if @albums.length > 4
					if area_clicked(510, 630, 580,670) 
						if @song
							@song.stop
						end
						@clicked_index = -1
						@clicked_index_track = -1
						if @current_page <= 0
							@current_page += 1
						elsif @current_page == @total_pages
							@current_page = 0
						end
					end
					
					if area_clicked(20, 630, 90,670)
						if @song
							@song.stop
						end
						@clicked_index = -1
						@clicked_index_track = -1
						if @current_page > 0
							@current_page -= 1
						elsif @current_page == 0
							@current_page = @total_pages
						end
					end
				end
				
			elsif @state == "playlists"
				if area_clicked(330, 300, 430, 400) && File.size("playlists.txt") == 0
					@state = "Add playlist"
				end
				
				if area_clicked(1000, 610, 1100, 650) && area_clicked(1030, 580, 1070, 680)
					@state = "Add playlist"
				end
				
				@playlists.each_with_index do | playlist, index |
					start_pos = 100
					gap = 50
					end_y = (index * gap) + start_pos + 30
					if area_clicked(50, start_pos, 300, end_y)
						@clicked_playlist = index
						@state = "playlist tracks"
						#puts "clicked"
					end
				end
				
				if area_clicked(60, 40, 160, 80)
					@state = "menu"
					@clicked_index = -1
					@clicked_index_track = -1
				end
				
			elsif @state == "playlist tracks"
				gap = 40
				@playlist_tracks.each_with_index do | track, index |
					start_pos = (index * gap) + 100
					end_y = start_pos + 30
					if area_clicked(40, start_pos, 300, end_y)
						playTrack_from_playlist(index, gap, start_pos)
					end
				end
				
				if area_clicked(300, 630, 392, 703) && @play_pause_file == "Media/Pause.png" && @clicked_index_track != -1
					@song.pause
					@play_pause_file = "Media/Play.png"
				elsif area_clicked(300, 630, 392, 703) && @play_pause_file == "Media/Play.png" && @clicked_index_track != -1
					@song.play(false)
					@play_pause_file = "Media/Pause.png"
				end
				
				if area_clicked(100, 630, 182,701) && @song.playing?
					@song.stop
					@clicked_index = -1
					@clicked_index_track = -1
					@track_color = @background
				end
				
				if area_clicked(60, 40, 160, 80)
					@state = "playlists"
					@clicked_index_track = -1
					if @song && @song.playing?
						@song.stop
					end
				end
				
				if area_clicked(400, 630, 472, 703) && @song.playing?
					@clicked_index_track += 1
					@song.stop
					if @clicked_index_track > @playlist_tracks.length - 1
						@clicked_index_track = 0
					end
					playTrack_from_playlist(@clicked_index_track, gap, (@clicked_index_track * gap) + 100)
					if @song.playing?
						@play_pause_file = "Media/Pause.png"
					end
				end
				
				if area_clicked(200, 630, 272, 703) && @song.playing?
					@clicked_index_track -= 1
					@song.stop
					if @clicked_index_track < 0
						@clicked_index_track = @playlist_tracks.length - 1
					end
					playTrack_from_playlist(@clicked_index_track, gap, (@clicked_index_track * gap) + 100)
					if @song.playing?
						@play_pause_file = "Media/Pause.png"
					end
				end			
			elsif @state == "Add playlist"
				if area_clicked(60, 40, 160, 80)
					@state = "playlists"
					@clicked_index = -1
					@clicked_index_track = -1
					@current_playlist_page = 0
				end
				
				gap = 30
				@all_tracks[@current_playlist_page * 18..(@current_playlist_page * 18) + 17].each_with_index do | track, index |
					@clicked_counter += 1
					start_pos = (index * gap) + 150
					end_y = start_pos + 20
					if area_clicked(300, start_pos, 450, end_y)
						add_track_to_array(index)
					end
				end
				
				if @clicked_counter > 0
					if area_clicked(800, 630, 900, 670)
						create_new_playlist(@temp_playlist_arr)
						@clicked_counter = 0
						@state = "playlists"
					end
				end

				if @all_tracks.length > 18
					if area_clicked(600, 630, 670, 670)
						if @current_playlist_page <= 0
							@current_playlist_page += 1
						elsif @current_playlist_page == @playlist_pages
							@current_playlist_page = 0
						end
						#puts @current_playlist_page.to_s
					end 
					
					if area_clicked(110, 630, 180, 670)
						if @current_playlist_page > 0
							@current_playlist_page -= 1
						elsif @current_playlist_page == 0
							@current_playlist_page = @playlist_pages
						end
						#puts @current_playlist_page.to_s
					end					
				end
				
			elsif @state == "genre"	
				if area_clicked(60, 10, 160, 50)
					@state = "menu"
					@clicked_index = -1
					@clicked_index_track = -1
					@current_page = 0
				end
				
				@albums_genre[@current_page * 4..@current_page * 4 + 3].each_with_index do | album, index |
					if area_clicked(@album_button[index].x, @album_button[index].y, @album_button[index].x + 256, @album_button[index].y + 270)
						@clicked_index = index
						@clicked_index_track = -1
						if @song && @clicked_index_track == -1
							@song.stop
						end
					end
				end
				
				start_pos = 55
				text_space_dim = 30
				@albums_genre[@clicked_index].track.each_with_index do | track, index |
					total_prev_button_area = index * text_space_dim
					total_y = start_pos + total_prev_button_area
					
					if area_clicked(700, total_y, 1000, total_y + 20) && @clicked_index > -1
						@clicked_index_track = index
						@play_pause_file = "Media/Pause.png"
						playTrack(@albums_genre, @clicked_index, @clicked_index_track, text_space_dim, start_pos)
					end
				end
				
				if @albums.length > 4
					if area_clicked(510, 630, 580,670) 
						if @song
							@song.stop
						end
						@clicked_index = -1
						@clicked_index_track = -1
						if @current_page <= 0
							@current_page += 1
						elsif @current_page == @total_pages
							@current_page = 0
						end
					end
					
					if area_clicked(20, 630, 90,670)
						if @song
							@song.stop
						end
						@clicked_index = -1
						@clicked_index_track = -1
						if @current_page > 0
							@current_page -= 1
						elsif @current_page == 0
							@current_page = @total_pages
						end
					end
				end
				
				if area_clicked(300, 630, 392, 703) && @play_pause_file == "Media/Pause.png" && @clicked_index != -1
					@song.pause
					@play_pause_file = "Media/Play.png"
				elsif area_clicked(300, 630, 392, 703) && @play_pause_file == "Media/Play.png" && @clicked_index != -1
					@song.play(false)
					@play_pause_file = "Media/Pause.png"
				end
				
				if area_clicked(100, 630, 182,701) && @clicked_index != -1
					@song.stop
					@clicked_index = -1
					@clicked_index_track = -1
					@track_color = @background
				end			
				
				if area_clicked(400, 630, 472, 703) && @clicked_index != -1
					@clicked_index_track += 1
					@song.stop
					playTrack(@albums_genre, @clicked_index, @clicked_index_track, text_space_dim, start_pos)
					if @song.playing?
						@play_pause_file = "Media/Pause.png"
					end
				end
				
				if area_clicked(200, 630, 272, 703) && @clicked_index != -1
					@clicked_index_track -= 1
					@song.stop
					playTrack(@albums_genre, @clicked_index, @clicked_index_track, text_space_dim, start_pos)
					if @song.playing?
						@play_pause_file = "Media/Pause.png"
					end
				end
				
			elsif @state == "artist"
				
				if area_clicked(60, 10, 160, 50)
					@state = "menu"
					@clicked_index = -1
					@clicked_index_track = -1
					@current_page = 0
				end
				
				@albums_artist[@current_page * 4..@current_page * 4 + 3].each_with_index do | album, index |
					if area_clicked(@album_button[index].x, @album_button[index].y, @album_button[index].x + 256, @album_button[index].y + 270)
						@clicked_index = index
						@clicked_index_track = -1
						if @song && @clicked_index_track == -1
							@song.stop
						end
					end
				end
				
				start_pos = 55
				text_space_dim = 30
				@albums_artist[@clicked_index].track.each_with_index do | track, index |
					total_prev_button_area = index * text_space_dim
					total_y = start_pos + total_prev_button_area
					
					if area_clicked(700, total_y, 1000, total_y + 20) && @clicked_index > -1
						@clicked_index_track = index
						@play_pause_file = "Media/Pause.png"
						playTrack(@albums_artist, @clicked_index, @clicked_index_track, text_space_dim, start_pos)
					end
				end
				if @albums.length > 4
					if area_clicked(510, 630, 580,670) 
						if @song
							@song.stop
						end
						@clicked_index = -1
						@clicked_index_track = -1
						if @current_page <= 0
							@current_page += 1
						elsif @current_page == @total_pages
							@current_page = 0
						end
					end
					
					if area_clicked(20, 630, 90,670)
						if @song
							@song.stop
						end
						@clicked_index = -1
						@clicked_index_track = -1
						if @current_page > 0
							@current_page -= 1
						elsif @current_page == 0
							@current_page = @total_pages
						end
					end
				end
				
				if area_clicked(300, 630, 392, 703) && @play_pause_file == "Media/Pause.png" && @clicked_index != -1
					@song.pause
					@play_pause_file = "Media/Play.png"
				elsif area_clicked(300, 630, 392, 703) && @play_pause_file == "Media/Play.png" && @clicked_index != -1
					@song.play(false)
					@play_pause_file = "Media/Pause.png"
				end
				
				if area_clicked(100, 630, 182,701) && @clicked_index != -1
					@song.stop
					@clicked_index = -1
					@clicked_index_track = -1
					@track_color = @background
				end			
				
				if area_clicked(400, 630, 472, 703) && @clicked_index != -1
					@clicked_index_track += 1
					@song.stop
					playTrack(@albums_artist, @clicked_index, @clicked_index_track, text_space_dim, start_pos)
					if @song.playing?
						@play_pause_file = "Media/Pause.png"
					end
				end
				
				if area_clicked(200, 630, 272, 703) && @clicked_index != -1
					@clicked_index_track -= 1
					@song.stop
					playTrack(@albums_artist, @clicked_index, @clicked_index_track, text_space_dim, start_pos)
					if @song.playing?
						@play_pause_file = "Media/Pause.png"
					end
				end
				
			end
		end
	end
end

# Show is a method that loops through update and draw

MusicPlayerMain.new.show if __FILE__ == $0