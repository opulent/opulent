(function() {
  $('document').ready(function() {
    $('.nano').nanoScroller();
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
      e.preventDefault();
    });
    $('body').scrollspy({
      target: '#table-of-contents',
      offset: 150
    });
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
