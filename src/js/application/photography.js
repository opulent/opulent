(function() {
  $('document').ready(function() {
    return $('#rock-slider').rockSlider({
      width: 1920,
      height: 1100,
      autoplay: true,
      layout: "default",
      scroller: true,
      delay: 4000,
      canvas_parallax: false,
      content_parallax: false,
      content_scaling: true,
      thumbnails: true,
      animation: {
        "in": "scale 2, fade out",
        out: "scale 0.5, fade out"
      },
      overlap: 0.5,
      pagination: true,
      pagination_position: $('.rock-pagination-wrapper'),
      pagination_class: "rock-pagination-dark",
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

//# sourceMappingURL=../src/maps/application/photography.js.map
