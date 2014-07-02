(function() {
  var $cells, $leftPane, $rightPane, ContentItem, ci, contentItems, gridster, group, item, refreshScrollablesIn, tab, _i, _j, _len, _len1, _ref, _ref1;

  gridster = void 0;

  ContentItem = (function() {
    function ContentItem(group, element) {
      this.group = group;
      this.element = element;
      this.$el = $(this.element);
      this.$el.on('click', '.button_add', (function(_this) {
        return function() {
          return _this.addToPage();
        };
      })(this));
      this.$el.data('contentItem', this);
      this.sizeX = 1;
      this.sizeY = 5;
      this.scale = 1;
    }

    ContentItem.prototype.addToPage = function() {
      this.$widget = gridster.add_widget(this.cellHTML(), this.sizeX, this.sizeY);
      this.$widget.on('click', '.button_remove', (function(_this) {
        return function() {
          return _this.removeFromPage();
        };
      })(this));
      this.$el.hide();
      return refreshScrollablesIn($leftPane);
    };

    ContentItem.prototype.removeFromPage = function() {
      if (this.$widget) {
        gridster.remove_widget(this.$widget, (function(_this) {
          return function() {
            _this.$widget = void 0;
            return _this.$el.show();
          };
        })(this));
      }
      return refreshScrollablesIn($leftPane);
    };

    ContentItem.prototype.cellHTML = function() {
      return "<div class=\"cell cell_" + this.group + "\">" + (this.$el.html()) + "</div";
    };

    ContentItem.prototype.setSize = function(x, y) {
      var ys;
      this.sizeX = 1;
      ys = 180 * y / x;
      this.sizeY = Math.floor(Math.ceil((ys + 10) / 38 - 0.1) + 0.1);
      if (this.$widget) {
        return gridster.resize_widget(this.$widget, this.sizeX, this.sizeY);
      }
    };

    return ContentItem;

  })();

  $leftPane = $('.pane_left');

  $rightPane = $('.pane_right');

  refreshScrollablesIn = function($pane) {
    var iscroll, scrollable, _i, _len, _ref, _results;
    _ref = $pane.find('.scrollable');
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      scrollable = _ref[_i];
      iscroll = $(scrollable).data('iscroll');
      _results.push(iscroll != null ? typeof iscroll.refresh === "function" ? iscroll.refresh() : void 0 : void 0);
    }
    return _results;
  };

  $cells = $('.gridster .cells').gridster({
    widget_selector: '.cell',
    widget_margins: [10, 10],
    widget_base_dimensions: [180, 28]
  });

  gridster = $cells.data('gridster');

  contentItems = [];

  _ref = $('.pane_left .tab-pane');
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    tab = _ref[_i];
    group = tab.id;
    _ref1 = $(tab).find('.item');
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      item = _ref1[_j];
      ci = new ContentItem(group, item);
      contentItems.push(ci);
    }
  }

  $(function() {
    $('pre').addClass('prettyprint');
    prettyPrint();
    return $(window).on('load', function() {
      var e, updateItemSizes, _k, _len2, _ref2;
      _ref2 = $('.scrollable').addClass('iscroll');
      for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
        e = _ref2[_k];
        $(e).data('iscroll', new IScroll(e, {
          mouseWheel: true,
          scrollbars: 'custom'
        }));
      }
      updateItemSizes = function() {
        var $i, _l, _len3, _results;
        _results = [];
        for (_l = 0, _len3 = contentItems.length; _l < _len3; _l++) {
          item = contentItems[_l];
          $i = $(item);
          if ($i.is(':visible')) {
            _results.push(item.setSize($i.width(), $i.height()));
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      };
      updateItemSizes();
      return $('#contents-tabs a').on('shown.bs.tab', function(e) {
        var _ref3;
        if ((_ref3 = $($(e.target).attr('href')).data('iscroll')) != null) {
          if (typeof _ref3.refresh === "function") {
            _ref3.refresh();
          }
        }
        return updateItemSizes();
      });
    });
  });

}).call(this);
