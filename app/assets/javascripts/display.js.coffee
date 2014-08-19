#= require 'underscore-min'
#= require 'backbone-min'
#= require 'backbone.marionette.min'
#= require 'iscroll'
# require 'jquery.coords'
# require 'jquery.collision'
# require 'jquery.draggable'
#= require 'utils'
#= require 'jquery-ui.min'
# require 'jquery.animate-enhanced.min'
# require 'jquery.gridster'


window.DisplayApplication = new Marionette.Application

$ ->
  if location.pathname is '/'
    DisplayApplication.start()


class window.DisplayItem extends Backbone.Model
  initialize: ->
    @id = @constructor.name + '_' + @id
  getView: -> window.DisplayItemView

class window.DisplayItems extends Backbone.Collection
  model: DisplayItem
window.displayedItems = new DisplayItems
window.displayedItems.reset()


class window.Exhibit extends DisplayItem
  getView: -> window.ExhibitView

class window.Exhibits extends Backbone.Collection
  model: Exhibit


class window.Note extends DisplayItem
  getView: -> window.NoteView

class window.Notes extends Backbone.Collection
  model: Note


class window.DisplayItemView extends Marionette.ItemView
  itemClassName: 'item'
  triggers:
    'click .button-add': 'buttonAdd:click'
    'click .button-remove': 'buttonRemove:click'
    'click .button-toggle-size': 'buttonToggleSize:click'
  onRender: ->
    @$el.addClass @itemClassName
    @on 'buttonAdd:click', (e) ->
      unless e.model.get 'addedToDisplay'
        window.displayedItems.push e.model
        e.model.set 'addedToDisplay', true
        e.model.trigger 'addedToDisplay'
    @on 'buttonRemove:click', (e) ->
      if e.model.get 'addedToDisplay'
        window.displayedItems.remove e.model
        e.model.set 'addedToDisplay', false
        e.model.trigger 'removedFromDisplay'
    @on 'buttonToggleSize:click', (e) ->
      e.view.toggleSize()
      e.view.trigger 'resize'
  modelEvents:
    addedToDisplay: ->
      @$el.addClass('item_displayed')
    removedFromDisplay: ->
      @$el.removeClass('item_displayed')
  getScale: ->
    @$el.data('scale') or 1
  setScale: (scale) ->
    @$el.data 'scale', scale
  toggleSize: ->
    scale = @getScale()
    @setScale if scale is 1 then 2 else 1


class window.ExhibitView extends DisplayItemView
  template: '#tmpl_exhibit'
  itemClassName: 'item item_exhibit'


class window.NoteView extends DisplayItemView
  basicSize: [2, 2]
  getScale: -> 2
  template: '#tmpl_note'
  itemClassName: 'item item_note'


class GridsterCollectionView extends Marionette.CollectionView
  minCols: 1
  maxCols: 5
  margins: [ 25, 10 ]
  currentMargins: [ 25, 10 ]
  baseDimensions: [ 200, 10 ]
  currentDimensions: [ 200, 10 ]
  enableDragging: true
  initialize: ->
    @$el.gridster
      widget_selector: '.cell'
      widget_margins: @margins
      widget_base_dimensions: @baseDimensions
      min_cols: @minCols
      max_cols: @maxCols
    @gridster = @$el.data 'gridster'
    @gridster.disable() unless @enableDragging
    @$parent = @$el.closest('article')
    if @$parent.length
      @resizeGridster()
      $(window).on 'resize', => @resizeGridster()
  resizeGridster: ->
    ratio = @$parent.width() / (@maxCols * (@baseDimensions[0] + @margins[0] * 2))
    @currentDimensions[0] = @baseDimensions[0] * ratio
    @currentDimensions[1] = @baseDimensions[1] * ratio
    @currentMargins[0] = @margins[0] * ratio
    @currentMargins[1] = @margins[1] * ratio
    @gridster.resize_widget_dimensions
      widget_base_dimensions: [
        @currentDimensions[0]
        @currentDimensions[1]
      ]
      widget_margins: [
        @currentMargins[0]
        @currentMargins[1]
      ]
  attachHtml: (collectionView, childView, index) ->
    childView.$el.addClass('cell')
    basicSize = childView.basicSize or [undefined, undefined]
    $widget = @gridster.add_widget childView.el, basicSize[0], basicSize[1]
    $imgs = $widget.find('img').css('opacity', 0)
    if $imgs.length
      promises = for img in $imgs
        dfd = $.Deferred()
        $(img)
          .on('load', dfd.resolve)
          .on('error', dfd.reject)
        dfd.promise()
      $.when(promises...).then =>
        $imgs.css('opacity', '')
        @resizeWidget(childView)
    else
      @resizeWidget(childView)
  resizeWidget: (childView) ->
    scale = childView.getScale()
    basicSize = childView.basicSize or [1, 1]
    unless childView.originalSize
      $c = childView.$el.children()
      w = $c.width()
      h = $c.height()
      sizeX = Math.ceil((w + @currentMargins[0]) / (@currentDimensions[0] + @currentMargins[0] * 2) / basicSize[0] - 0.001)
      sizeY = Math.ceil((h + @currentMargins[1]) / (@currentDimensions[1] + @currentMargins[1] * 2) / basicSize[1] - 0.001)
      childView.originalSize =
        x: sizeX
        y: sizeY
    else
      sizeX = childView.originalSize.x
      sizeY = childView.originalSize.y
    @gridster.resize_widget childView.$el, sizeX * scale, sizeY * scale
  onBeforeRemoveChild: (childView) ->
    @gridster.remove_widget childView.$el
  childEvents:
    'resize': (childView) ->
      @resizeWidget childView


