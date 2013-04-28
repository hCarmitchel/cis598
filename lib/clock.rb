require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require 'clockwork'

include Clockwork

every(1.day, 'Parse TV shows', :at => '05:00') { Delayed::Job.enqueue TvShow.parseIMDB }
every(17.days, 'Weekly parse TV shows', :at => '01:11') { Delayed::Job.enqueue TvShow.parseIMDB }