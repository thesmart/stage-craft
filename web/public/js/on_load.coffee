# Add any code you want to execute on every page load
$().ready(->

  # Scan for <time> tags and convert to local/humanized time
  $('time.time').each((i, element)->
    element = $(element)
    time = element.data('time')
    time *= 1000 if typeof time == 'number'
    format = element.data('format')
    format = 'LLLL' unless format
    element.text(moment(time).format(format))
  )

  # Scan for <ago> tags and convert to local/humanized time
  $('time.ago').each((i, element)->
    element = $(element)
    time = element.data('time')
    time *= 1000 if typeof time == 'number'
    m = moment(time).max()

    updateAgo = ->
      ms = m - moment()
      element.text(moment.duration(ms).humanize(true))

    updateAgo()
    updateSeed = Math.floor(Math.random() * 10)
    window.setInterval(updateAgo, (25 + updateSeed) * 1000) # update every 25-35 seconds seconds
  )
)