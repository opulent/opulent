(function() {
  $('document').ready(function() {
    return $('#rock-slider').rockSlider({
      width: 1920,
      height: 1000,
      autoplay: true,
      layout: "swipe",
      scroller: true,
      delay: 9000,
      canvas_parallax: false,
      content_parallax: false,
      content_scaling: true,
      thumbnails: true,
      thumbnails_visible: {
        xs: 5,
        sm: 5,
        md: 5,
        lg: 5,
        xlg: 5
      }
    });
  });

}).call(this);

//# sourceMappingURL=../src/maps/application/realestate.js.map