class window.ExhibitListView extends Marionette.CollectionView
  initialize: ->
  childView: ExhibitView


class window.NoteListView extends Marionette.CollectionView
  initialize: ->
  childView: NoteView


class window.DisplayView extends Marionette.CollectionView
  # minCols: 3
  maxCols: 3
  _findRows: ->
    @$rows = @$el.children('.display-row')
  _addRow: ->
    $row = $('<div class="display-row"></div>')
    $row.appendTo(@$el)
    # @_setupSortable($row, true)
    @_findRows()
    $row
  _setupTemps: ($col) ->
    $rows = @$el.children()
    for row in $rows
      $row = $(row)
      unless $row.is('.display-row_full')
        $cols = $row.children('.display-col')
        continue unless $cols.length
        $firstCol = $cols.first()
        $lastCol = $cols.last()
        $colA = $('<div class="display-col display-col_temp display-col_temp-l"></div>').prependTo($row)
        # $colA.css 'left', $firstCol.position().left - $colA[0].offsetWidth
        $colA.height $row.height()
        @_setupSortable($colA)
        $colB = $('<div class="display-col display-col_temp display-col_temp-r"></div>').appendTo($row)
        # $colB.css 'left', $lastCol.position().left + $lastCol[0].offsetWidth
        $colB.height $row.height()
        @_setupSortable($colB)
    # $rowA = @_addRow().addClass('display-row_temp display-row_temp-t')
    # $rowA.remove().prependTo(@$el)
    # $colA = $('<div class="display-col display-col_temp display-col_temp-t"></div>').appendTo($rowA)
    # @_setupSortable($colA)
    $rowB = @_addRow().addClass('display-row_temp display-row_temp-b')
    # $rowB.remove().appendTo(@$el)
    $colB = $('<div class="display-col display-col_temp display-col_temp-b"></div>').appendTo($rowB)
    @_setupSortable($colB)
    $col.sortable('refresh')
  _removeTemps: ($col) ->
    $rows = @$el.children()
    for row in $rows
      $row = $(row)
      $tempCols = $row.find('.display-col_temp')
      for tc in $tempCols
        $tc = $(tc)
        if $tc.children().length
          $tc.removeClass 'display-col_temp display-col_temp-l display-col_temp-r'
          $tc.css 'height', ''
        else
          $tc.remove()
      if $row.is('.display-row_temp')
        if $row.children().length
          $row.removeClass 'display-row_temp display-row_temp-t display-row_temp-b'
          $tc.css 'height', ''
        else
          $row.remove()
  _setupSortable: ($el, isRow = false) ->
    # return true if isRow
    $el.sortable
      # helper: 'clone'
      # appendTo: @$el
      connectWith: '.display-col'
      items: '.item'
      placeholder: 'display-placeholder'
      forcePlaceholderSize: true
      # forcePlaceholderSize: false
      start: (e, ui) =>
        $col = $(e.target)
        @_setupTemps($col)
        @$el.addClass('on-sorting')
      stop: (e, ui) =>
        console.log 'stop', e.target
        $col = $(e.target)
        @_removeTemps($col)
        $row = $col.closest('.display-row')
        @_cleanUp($row, $col)
        @$el.removeClass('on-sorting')
      change: (e, ui) =>
        console.log 'change', e.target
      update: (e, ui) =>
        console.log 'update', e.target
      remove: (e, ui) =>
        $col = $(e.target)
        unless $col.is('.display-col')
          # @_cleanUp($col)
        else
          $row = $col.closest('.display-row')
          # @_cleanUp($row, $col)
  _findOrAddRow: ->
    $row = @_findRows().not('.display-row_full')
    if $row.length
      $row.last()
    else
      @_addRow()
  _rowSize: ($row) ->
    rs = 0
    rs += ($(col).data('sizeX') or 1) for col in $row.children()
    rs
  _updateRow: ($row) ->
    $row.toggleClass('display-row_full', @_rowSize($row) >= 3)
    # $row.sortable('refresh')
  # initialize: ->
  onRender: ->
    @$scrollParent = @$el.scrollParent()
  _addColToRow: ($row, type) ->
    $col = $('<div class="display-col"></div>')
    $row.append $col
    @_setupSortable($col)
    $col
  _scrollToElement: ($el) ->
    @$scrollParent.animate({scrollTop: @$scrollParent[0].scrollTop + $el.offset().top})
  attachHtml: (collectionView, childView, index) ->
    # $col = $('<div class="display-col"></div>').append(childView.$el)
    sizeX = if childView.basicSize then childView.basicSize[0] else 1
    $row = @_findOrAddRow(sizeX)
    $col = @_addColToRow $row
    $col.data('sizeX', sizeX)
    $col.append childView.$el
    # $col.sortable
    #   connectWith: '.display-col'
    #   placeholder: 'display-placeholder'
    #   forcePlaceholderSize: true
    # $row.children('.display-col_last').before($col)
    # $row.append($col)
    @_updateRow($row)
    @_scrollToElement(childView.$el)
  _cleanUp: ($row, $col) ->
    $col.remove() if $col? and $col.children().length == 0
    if $row.children().length == 0
      $row.remove()
    else
      @_updateRow($row)
  onBeforeRemoveChild: (childView) ->
    $col = childView.$el.closest('.display-col')
    $row = $col.closest('.display-row')
    childView.$el.remove()
    @_cleanUp($row, $col)
  getChildView: (child) ->
    if child instanceof DisplayItem
      child.getView()


