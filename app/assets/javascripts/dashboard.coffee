# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready =>
  $('#support_source_tabs a[role=tab]').click (e)->
    e.preventDefault()
    $(this).tab('show')

window.selectAll = (supportSourceId)->
  $('#support_source_' + supportSourceId).
    find('.ticket-checkbox input').
    prop('checked', true)

window.selectNone = (supportSourceId)->
  $('#support_source_' + supportSourceId).
    find('.ticket-checkbox input').
    prop('checked', false)

window.ignoreSelectedTickets = (supportSourceId)->
  ids = $('#support_source_' + supportSourceId).
    find('.ticket-checkbox input:checked').
    map(-> $(this).data('ticket-id')).
    toArray()
  if ids.length > 0 and window.confirm('Are you sure? There is no undo!')
    jQuery.post('/dashboard/ignore',
      support_source_id: supportSourceId,
      ticket_ids: ids
    ).
      done(->
        window.location.reload()
      ).
      fail((e)->
        console.log(e)
        window.alert("HTTP error #{e.status} #{e.statusText}\n\n" +
          e.responseText)
      )
