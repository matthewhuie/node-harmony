$(document).ajaxStart ->
  Pace.restart()

$('#dropzone').on 'dragenter', (event) ->
  event.stopPropagation()
  event.preventDefault()
  clearStatus()
  $('body').addClass 'dragover'
  $('#message').html 'Drop now to harmonize'
.on 'dragleave', (event) ->
  event.stopPropagation()
  event.preventDefault()
  clearStatus()
  $('#message').html 'Drop a file anywhere to harmonize'
.on 'dragover', (event) ->
  event.stopPropagation()
  event.preventDefault()
  event.originalEvent.dataTransfer.dropEffect = 'copy'
.on 'drop', (event) ->
  event.stopPropagation()
  event.preventDefault()
  $('#message').html 'Harmonizing <i>' + event.originalEvent.dataTransfer.files[0].name + '</i> ...'
  Papa.parse event.originalEvent.dataTransfer.files[0],
    header: true,
    error: (error) ->
      clearStatus()
      $('body').addClass 'bad'
      $('#message').html 'Invalid file'
    complete: (results) ->
      if _.size(_.intersection results.meta.fields, ['name', 'latitude', 'longitude']) == 3
        $('#dropzone').hide()
        $.ajax 
          url: '/harmonize'
          data: JSON.stringify(results.data)
          type: 'POST'
          dataType: 'json'
          contentType: 'application/json; charset=utf-8'
          success: (data) ->
            $('#dropzone').show()
            clearStatus()
            $('body').addClass 'good'
            $('#message').html 'Done!' 
            csv = new Blob [Papa.unparse data],
              type: 'text/csv;charset=utf-8;'
            $('<a></a>').attr 'href', window.URL.createObjectURL csv
              .get(0).click()
      else
        clearStatus()
        $('body').addClass 'bad'
        $('#message').html 'Invalid file'

clearStatus = ->
  $('body').removeClass 'dragover'
    .removeClass 'good'
    .removeClass 'bad'
