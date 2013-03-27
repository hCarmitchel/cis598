class WelcomeController < ApplicationController
	def stats
		@genres = Genre.total_grouped_by_genre
	end
	def upload
	  uploaded_io = params[:person][:import]
	  File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'w') do |file|
	    file.write(uploaded_io.read)
	  end
	end
end
