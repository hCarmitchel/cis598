require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require 'clockwork'

include Clockwork

every(2.minutes, 'Parse TV shows') { Delayed::Job.enqueue TvShow.parseIMDB }
every(7.days, 'Weekly parse TV shows', :at => '01:11') { Delayed::Job.enqueue TvShow.parseIMDB }