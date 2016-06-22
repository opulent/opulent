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
      $("html").velocity("scroll", {
        offset: (target.offset().top) + "px",
        mobileHA: false
      });
      e.preventDefault();
    });
    SyntaxHighlighter.defaults.toolbar = false;
    SyntaxHighlighter.all();
  });

}).call(this);

//# sourceMappingURL=../../maps/application/documentation.js.map
