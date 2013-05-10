require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require 'clockwork'

include Clockwork

Clockwork.configure do |config|
  config[:tz] = 'America/Indiana/Knox'
end

#every(1.day, 'Parse TV shows', :if => lambda { |t| t.thursday? }) { Delayed::Job.enqueue TvShow.parseIMDB }
#every(1.minute, 'Parse TV shows') { TvShow.parseIMDB }

#every(1.day, 'Parse genres', :if => lambda { |t| t.monday? }) { Delayed::Job.enqueue Genre.parseIMDB }
#every(1.minute, 'Parse genres') { Genre.parseIMDB }

#every(1.day, 'Parse ratings', :if => lambda { |t| t.tuesday? }) { Delayed::Job.enqueue Rating.parseIMDB }
#every(3.minutes, 'Parse ratings') { Rating.parseIMDB }
#every(1.minute, 'Parse ratings') { Rating.parseTVDB }


#every(1.day, 'Parse Feeds', :at => '12:30') { Delayed::Job.enqueue Review.downloadFeeds }
every(1.minute, 'Parse Feeds') { Review.downloadFeeds }

#every(7.days, 'Weekly parse TV shows', :at => '01:11') { TvShow.delay.parseIMDB }
