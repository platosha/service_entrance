gridster = undefined


class ContentItem

  constructor: (@group, @element) ->
    @$el = $(@element)
    @$el.on 'click', '.button_add', =>
      @addToPage()
    @$el.data('contentItem', this)
    @sizeX = 1
    @sizeY = 5
    @scale = 1

  addToPage: ->
    @$widget = gridster.add_widget(@cellHTML(), @sizeX, @sizeY)
    @$widget.on 'click', '.button_remove', =>
      @removeFromPage()
    @$el.hide()
    refreshScrollablesIn($leftPane)

  removeFromPage: ->
    if @$widget
      gridster.remove_widget @$widget, =>
        @$widget = undefined
        @$el.show()
    refreshScrollablesIn($leftPane)

  cellHTML: ->
    "<div class=\"cell cell_#{@group}\">#{@$el.html()}</div"

  setSize: (x, y) ->
    @sizeX = 1
    ys = 180 * y / x
    @sizeY = Math.floor(Math.ceil((ys + 10) / 40 - 0.1) + 0.1)
    if @$widget
      gridster.resize_widget @$widget, @sizeX, @sizeY


$leftPane = $('.pane_left')
$rightPane = $('.pane_right')
refreshScrollablesIn = ($pane) ->
  for scrollable in $pane.find('.scrollable')
    iscroll = $(scrollable).data('iscroll')
    iscroll?.refresh?()

$cells = $('.gridster .cells').gridster
  widget_selector: '.cell'
  widget_margins: [10, 10]
  widget_base_dimensions: [180, 30]

gridster = $cells.data('gridster')

contentItems = []
for tab in $('.pane_left .tab-pane')
  group = tab.id
  for item in $(tab).find('.item')
    ci = new ContentItem(group, item)
    contentItems.push(ci)


$ ->

  $('pre').addClass('prettyprint')
  prettyPrint()

  $(window).on 'load', ->
    for e in $('.scrollable').addClass('iscroll')
      $(e).data 'iscroll', new IScroll e, mouseWheel: true, scrollbars: 'custom'

    updateItemSizes = ->
      for item in contentItems
        $i = $(item)
        item.setSize($i.width(), $i.height()) if $i.is(':visible')

    updateItemSizes()

    $('#contents-tabs a')
      .on 'shown.bs.tab', (e) ->
        $($(e.target).attr('href')).data('iscroll')?.refresh?()
        updateItemSizes()
