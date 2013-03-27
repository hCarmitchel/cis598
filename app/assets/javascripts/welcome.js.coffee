# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


jQuery ->
	Morris.Line({
      element: 'tv_shows_chart'
      data: $('#tv_shows_chart').data('tv-shows')
      xkey: 'year_released'
      ykeys: ['count', 'count_eps']
      labels: ['TV shows', 'TV episodes']
	});

jQuery ->
	Morris.Donut({
      element: 'genres_pie_chart'
      data: $('#genres_pie_chart').data('genres')
	});

jQuery ->
      Morris.Area({
      element: 'genres_chart'
      data: $('#genres_chart').data('genres')
      xkey: 'year_released'
      ykeys: ['comedy','drama','documentary','animation','realitytv']
      labels: ['Comedy','Drama','Documentary','Animation','Reality TV']
      });

jQuery ->
      Morris.Area({
      element: 'ratings_chart'
      data: $('#ratings_chart').data('ratings')
      xkey: 'year_released'
      ykeys: ['count']
      labels: ['count']
      });

