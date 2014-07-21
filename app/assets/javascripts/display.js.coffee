#= require 'lodash.underscore.min'
#= require 'backbone-min'
#= require 'backbone.marionette.min'
#= require 'iscroll'
#= require 'jquery.gridster'


window.DisplayApplication = new Marionette.Application

$ ->
  if location.pathname is '/'
    DisplayApplication.start()


class window.DisplayItem extends Backbone.Model

class window.DisplayItems extends Backbone.Collection
  # model: DisplayItem
window.displayedItems = new Backbone.Collection


class window.Exhibit extends DisplayItem
  getView: -> window.ExhibitView

class window.Exhibits extends Backbone.Collection
  model: Exhibit


class window.Note extends DisplayItem
  getView: -> window.NoteView

class window.Notes extends Backbone.Collection
  model: Note


class window.DisplayItemView extends Marionette.ItemView
  triggers:
    'click .button-add': 'buttonAdd:click'
    'click .button-remove': 'buttonRemove:click'
    'click .button-toggle-size': 'buttonToggleSize:click'
  onRender: ->
    @on 'buttonAdd:click', (e) ->
      unless e.model.get 'addedToDisplay'
        window.displayedItems.add e.model
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
      @$el.addClass('item-displayed')
    removedFromDisplay: ->
      @$el.removeClass('item-displayed')
  getScale: ->
    @$el.data('scale') or 1
  setScale: (scale) ->
    @$el.data 'scale', scale
  toggleSize: ->
    scale = @getScale()
    @setScale if scale is 1 then 2 else 1


class window.ExhibitView extends DisplayItemView
  template: '#tmpl_exhibit'


class window.NoteView extends DisplayItemView
  template: '#tmpl_note'


class GridsterCollectionView extends Marionette.CollectionView
  minCols: 1
  maxCols: 5
  margins: [10, 10]
  baseDimensions: [180, 10]
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
  attachHtml: (collectionView, childView, index) ->
    childView.$el.addClass('cell')
    $widget = @gridster.add_widget childView.el
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
    unless childView.originalSize
      $c = childView.$el.children()
      w = $c.width()
      h = $c.height()
      sizeX = Math.ceil((w + @margins[0]) / (@baseDimensions[0] + @margins[0] * 2) - 0.001)
      sizeY = Math.ceil((h + @margins[1]) / (@baseDimensions[1] + @margins[1] * 2) - 0.001)
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


class window.DisplayView extends GridsterCollectionView
  minCols: 3
  maxCols: 3
  getChildView: (child) ->
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
