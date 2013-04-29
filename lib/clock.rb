require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require 'clockwork'

include Clockwork

Clockwork.configure do |config|
  config[:tz] = 'America/Indiana/Knox'
end

#every(1.day, 'Parse TV shows', :at => '14:01') { Delayed::Job.enqueue TvShow.parseIMDB }
every(1.day, 'Parse TV shows', :at => '21:15') { Delayed::Job.enqueue TvShow.parseIMDB }
#every(1.minute, 'Parse genres') { Delayed::Job.enqueue Genre.parseIMDB }
#every(1.minute, 'Parse genres') { Delayed::Job.enqueue Genre.parseIMDB }

every(7.days, 'Weekly parse TV shows', :at => '01:11') { Delayed::Job.enqueue TvShow.parseIMDB }
