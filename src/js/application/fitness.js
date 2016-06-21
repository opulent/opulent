(function() {
  $('document').ready(function() {
    var resize_header;
    resize_header = function() {
      $('#header').height($(window).height());
    };
    resize_header();
    $(window).resize(resize_header);
    return $('#rock-slider').rockSlider({
      width: 1920,
      height: 1200,
      autoplay: true,
      layout: "fluid",
      scroller: true,
      delay: 4000,
      canvas_parallax: true,
      content_parallax: true,
      content_scaling: true,
      animation: {
        'in': "fade out, rotate x 90, scale 2, duration 500",
        'out': "fade out, rotate x -90, scale 2, duration 500"
      }
    });
  });

}).call(this);

//# sourceMappingURL=../src/maps/application/fitness.js.map
