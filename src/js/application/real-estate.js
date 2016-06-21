(function() {
  $('document').ready(function() {
    return $('#rock-slider').rockSlider({
      width: 1920,
      height: 1200,
      autoplay: true,
      layout: "swipe",
      scroller: true,
      delay: 4000,
      canvas_parallax: false,
      content_parallax: false,
      content_scaling: true,
      thumbnails: true,
      thumbnails_visible: {
        xs: 4,
        sm: 4,
        md: 4,
        lg: 4,
        xlg: 4
      },
      thumbnails_orientation: 'vertical',
      thumbnails_position: $('.rock-thumbnails-container')
    });
  });

}).call(this);

//# sourceMappingURL=../src/maps/application/real-estate.js.map
