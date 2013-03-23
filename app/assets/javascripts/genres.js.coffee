# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $('#genres').dataTable
    sDom: "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>"
    sPaginationType: "bootstrap"
    bSortClasses: false
    bProcessing: true
    bServerSide: true
    sAjaxSource: $('#genres').data('source')
    oLanguage: { sProcessing: "<img src='/assets/loading.gif'>" }