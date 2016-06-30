(function() {
  $('document').ready(function() {
    var responsive, sidebar;
    responsive = {
      xs: 0,
      sm: 544,
      md: 768,
      lg: 992,
      xl: 1200
    };
    sidebar = $('.nano');
    sidebar.nanoScroller({
      iOSNativeScrolling: true
    });
    sidebar.addClass('has-nano');
    $('.table-of-contents li a').on('click', function(e) {
      var target;
      target = $(e.currentTarget).attr('href');
      if (!/^#/.test(target)) {
        return;
      }
      target = $(target);
      $("html, body").animate({
        scrollTop: target.offset().top - 150
      }, 1000);
      if ($('#sidebar').hasClass('sidebar-visible')) {
        $('#sidebar-toggle').trigger('click');
      }
      e.preventDefault();
    });
    $('body').scrollspy({
      target: '#table-of-contents',
      offset: 150
    });
    $('#sidebar-toggle').on('click', (function(_this) {
      return function() {
        $('#sidebar').toggleClass('sidebar-visible');
      };
    })(this));
    $(window).resize((function(_this) {
      return function() {
        var window_width;
        window_width = $(window).width();
        if (window_width < responsive['md'] && sidebar.hasClass('has-nano')) {
          sidebar.removeClass('has-nano');
          sidebar.nanoScroller({
            destroy: true
          });
          $('.nano-pane', sidebar).remove();
        } else if (window_width >= responsive['md'] && !sidebar.hasClass('has-nano')) {
          sidebar.addClass('has-nano');
          sidebar.nanoScroller({
            iOSNativeScrolling: true
          });
        }
      };
    })(this)).trigger('resize');
    $('.social-icons a').each(function(index, icon) {
      var color_class;
      color_class = 'social-colored social-' + $(icon).attr('data-color');
      $(icon).on('mouseenter', (function(_this) {
        return function() {
          $('#social-section').addClass(color_class);
        };
      })(this));
      $(icon).on('mouseleave', (function(_this) {
        return function() {
          $('#social-section').removeClass(color_class);
        };
      })(this));
    });
    SyntaxHighlighter.defaults.toolbar = false;
    SyntaxHighlighter.all();
  });

}).call(this);

//# sourceMappingURL=../../maps/application/documentation.js.map
