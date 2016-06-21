
/*

                  oo

.d8888b. 88d888b. dP 88d8b.d8b. dP    dP .d8888b.
88'  `88 88'  `88 88 88'`88'`88 88    88 Y8ooooo.
88.  .88 88    88 88 88  88  88 88.  .88       88
`88888P8 dP    dP dP dP  dP  dP `88888P' `88888P'
oooooooooooooooooooooooooooooooooooooooooooooooooo

@plugin    jQuery
@license   CodeCanyon Standard / Extended
@author    Alex Grozav
@company   Pixevil
@website   http://pixevil.com
@email     alex@grozav.com
 */

(function() {
  (function($, window, document) {
    'use strict';

    /* Externalize the packagedEffects data so that they can optionally be modified and re-registered. */

    /* Support: <=IE8: Callouts will have no effect, and transitions will simply fade in/out. IE9/Android 2.3: Most effects are fully supported, the rest fade in/out. All other browsers: full support. */
    var animus_presets, preset;
    animus_presets = {
      'bounce': {
        defaultDuration: 550,
        calls: [
          [
            {
              translateY: -30
            }, 0.25
          ], [
            {
              translateY: 0
            }, 0.125
          ], [
            {
              translateY: -15
            }, 0.125
          ], [
            {
              translateY: 0
            }, 0.25
          ]
        ]
      },
      'shake': {
        defaultDuration: 800,
        calls: [
          [
            {
              translateX: -11
            }, 0.125
          ], [
            {
              translateX: 11
            }, 0.125
          ], [
            {
              translateX: -11
            }, 0.125
          ], [
            {
              translateX: 11
            }, 0.125
          ], [
            {
              translateX: -11
            }, 0.125
          ], [
            {
              translateX: 11
            }, 0.125
          ], [
            {
              translateX: -11
            }, 0.125
          ], [
            {
              translateX: 0
            }, 0.125
          ]
        ]
      },
      'flash': {
        defaultDuration: 1100,
        calls: [
          [
            {
              opacity: [0, 'easeInOutQuad', 1]
            }, 0.25
          ], [
            {
              opacity: [1, 'easeInOutQuad']
            }, 0.25
          ], [
            {
              opacity: [0, 'easeInOutQuad']
            }, 0.25
          ], [
            {
              opacity: [1, 'easeInOutQuad']
            }, 0.25
          ]
        ]
      },
      'pulse': {
        defaultDuration: 825,
        calls: [
          [
            {
              scaleX: 1.1,
              scaleY: 1.1
            }, 0.50, {
              easing: 'easeInExpo'
            }
          ], [
            {
              scaleX: 1,
              scaleY: 1
            }, 0.50
          ]
        ]
      },
      'swing': {
        defaultDuration: 950,
        calls: [
          [
            {
              rotateZ: 15
            }, 0.20
          ], [
            {
              rotateZ: -10
            }, 0.20
          ], [
            {
              rotateZ: 5
            }, 0.20
          ], [
            {
              rotateZ: -5
            }, 0.20
          ], [
            {
              rotateZ: 0
            }, 0.20
          ]
        ]
      },
      'tada': {
        defaultDuration: 1000,
        calls: [
          [
            {
              scaleX: 0.9,
              scaleY: 0.9,
              rotateZ: -3
            }, 0.10
          ], [
            {
              scaleX: 1.1,
              scaleY: 1.1,
              rotateZ: 3
            }, 0.10
          ], [
            {
              scaleX: 1.1,
              scaleY: 1.1,
              rotateZ: -3
            }, 0.10
          ], ['reverse', 0.125], ['reverse', 0.125], ['reverse', 0.125], ['reverse', 0.125], ['reverse', 0.125], [
            {
              scaleX: 1,
              scaleY: 1,
              rotateZ: 0
            }, 0.20
          ]
        ]
      },
      'fadeIn': {
        defaultDuration: 500,
        calls: [
          [
            {
              opacity: [1, 0]
            }
          ]
        ]
      },
      'fadeOut': {
        defaultDuration: 500,
        calls: [
          [
            {
              opacity: [0, 1]
            }
          ]
        ]
      },
      'flipXIn': {
        defaultDuration: 700,
        calls: [
          [
            {
              opacity: [1, 0],
              transformPerspective: [800, 800],
              rotateY: [0, -55]
            }
          ]
        ],
        reset: {
          transformPerspective: 0
        }
      },
      'flipXOut': {
        defaultDuration: 700,
        calls: [
          [
            {
              opacity: [0, 1],
              transformPerspective: [800, 800],
              rotateY: 55
            }
          ]
        ],
        reset: {
          transformPerspective: 0,
          rotateY: 0
        }
      },
      'flipYIn': {
        defaultDuration: 800,
        calls: [
          [
            {
              opacity: [1, 0],
              transformPerspective: [800, 800],
              rotateX: [0, -45]
            }
          ]
        ],
        reset: {
          transformPerspective: 0
        }
      },
      'flipYOut': {
        defaultDuration: 800,
        calls: [
          [
            {
              opacity: [0, 1],
              transformPerspective: [800, 800],
              rotateX: 25
            }
          ]
        ],
        reset: {
          transformPerspective: 0,
          rotateX: 0
        }
      },
      'flipBounceXIn': {
        defaultDuration: 900,
        calls: [
          [
            {
              opacity: [0.725, 0],
              transformPerspective: [400, 400],
              rotateY: [-10, 90]
            }, 0.50
          ], [
            {
              opacity: 0.80,
              rotateY: 10
            }, 0.25
          ], [
            {
              opacity: 1,
              rotateY: 0
            }, 0.25
          ]
        ],
        reset: {
          transformPerspective: 0
        }
      },
      'flipBounceXOut': {
        defaultDuration: 800,
        calls: [
          [
            {
              opacity: [0.9, 1],
              transformPerspective: [400, 400],
              rotateY: -10
            }, 0.50
          ], [
            {
              opacity: 0,
              rotateY: 90
            }, 0.50
          ]
        ],
        reset: {
          transformPerspective: 0,
          rotateY: 0
        }
      },
      'flipBounceYIn': {
        defaultDuration: 850,
        calls: [
          [
            {
              opacity: [0.725, 0],
              transformPerspective: [400, 400],
              rotateX: [-10, 90]
            }, 0.50
          ], [
            {
              opacity: 0.80,
              rotateX: 10
            }, 0.25
          ], [
            {
              opacity: 1,
              rotateX: 0
            }, 0.25
          ]
        ],
        reset: {
          transformPerspective: 0
        }
      },
      'flipBounceYOut': {
        defaultDuration: 800,
        calls: [
          [
            {
              opacity: [0.9, 1],
              transformPerspective: [400, 400],
              rotateX: -15
            }, 0.50
          ], [
            {
              opacity: 0,
              rotateX: 90
            }, 0.50
          ]
        ],
        reset: {
          transformPerspective: 0,
          rotateX: 0
        }
      },
      'swoopIn': {
        defaultDuration: 850,
        calls: [
          [
            {
              opacity: [1, 0],
              transformOriginX: ['100%', '50%'],
              transformOriginY: ['100%', '100%'],
              scaleX: [1, 0],
              scaleY: [1, 0],
              translateX: [0, -700],
              translateZ: 0
            }
          ]
        ],
        reset: {
          transformOriginX: '50%',
          transformOriginY: '50%'
        }
      },
      'swoopOut': {
        defaultDuration: 850,
        calls: [
          [
            {
              opacity: [0, 1],
              transformOriginX: ['50%', '100%'],
              transformOriginY: ['100%', '100%'],
              scaleX: 0,
              scaleY: 0,
              translateX: -700,
              translateZ: 0
            }
          ]
        ],
        reset: {
          transformOriginX: '50%',
          transformOriginY: '50%',
          scaleX: 1,
          scaleY: 1,
          translateX: 0
        }
      },
      'whirlIn': {
        defaultDuration: 850,
        calls: [
          [
            {
              opacity: [1, 0],
              transformOriginX: ['50%', '50%'],
              transformOriginY: ['50%', '50%'],
              scaleX: [1, 0],
              scaleY: [1, 0],
              rotateY: [0, 160]
            }, 1, {
              easing: 'easeInOutSine'
            }
          ]
        ]
      },
      'whirlOut': {
        defaultDuration: 750,
        calls: [
          [
            {
              opacity: [0, 'easeInOutQuint', 1],
              transformOriginX: ['50%', '50%'],
              transformOriginY: ['50%', '50%'],
              scaleX: 0,
              scaleY: 0,
              rotateY: 160
            }, 1, {
              easing: 'swing'
            }
          ]
        ],
        reset: {
          scaleX: 1,
          scaleY: 1,
          rotateY: 0
        }
      },
      'shrinkIn': {
        defaultDuration: 750,
        calls: [
          [
            {
              opacity: [1, 0],
              transformOriginX: ['50%', '50%'],
              transformOriginY: ['50%', '50%'],
              scaleX: [1, 1.5],
              scaleY: [1, 1.5],
              translateZ: 0
            }
          ]
        ]
      },
      'shrinkOut': {
        defaultDuration: 600,
        calls: [
          [
            {
              opacity: [0, 1],
              transformOriginX: ['50%', '50%'],
              transformOriginY: ['50%', '50%'],
              scaleX: 1.3,
              scaleY: 1.3,
              translateZ: 0
            }
          ]
        ],
        reset: {
          scaleX: 1,
          scaleY: 1
        }
      },
      'expandIn': {
        defaultDuration: 700,
        calls: [
          [
            {
              opacity: [1, 0],
              transformOriginX: ['50%', '50%'],
              transformOriginY: ['50%', '50%'],
              scaleX: [1, 0.625],
              scaleY: [1, 0.625],
              translateZ: 0
            }
          ]
        ]
      },
      'expandOut': {
        defaultDuration: 700,
        calls: [
          [
            {
              opacity: [0, 1],
              transformOriginX: ['50%', '50%'],
              transformOriginY: ['50%', '50%'],
              scaleX: 0.5,
              scaleY: 0.5,
              translateZ: 0
            }
          ]
        ],
        reset: {
          scaleX: 1,
          scaleY: 1
        }
      },
      'bounceIn': {
        defaultDuration: 800,
        calls: [
          [
            {
              opacity: [1, 0],
              scaleX: [1.05, 0.3],
              scaleY: [1.05, 0.3]
            }, 0.40
          ], [
            {
              scaleX: 0.9,
              scaleY: 0.9,
              translateZ: 0
            }, 0.20
          ], [
            {
              scaleX: 1,
              scaleY: 1
            }, 0.50
          ]
        ]
      },
      'bounceOut': {
        defaultDuration: 800,
        calls: [
          [
            {
              scaleX: 0.95,
              scaleY: 0.95
            }, 0.35
          ], [
            {
              scaleX: 1.1,
              scaleY: 1.1,
              translateZ: 0
            }, 0.35
          ], [
            {
              opacity: [0, 1],
              scaleX: 0.3,
              scaleY: 0.3
            }, 0.30
          ]
        ],
        reset: {
          scaleX: 1,
          scaleY: 1
        }
      },
      'bounceUpIn': {
        defaultDuration: 800,
        calls: [
          [
            {
              opacity: [1, 0],
              translateY: [-30, 1000]
            }, 0.60, {
              easing: 'easeOutCirc'
            }
          ], [
            {
              translateY: 10
            }, 0.20
          ], [
            {
              translateY: 0
            }, 0.20
          ]
        ]
      },
      'bounceUpOut': {
        defaultDuration: 1000,
        calls: [
          [
            {
              translateY: 20
            }, 0.20
          ], [
            {
              opacity: [0, 'easeInCirc', 1],
              translateY: -1000
            }, 0.80
          ]
        ],
        reset: {
          translateY: 0
        }
      },
      'bounceDownIn': {
        defaultDuration: 800,
        calls: [
          [
            {
              opacity: [1, 0],
              translateY: [30, -1000]
            }, 0.60, {
              easing: 'easeOutCirc'
            }
          ], [
            {
              translateY: -10
            }, 0.20
          ], [
            {
              translateY: 0
            }, 0.20
          ]
        ]
      },
      'bounceDownOut': {
        defaultDuration: 1000,
        calls: [
          [
            {
              translateY: -20
            }, 0.20
          ], [
            {
              opacity: [0, 'easeInCirc', 1],
              translateY: 1000
            }, 0.80
          ]
        ],
        reset: {
          translateY: 0
        }
      },
      'bounceLeftIn': {
        defaultDuration: 750,
        calls: [
          [
            {
              opacity: [1, 0],
              translateX: [30, -1250]
            }, 0.60, {
              easing: 'easeOutCirc'
            }
          ], [
            {
              translateX: -10
            }, 0.20
          ], [
            {
              translateX: 0
            }, 0.20
          ]
        ]
      },
      'bounceLeftOut': {
        defaultDuration: 750,
        calls: [
          [
            {
              translateX: 30
            }, 0.20
          ], [
            {
              opacity: [0, 'easeInCirc', 1],
              translateX: -1250
            }, 0.80
          ]
        ],
        reset: {
          translateX: 0
        }
      },
      'bounceRightIn': {
        defaultDuration: 750,
        calls: [
          [
            {
              opacity: [1, 0],
              translateX: [-30, 1250]
            }, 0.60, {
              easing: 'easeOutCirc'
            }
          ], [
            {
              translateX: 10
            }, 0.20
          ], [
            {
              translateX: 0
            }, 0.20
          ]
        ]
      },
      'bounceRightOut': {
        defaultDuration: 750,
        calls: [
          [
            {
              translateX: -30
            }, 0.20
          ], [
            {
              opacity: [0, 'easeInCirc', 1],
              translateX: 1250
            }, 0.80
          ]
        ],
        reset: {
          translateX: 0
        }
      },
      'slideUpIn': {
        defaultDuration: 900,
        calls: [
          [
            {
              opacity: [1, 0],
              translateY: [0, 20],
              translateZ: 0
            }
          ]
        ]
      },
      'slideUpOut': {
        defaultDuration: 900,
        calls: [
          [
            {
              opacity: [0, 1],
              translateY: -20,
              translateZ: 0
            }
          ]
        ],
        reset: {
          translateY: 0
        }
      },
      'slideDownIn': {
        defaultDuration: 900,
        calls: [
          [
            {
              opacity: [1, 0],
              translateY: [0, -20],
              translateZ: 0
            }
          ]
        ]
      },
      'slideDownOut': {
        defaultDuration: 900,
        calls: [
          [
            {
              opacity: [0, 1],
              translateY: 20,
              translateZ: 0
            }
          ]
        ],
        reset: {
          translateY: 0
        }
      },
      'slideLeftIn': {
        defaultDuration: 1000,
        calls: [
          [
            {
              opacity: [1, 0],
              translateX: [0, -20],
              translateZ: 0
            }
          ]
        ]
      },
      'slideLeftOut': {
        defaultDuration: 1050,
        calls: [
          [
            {
              opacity: [0, 1],
              translateX: -20,
              translateZ: 0
            }
          ]
        ],
        reset: {
          translateX: 0
        }
      },
      'slideRightIn': {
        defaultDuration: 1000,
        calls: [
          [
            {
              opacity: [1, 0],
              translateX: [0, 20],
              translateZ: 0
            }
          ]
        ]
      },
      'slideRightOut': {
        defaultDuration: 1050,
        calls: [
          [
            {
              opacity: [0, 1],
              translateX: 20,
              translateZ: 0
            }
          ]
        ],
        reset: {
          translateX: 0
        }
      },
      'slideUpBigIn': {
        defaultDuration: 850,
        calls: [
          [
            {
              opacity: [1, 0],
              translateY: [0, 75],
              translateZ: 0
            }
          ]
        ]
      },
      'slideUpBigOut': {
        defaultDuration: 800,
        calls: [
          [
            {
              opacity: [0, 1],
              translateY: -75,
              translateZ: 0
            }
          ]
        ],
        reset: {
          translateY: 0
        }
      },
      'slideDownBigIn': {
        defaultDuration: 850,
        calls: [
          [
            {
              opacity: [1, 0],
              translateY: [0, -75],
              translateZ: 0
            }
          ]
        ]
      },
      'slideDownBigOut': {
        defaultDuration: 800,
        calls: [
          [
            {
              opacity: [0, 1],
              translateY: 75,
              translateZ: 0
            }
          ]
        ],
        reset: {
          translateY: 0
        }
      },
      'slideLeftBigIn': {
        defaultDuration: 800,
        calls: [
          [
            {
              opacity: [1, 0],
              translateX: [0, -75],
              translateZ: 0
            }
          ]
        ]
      },
      'slideLeftBigOut': {
        defaultDuration: 750,
        calls: [
          [
            {
              opacity: [0, 1],
              translateX: -75,
              translateZ: 0
            }
          ]
        ],
        reset: {
          translateX: 0
        }
      },
      'slideRightBigIn': {
        defaultDuration: 800,
        calls: [
          [
            {
              opacity: [1, 0],
              translateX: [0, 75],
              translateZ: 0
            }
          ]
        ]
      },
      'slideRightBigOut': {
        defaultDuration: 750,
        calls: [
          [
            {
              opacity: [0, 1],
              translateX: 75,
              translateZ: 0
            }
          ]
        ],
        reset: {
          translateX: 0
        }
      },
      'perspectiveUpIn': {
        defaultDuration: 800,
        calls: [
          [
            {
              opacity: [1, 0],
              transformPerspective: [800, 800],
              transformOriginX: [0, 0],
              transformOriginY: ['100%', '100%'],
              rotateX: [0, -180]
            }
          ]
        ]
      },
      'perspectiveUpOut': {
        defaultDuration: 850,
        calls: [
          [
            {
              opacity: [0, 1],
              transformPerspective: [800, 800],
              transformOriginX: [0, 0],
              transformOriginY: ['100%', '100%'],
              rotateX: -180
            }
          ]
        ],
        reset: {
          transformPerspective: 0,
          transformOriginX: '50%',
          transformOriginY: '50%',
          rotateX: 0
        }
      },
      'perspectiveDownIn': {
        defaultDuration: 800,
        calls: [
          [
            {
              opacity: [1, 0],
              transformPerspective: [800, 800],
              transformOriginX: [0, 0],
              transformOriginY: [0, 0],
              rotateX: [0, 180]
            }
          ]
        ],
        reset: {
          transformPerspective: 0,
          transformOriginX: '50%',
          transformOriginY: '50%'
        }
      },
      'perspectiveDownOut': {
        defaultDuration: 850,
        calls: [
          [
            {
              opacity: [0, 1],
              transformPerspective: [800, 800],
              transformOriginX: [0, 0],
              transformOriginY: [0, 0],
              rotateX: 180
            }
          ]
        ],
        reset: {
          transformPerspective: 0,
          transformOriginX: '50%',
          transformOriginY: '50%',
          rotateX: 0
        }
      },
      'perspectiveLeftIn': {
        defaultDuration: 950,
        calls: [
          [
            {
              opacity: [1, 0],
              transformPerspective: [2000, 2000],
              transformOriginX: [0, 0],
              transformOriginY: [0, 0],
              rotateY: [0, -180]
            }
          ]
        ],
        reset: {
          transformPerspective: 0,
          transformOriginX: '50%',
          transformOriginY: '50%'
        }
      },
      'perspectiveLeftOut': {
        defaultDuration: 950,
        calls: [
          [
            {
              opacity: [0, 1],
              transformPerspective: [2000, 2000],
              transformOriginX: [0, 0],
              transformOriginY: [0, 0],
              rotateY: -180
            }
          ]
        ],
        reset: {
          transformPerspective: 0,
          transformOriginX: '50%',
          transformOriginY: '50%',
          rotateY: 0
        }
      },
      'perspectiveRightIn': {
        defaultDuration: 950,
        calls: [
          [
            {
              opacity: [1, 0],
              transformPerspective: [2000, 2000],
              transformOriginX: ['100%', '100%'],
              transformOriginY: [0, 0],
              rotateY: [0, 180]
            }
          ]
        ],
        reset: {
          transformPerspective: 0,
          transformOriginX: '50%',
          transformOriginY: '50%'
        }
      },
      'perspectiveRightOut': {
        defaultDuration: 950,
        calls: [
          [
            {
              opacity: [0, 1],
              transformPerspective: [2000, 2000],
              transformOriginX: ['100%', '100%'],
              transformOriginY: [0, 0],
              rotateY: 180
            }
          ]
        ],
        reset: {
          transformPerspective: 0,
          transformOriginX: '50%',
          transformOriginY: '50%',
          rotateY: 0
        }
      }
    };

    /* Register the packaged velocity effects. */
    for (preset in animus_presets) {
      $.Velocity.RegisterEffect(preset, animus_presets[preset]);
    }
  })(jQuery, window, document);

}).call(this);

//# sourceMappingURL=../../src/maps/animus/presets/default.js.map
