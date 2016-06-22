###

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
###
(($, window, document) ->
  'use strict'

  ### Externalize the packagedEffects data so that they can optionally be modified and re-registered. ###

  ### Support: <=IE8: Callouts will have no effect, and transitions will simply fade in/out. IE9/Android 2.3: Most effects are fully supported, the rest fade in/out. All other browsers: full support. ###

  animus_presets =
    'bounce': [
        [
          {
            opacity: 1
            y: -60
          }
          0.25
        ]
        [
          { y: 0 }
          0.125
        ]
        [
          { y: -30 }
          0.125
        ]
        [
          { y: 0 }
          0.25
        ]
      ]
    'shake': [
        [
          {
            opacity: 1
            x: -11
          }
          0.125
        ]
        [
          { x: 11 }
          0.125
        ]
        [
          { x: -11 }
          0.125
        ]
        [
          { x: 11 }
          0.125
        ]
        [
          { x: -11 }
          0.125
        ]
        [
          { x: 11 }
          0.125
        ]
        [
          { x: -11 }
          0.125
        ]
        [
          { x: 0 }
          0.125
        ]
      ]
    'flash': [
        [
          {
            opacity: 1
            easing: 'easeInOutQuad'
          }
          0.25
        ]
        [
          {
            opacity: 0
            easing: 'easeInOutQuad'
          }
          0.25
        ]
        [
          {
            opacity: 1
            easing: 'easeInOutQuad'
          }
          0.25
        ]
        [
          {
            opacity: 0
            easing: 'easeInOutQuad'
          }
          0.25
        ]
        [
          {
            opacity: 1
            easing: 'easeInOutQuad'
          }
          0.25
        ]
      ]
    'pulse': [
        [
          {
            opacity: 1
            scaleX: 1.1
            scaleY: 1.1
            easing: 'easeInExpo'
          }
          0.50
        ]
        [
          {
            scaleX: 1
            scaleY: 1
          }
          0.50
        ]
      ]
    'swing': [
        [
          {
            opacity: 1
            rotationZ: 15
          }
          0.20
        ]
        [
          { rotationZ: -10 }
          0.20
        ]
        [
          { rotationZ: 5 }
          0.20
        ]
        [
          { rotationZ: -5 }
          0.20
        ]
        [
          { rotationZ: 0 }
          0.20
        ]
      ]
    'tada': [
        [
          {
            opacity: 1
            scaleX: 0.9
            scaleY: 0.9
            rotationZ: -3
          }
          0.10
        ]
        [
          {
            scaleX: 1.1
            scaleY: 1.1
            rotationZ: 3
          }
          0.10
        ]
        [
          {
            scaleX: 1.1
            scaleY: 1.1
            rotationZ: -3
          }
          0.10
        ]
        [
          {
            scaleX: 1.1
            scaleY: 1.1
            rotationZ: 3
          }
          0.10
        ]
        [
          {
            scaleX: 1.1
            scaleY: 1.1
            rotationZ: -3
          }
          0.10
        ]
        [
          {
            scaleX: 1.1
            scaleY: 1.1
            rotationZ: 3
          }
          0.10
        ]
        [
          {
            scaleX: 1.1
            scaleY: 1.1
            rotationZ: -3
          }
          0.10
        ]
        [
          {
            scaleX: 1
            scaleY: 1
            rotationZ: 0
          }
          0.20
        ]
      ]
    'fadeIn': [
      [
        { opacity: 1 }
        1
      ]
    ]
    'fadeOut':[
      [
        { opacity: 0 }
        1
      ]
    ]
    'flipXIn': [
      [
        {
          opacity: 0
          transformPerspective: 800
          rotationY: -55
        }
        0
      ]
      [
        {
          opacity: 1
          transformPerspective: 800
          rotationY: 0
        }
        1
      ]
    ]
    'flipXOut': [
      [
        {
          transformPerspective: 800
          rotationY: 55
          opacity: 0
        }
        1
      ]
    ]
    'flipYIn': [
      [
        {
          opacity: 0
          transformPerspective: 800
          rotationX: -55
        }
        0
      ]
      [
        {
          opacity: 1
          transformPerspective: 800
          rotationX: 0
        }
        1
      ]
    ]
    'flipYOut': [
      [
        {
          transformPerspective: 800
          rotationX: 55
          opacity: 0
        }
        1
      ]
    ]

    'flipBounceXIn': [
      [
        {
          opacity: 0
          transformPerspective: 400
          rotationY: 90
        }
        0
      ]
      [
        {
          opacity: 0.725
          rotationY: -10
        }
        0.50
      ]
      [
        {
          opacity: 0.80
          rotationY: 10
        }
        0.25
      ]
      [
        {
          opacity: 1
          rotationY: 0
        }
        0.25
      ]
    ]
    'flipBounceXOut': [
      [
        {
          opacity: 1
          transformPerspective: 400
          rotationY: -10
        }
        0.25
      ]
      [
        {
          opacity: 1
          transformPerspective: 400
          rotationY: 10
        }
        0.25
      ]
      [
        {
          opacity: 0.9
          rotationY: -20
        }
        0.50
      ]
      [
        {
          opacity: 0
          rotationY: 90
        }
        0.50
      ]
    ]

    'flipBounceYIn': [
      [
        {
          opacity: 0
          transformPerspective: 400
          rotationX: 90
        }
        0
      ]
      [
        {
          opacity: 0.725
          rotationX: -10
        }
        0.50
      ]
      [
        {
          opacity: 0.80
          rotationX: 10
        }
        0.25
      ]
      [
        {
          opacity: 1
          rotationX: 0
        }
        0.25
      ]
    ]

    'flipBounceYOut': [
      [
        {
          opacity: 1
          transformPerspective: 400
          rotationX: -10
        }
        0.25
      ]
      [
        {
          opacity: 1
          transformPerspective: 400
          rotationX: 10
        }
        0.25
      ]
      [
        {
          opacity: 0.9
          rotationX: -20
        }
        0.50
      ]
      [
        {
          opacity: 0
          rotationX: 90
        }
        0.50
      ]
    ]

    'swoopIn': [
      [
        {
          opacity: 0
          scaleX: 0
          scaleY: 0
          x: -700
          z: 0
          transformOriginX: '50%'
          transformOriginY: '50%'
        }
        0
      ]
      [
        {
          opacity: 1
          scaleX: 1
          scaleY: 1
          x: 0
          z: 0
        }
        1
      ]
    ]

    'swoopOut': [
      [
        {
          opacity: 0
          scaleX: 0
          scaleY: 0
          x: 700
          z: 0
        }
        1
      ]
    ]

    'whirlIn': [
      [
        {
          opacity: 0
          transformOriginX: '50%'
          transformOriginY: '50%'
          scaleX: 0
          scaleY: 0
          rotationY: 169
          easing: 'easeInOutSine'
        }
        0
      ]
      [
        {
          opacity: 1
          scaleX: 1
          scaleY: 1
          rotationY: 0
          easing: 'easeInOutSine'
        }
        1
      ]
    ]

    'whirlOut': [
      [
        {
          opacity: 0
          transformOriginX: '50%'
          transformOriginY: '50%'
          scaleX: 0
          scaleY: 0
          rotationY: 169
          easing: 'easeInOutSine'
        }
        1
      ]
    ]

    'shrinkIn': [
      [
        {
          opacity: 0
          transformOriginX: '50%'
          transformOriginY: '50%'
          scaleX: 1.5
          scaleY: 1.5
          z: 0
        }
        0
      ]
      [
        {
          opacity: 1
          scaleX: 1
          scaleY: 1
          z: 0
        }
        1
      ]
    ]

    'shrinkOut': [
      [
        {
          opacity: 0
          scaleX: 0
          scaleY: 0
          z: 0
        }
        1
      ]
    ]

    'expandIn': [
      [
        {
          opacity: 0
          transformOriginX: '50%'
          transformOriginY: '50%'
          scaleX: 0
          scaleY: 0
          z: 0
        }
        0
      ]
      [
        {
          opacity: 1
          scaleX: 1
          scaleY: 1
          z: 0
        }
        1
      ]
    ]

    'expandOut': [
      [
        {
          opacity: 0
          scaleX: 1.5
          scaleY: 1.5
          z: 0
        }
        1
      ]
    ]

    'bounceIn': [
      [
        {
          opacity: 0
          scaleX: 0.3
          scaleY: 0.3
        }
        0
      ]
      [
        {
          opacity: 1
          scaleX: 1.05
          scaleY: 1.05
        }
        0.25
      ]
      [
        {
          scaleX: 0.9
          scaleY: 0.9
          z: 0
        }
        0.25
      ]
      [
        {
          scaleX: 1
          scaleY: 1
        }
        0.50
      ]
    ]

    'bounceOut': [
      [
        {
          opacity: 1
          scaleX: 0.95
          scaleY: 0.95
        }
        0.35
      ]
      [
        {
          scaleX: 1.1
          scaleY: 1.1
          z: 0
        }
        0.35
      ]
      [
        {
          opacity: 0
          scaleX: 0.3
          scaleY: 0.3
        }
        0.30
      ]
    ]

    'bounceUpIn': [
      [
        {
          opacity: 0
          y: 1000
        }
        0
      ]
      [
        {
          opacity: 1
          easing: 'easeOutCirc'
          y: -30
        }
        0.60
      ]
      [
        { y: 10 }
        0.20
      ]
      [
        { y: 0 }
        0.20
      ]
    ]

    'bounceUpOut': [
        [
          {
            opacity: 1
            y: 20
            easing: 'easeInCirc'
          }
          0.20
        ]
        [
          {
            opacity: 0
            y: -1000
          }
          0.80
        ]
      ]

    'bounceDownIn': [
        [
          {
            opacity: 0
            y: -1000
          }
          0
        ]
        [
          {
            opacity: 1
            y: 30
            easing: 'easeOutCirc'
          }
          0.60
        ]
        [
          { y: -10 }
          0.20
        ]
        [
          { y: 0 }
          0.20
        ]
      ]
    'bounceDownOut': [
        [
          {
            opacity: 1
            y: -20
          }
          0.20
        ]
        [
          {
            easing: 'easeInCirc'
            opacity: 0
            y: 1000
          }
          0.80
        ]
      ]
    'bounceLeftIn': [
        [
          {
            opacity: 0
            x: -1250
          }
          0
        ]
        [
          {
            opacity: 1
            x: 30
            easing: 'easeOutCirc'
          }
          0.60
        ]
        [
          { x: -10 }
          0.20
        ]
        [
          { x: 0 }
          0.20
        ]
      ]

    'bounceLeftOut': [
        [
          {
            opacity: 1
            x: 30
          }
          0.20
        ]
        [
          {
            opacity: 0
            easing: 'easeOutCirc'
            x: -1250
          }
          0.80
        ]
      ]

    'bounceRightIn': [
        [
          {
            opacity: 0
            x: 1250
          }
          0
        ]
        [
          {
            opacity: 1
            x: -30
            easing: 'easeOutCirc'
          }
          0.60
        ]
        [
          { x: 10 }
          0.20
        ]
        [
          { x: 0 }
          0.20
        ]
      ]

    'bounceRightOut': [
        [
          {
            opacity: 1
            x: -30
          }
          0.20
        ]
        [
          {
            opacity: 0
            x: 1250
            easing: 'easeOutCirc'
          }
          0.80
        ]
      ]

    'slideUpIn': [
      [
        {
          opacity: 0
          y: 20
          z: 0
        }
        0
      ]
      [
        {
          opacity: 1
          y: 0
          z: 0
        }
        1
      ]
    ]

    'slideUpOut': [
      [
        {
          opacity: 1
        }
        0.2
      ]
      [
        {
          opacity: 0
          y: -20
          z: 0
        }
        0.8
      ]
    ]

    'slideDownIn': [
      [
        {
          opacity: 0
          y: -20
          z: 0
        }
        0
      ]
      [
        {
          opacity: 1
          y: 0
          z: 0
        }
        1
      ]
    ]

    'slideDownOut': [
      [
        {
          opacity: 1
        }
        0.2
      ]
      [
        {
          opacity: 0
          y: 20
          z: 0
        }
        0.8
      ]
    ]

    'slideLeftIn': [
      [
        {
          opacity: 1
          x: -20
          z: 0
        }
        0
      ]
      [
        {
          opacity: 1
          x: 0
          z: 0
        }
        1
      ]
    ]

    'slideLeftOut': [
      [
        {
          opacity: 1
        }
        0.2
      ]
      [
        {
          opacity: 0
          x: -20
          z: 0
        }
        0.8
      ]
    ]

    'slideRightIn': [
      [
        {
          opacity: 0
          x: 20
          z: 0
        }
        0
      ]
      [
        {
          opacity: 1
          x: 0
          z: 0
        }
        1
      ]
    ]

    'slideRightOut': [
      [
        {
          opacity: 1
        }
        0.2
      ]
      [
        {
          opacity: 0
          x: 20
          z: 0
        }
        0.8
      ]
    ]

    'slideUpBigIn': [
      [
        {
          opacity: 0
          y: 75
          z: 0
        }
        0
      ]
      [
        {
          opacity: 1
          y: 0
          z: 0
        }
        1
      ]
    ]

    'slideUpBigOut': [
      [
        {
          opacity: 1
        }
        0.2
      ]
      [
        {
          opacity: 0
          y: -75
          z: 0
        }
        0.8
      ]
    ]

    'slideDownBigIn': [
      [
        {
          opacity: 0
          y: -75
          z: 0
        }
        0
      ]
      [
        {
          opacity: 1
          y: 0
          z: 0
        }
        1
      ]
    ]

    'slideDownBigOut': [
      [
        {
          opacity: 1
        }
        0.2
      ]
      [
        {
          opacity: 0
          y: 75
          z: 0
        }
        0.8
      ]
    ]

    'slideLeftBigIn': [
      [
        {
          opacity: 0
          x: -75
          z: 0
        }
        0
      ]
      [
        {
          opacity: 1
          x: 0
          z: 0
        }
        1
      ]
    ]

    'slideLeftBigOut': [
      [
        {
          opacity: 1
        }
        0.2
      ]
      [
        {
          opacity: 0
          x: -75
          z: 0
        }
        0.8
      ]
    ]

    'slideRightBigIn': [
      [
        {
          opacity: 0
          x: 75
          z: 0
        }
        0
      ]
      [
        {
          opacity: 1
          x: 0
          z: 0
        }
        1
      ]
    ]

    'slideRightBigOut': [
      [
        {
          opacity: 1
        }
        0.2
      ]
      [
        {
          opacity: 0
          x: 75
          z: 0
        }
        0.8
      ]
    ]

    'perspectiveUpIn': [
      [
        {
          opacity: 0
          transformPerspective: 800
          transformOriginX: '0%'
          transformOriginY: '100%'
          rotationX: -180
        }
        0
      ]
      [
        {
          opacity: 1
          rotationX: 0
        }
        1
      ]
    ]

    'perspectiveUpOut': [
      [
        {
          opacity: 1
          transformPerspective: 800
          transformOriginX: '0%'
          transformOriginY: '100%'
        }
        0.2
      ]
      [
        {
          opacity: 0
          rotationX: -180
        }
        0.8
      ]
    ]

    'perspectiveDownIn': [
      [
        {
          opacity: 0
          transformPerspective: 800
          transformOriginX: 0
          transformOriginY: 0
          rotationX: 180
        }
        0
      ]
      [
        {
          opacity: 1
          rotationX: 0
        }
        1
      ]
    ]

    'perspectiveDownOut': [
      [
        {
          opacity: 1
          transformPerspective: 800
          transformOriginX: 0
          transformOriginY: 0
        }
        0.2
      ]
      [
        {
          opacity: 0
          rotationX: 180
        }
        0.8
      ]
    ]

    'perspectiveLeftIn': [
      [
        {
          opacity: 0
          transformPerspective: 2000
          transformOriginX: 0
          transformOriginY: 0
          rotationY: -180
        }
        0
      ]
      [
        {
          opacity: 1
          rotationY: 0
        }
        1
      ]
    ]

    'perspectiveLeftOut': [
      [
        {
          opacity: 1
          transformPerspective: 2000
          transformOriginX: 0
          transformOriginY: 0
        }
        0.2
      ]
      [
        {

          opacity: 0
          rotationY: -180
        }
        0.8
      ]
    ]

    'perspectiveRightIn': [
      [
        {
          opacity: 0
          transformPerspective: 2000
          transformOriginX: '100%'
          transformOriginY: 0
          rotationY: 180
        }
        0
      ]
      [
        {
          opacity: 1
          rotationY: 0
        }
        1
      ]
    ]

    'perspectiveRightOut': [
      [
        {
          opacity: 1
          transformPerspective: 2000
          transformOriginX: '100%'
          transformOriginY: 0
        }
        0.2
      ]
      [
        {
          opacity: 0
          rotationY: 180
        }
        1
      ]
    ]

  ### Register the packaged velocity effects. ###
  for preset of animus_presets
    $.animus.register_preset preset, animus_presets[preset]

  return
) jQuery, window, document