window.displayItems =
  exhibits: new Exhibits
  notes: new Notes


DisplayApplication.addInitializer ->
  elv = new ExhibitListView
    collection: displayItems.exhibits
    el: '#objects .items'
  elv.render()
  nlv = new NoteListView
    collection: displayItems.notes
    el: '#texts .items'
  nlv.render()
  dv = new DisplayView
    collection: displayedItems
    el: '#display-view'
  dv.render()

  $ct = $('#contents-tabs')
  $pl = $('.pane_left')
  resizeTabs = ->
    position = $ct.css('position')
    if position is 'absolute'
      $ct.width($pl.height())
    else
      $ct.width('auto')
  resizeTabsSafe = _.throttle(resizeTabs, 12)
  if $ct.length
    resizeTabs()
    $(window).on 'resize', resizeTabsSafe

  $panes = $('.panes')
  $pr = $('.pane_right')
  panesFull = false
  togglePanes = (full) ->
    return true if panesFull is full
    panesFull = full
    $panes.toggleClass('panes_full', panesFull)
    $pr.animate {
      left: if panesFull then '39px' else '25%'
      # width: if panesFull then 'auto' else '75%'
    }, 300
  $('.button-pane-expand, .button-pane-collapse').on 'click', (e) ->
    e.preventDefault()
    togglePanes(!panesFull)
    # dv.resizeGridster()
  $ct.on 'click', 'a', (e) ->
    togglePanes(false)

# class ContentItem extends Backbone.Model
#
#   constructor: (@group, @element) ->
#     @$el = $(@element)
#     @$el.on 'click', '.button_add', =>
#       @addToPage()
#     @$el.data('contentItem', this)
#     @sizeX = 1
#     @sizeY = 5
#     @scale = 1
#
#   addToPage: ->
#     @$widget = gridster.add_widget(@cellHTML(), @sizeX, @sizeY)
#     @$widget.on 'click', '.button_remove', =>
#       @removeFromPage()
#     @$el.hide()
#     refreshScrollablesIn($leftPane)
#
#   removeFromPage: ->
#     if @$widget
#       gridster.remove_widget @$widget, =>
#         @$widget = undefined
#         @$el.show()
#     refreshScrollablesIn($leftPane)
#
#   cellHTML: ->
#     "<div class=\"cell cell_#{@group}\">#{@$el.html()}</div"
#
#   setSize: (x, y) ->
#     @sizeX = 1
#     ys = 180 * y / x
#     @sizeY = Math.floor(Math.ceil((ys + 10) / 38 - 0.1) + 0.1)
#     if @$widget
#       gridster.resize_widget @$widget, @sizeX, @sizeY
#
#
# $leftPane = $('.pane_left')
# $rightPane = $('.pane_right')
# refreshScrollablesIn = ($pane) ->
#   for scrollable in $pane.find('.scrollable')
#     iscroll = $(scrollable).data('iscroll')
#     iscroll?.refresh?()
#
# $cells = $('.gridster .cells').gridster
#   widget_selector: '.cell'
#   widget_margins: [10, 10]
#   widget_base_dimensions: [180, 28]
#
# gridster = $cells.data('gridster')
#
# contentItems = []
# for tab in $('.pane_left .tab-pane')
#   group = tab.id
#   for item in $(tab).find('.item')
#     ci = new ContentItem(group, item)
#     contentItems.push(ci)
#
#
# $ ->
#
#   # $('pre').addClass('prettyprint')
#   # prettyPrint()
#
#   $(window).on 'load', ->
#     for e in $('.scrollable').addClass('iscroll')
#       $(e).data 'iscroll', new IScroll e, mouseWheel: true, scrollbars: 'custom'
#
#     updateItemSizes = ->
#       for item in contentItems
#         $i = $(item)
#         item.setSize($i.width(), $i.height()) if $i.is(':visible')
#
#     updateItemSizes()
#
#     $('#contents-tabs a')
#       .on 'shown.bs.tab', (e) ->
#         $($(e.target).attr('href')).data('iscroll')?.refresh?()
#         updateItemSizes()
