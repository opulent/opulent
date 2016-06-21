
 /**********************
  Velocity UI Pack
  **********************/

 /* VelocityJS.org UI Pack (5.0.3). (C) 2014 Julian Shapiro. MIT @license: en.wikipedia.org/wiki/MIT_License. Portions copyright Daniel Eden, Christian Pucci. */

 ;(function (factory) {
     /* CommonJS module. */
     if (typeof require === "function" && typeof exports === "object" ) {
         module.exports = factory();
         /* AMD module. */
     } else if (typeof define === "function" && define.amd) {
         define([ "velocity" ], factory);
         /* Browser globals. */
     } else {
         factory();
     }
 }(function() {
     return function (global, window, document, undefined) {

         /*************
          Checks
          *************/

         if (!global.Velocity || !global.Velocity.Utilities) {
             window.console && console.log("Velocity UI Pack: Velocity must be loaded first. Aborting.");
             return;
         } else {
             var Velocity = global.Velocity,
                 $ = Velocity.Utilities;
         }

         var velocityVersion = Velocity.version,
             requiredVersion = { major: 1, minor: 1, patch: 0 };

         function greaterSemver (primary, secondary) {
             var versionInts = [];

             if (!primary || !secondary) { return false; }

             $.each([ primary, secondary ], function(i, versionObject) {
                 var versionIntsComponents = [];

                 $.each(versionObject, function(component, value) {
                     while (value.toString().length < 5) {
                         value = "0" + value;
                     }
                     versionIntsComponents.push(value);
                 });

                 versionInts.push(versionIntsComponents.join(""))
             });

             return (parseFloat(versionInts[0]) > parseFloat(versionInts[1]));
         }

         if (greaterSemver(requiredVersion, velocityVersion)){
             var abortError = "Velocity UI Pack: You need to update Velocity (jquery.velocity.js) to a newer version. Visit http://github.com/julianshapiro/velocity.";
             alert(abortError);
             throw new Error(abortError);
         }

         /************************
          Effect Registration
          ************************/

         /* Note: RegisterUI is a legacy name. */
         Velocity.RegisterEffect = Velocity.RegisterUI = function (effectName, properties) {
             /* Animate the expansion/contraction of the elements' parent's height for In/Out effects. */
             function animateParentHeight (elements, direction, totalDuration, stagger) {
                 var totalHeightDelta = 0,
                     parentNode;

                 /* Sum the total height (including padding and margin) of all targeted elements. */
                 $.each(elements.nodeType ? [ elements ] : elements, function(i, element) {
                     if (stagger) {
                         /* Increase the totalDuration by the successive delay amounts produced by the stagger option. */
                         totalDuration += i * stagger;
                     }

                     parentNode = element.parentNode;

                     $.each([ "height", "paddingTop", "paddingBottom", "marginTop", "marginBottom"], function(i, property) {
                         totalHeightDelta += parseFloat(Velocity.CSS.getPropertyValue(element, property));
                     });
                 });

                 /* Animate the parent element's height adjustment (with a varying duration multiplier for aesthetic benefits). */
                 Velocity.animate(
                     parentNode,
                     { height: (direction === "In" ? "+" : "-") + "=" + totalHeightDelta },
                     { queue: false, easing: "ease-in-out", duration: totalDuration * (direction === "In" ? 0.6 : 1) }
                 );
             }

             /* Register a custom redirect for each effect. */
             Velocity.Redirects[effectName] = function (element, redirectOptions, elementsIndex, elementsSize, elements, promiseData) {
                 var finalElement = (elementsIndex === elementsSize - 1);

                 if (typeof properties.defaultDuration === "function") {
                     properties.defaultDuration = properties.defaultDuration.call(elements, elements);
                 } else {
                     properties.defaultDuration = parseFloat(properties.defaultDuration);
                 }

                 /* Iterate through each effect's call array. */
                 for (var callIndex = 0; callIndex < properties.calls.length; callIndex++) {
                     var call = properties.calls[callIndex],
                         propertyMap = call[0],
                         redirectDuration = (redirectOptions.duration || properties.defaultDuration || 1000),
                         durationPercentage = call[1],
                         callOptions = call[2] || {},
                         opts = {};

                     /* Assign the whitelisted per-call options. */
                     opts.duration = redirectDuration * (durationPercentage || 1);
                     opts.queue = redirectOptions.queue || "";
                     opts.easing = callOptions.easing || "ease";
                     opts.delay = parseFloat(callOptions.delay) || 0;
                     opts._cacheValues = callOptions._cacheValues || true;

                     /* Special processing for the first effect call. */
                     if (callIndex === 0) {
                         /* If a delay was passed into the redirect, combine it with the first call's delay. */
                         opts.delay += (parseFloat(redirectOptions.delay) || 0);

                         if (elementsIndex === 0) {
                             opts.begin = function() {
                                 /* Only trigger a begin callback on the first effect call with the first element in the set. */
                                 redirectOptions.begin && redirectOptions.begin.call(elements, elements);

                                 var direction = effectName.match(/(In|Out)$/);

                                 /* Make "in" transitioning elements invisible immediately so that there's no FOUC between now
                                  and the first RAF tick. */
                                 if ((direction && direction[0] === "In") && propertyMap.opacity !== undefined) {
                                     $.each(elements.nodeType ? [ elements ] : elements, function(i, element) {
                                         Velocity.CSS.setPropertyValue(element, "opacity", 0);
                                     });
                                 }

                                 /* Only trigger animateParentHeight() if we're using an In/Out  */
                                 if (redirectOptions.animateParentHeight && direction) {
                                     animateParentHeight(elements, direction[0], redirectDuration + opts.delay, redirectOptions.stagger);
                                 }
                             }
                         }

                         /* If the user isn't overriding the display option, default to "auto" for "In"-suffixed transitions. */
                         if (redirectOptions.display !== null) {
                             if (redirectOptions.display !== undefined && redirectOptions.display !== "none") {
                                 opts.display = redirectOptions.display;
                             } else if (/In$/.test(effectName)) {
                                 /* Inline elements cannot be subjected to transforms, so we switch them to inline-block. */
                                 var defaultDisplay = Velocity.CSS.Values.getDisplayType(element);
                                 opts.display = (defaultDisplay === "inline") ? "inline-block" : defaultDisplay;
                             }
                         }

                         if (redirectOptions.visibility && redirectOptions.visibility !== "hidden") {
                             opts.visibility = redirectOptions.visibility;
                         }
                     }

                     /* Special processing for the last effect call. */
                     if (callIndex === properties.calls.length - 1) {
                         /* Append promise resolving onto the user's redirect callback. */
                         function injectFinalCallbacks () {
                             if ((redirectOptions.display === undefined || redirectOptions.display === "none") && /Out$/.test(effectName)) {
                                 $.each(elements.nodeType ? [ elements ] : elements, function(i, element) {
                                     Velocity.CSS.setPropertyValue(element, "display", "none");
                                 });
                             }

                             redirectOptions.complete && redirectOptions.complete.call(elements, elements);

                             if (promiseData) {
                                 promiseData.resolver(elements || element);
                             }
                         }

                         opts.complete = function() {
                             if (properties.reset) {
                                 for (var resetProperty in properties.reset) {
                                     var resetValue = properties.reset[resetProperty];

                                     /* Format each non-array value in the reset property map to [ value, value ] so that changes apply
                                      immediately and DOM querying is avoided (via forcefeeding). */
                                     /* Note: Don't forcefeed hooks, otherwise their hook roots will be defaulted to their null values. */
                                     if (Velocity.CSS.Hooks.registered[resetProperty] === undefined && (typeof resetValue === "string" || typeof resetValue === "number")) {
                                         properties.reset[resetProperty] = [ properties.reset[resetProperty], properties.reset[resetProperty] ];
                                     }
                                 }

                                 /* So that the reset values are applied instantly upon the next rAF tick, use a zero duration and parallel queueing. */
                                 var resetOptions = { duration: 0, queue: false };

                                 /* Since the reset option uses up the complete callback, we trigger the user's complete callback at the end of ours. */
                                 if (finalElement) {
                                     resetOptions.complete = injectFinalCallbacks;
                                 }

                                 Velocity.animate(element, properties.reset, resetOptions);
                                 /* Only trigger the user's complete callback on the last effect call with the last element in the set. */
                             } else if (finalElement) {
                                 injectFinalCallbacks();
                             }
                         };

                         if (redirectOptions.visibility === "hidden") {
                             opts.visibility = redirectOptions.visibility;
                         }
                     }

                     Velocity.animate(element, propertyMap, opts);
                 }
             };

             /* Return the Velocity object so that RegisterUI calls can be chained. */
             return Velocity;
         };


         /*********************
          Sequence Running
          **********************/

         /* Note: Sequence calls must use Velocity's single-object arguments syntax. */
         Velocity.RunSequence = function (originalSequence) {
             var sequence = $.extend(true, [], originalSequence);

             if (sequence.length > 1) {
                 $.each(sequence.reverse(), function(i, currentCall) {
                     var nextCall = sequence[i + 1];

                     if (nextCall) {
                         /* Parallel sequence calls (indicated via sequenceQueue:false) are triggered
                          in the previous call's begin callback. Otherwise, chained calls are normally triggered
                          in the previous call's complete callback. */
                         var currentCallOptions = currentCall.options || currentCall.o,
                             nextCallOptions = nextCall.options || nextCall.o;

                         var timing = (currentCallOptions && currentCallOptions.sequenceQueue === false) ? "begin" : "complete",
                             callbackOriginal = nextCallOptions && nextCallOptions[timing],
                             options = {};

                         options[timing] = function() {
                             var nextCallElements = nextCall.elements || nextCall.e;
                             var elements = nextCallElements.nodeType ? [ nextCallElements ] : nextCallElements;

                             callbackOriginal && callbackOriginal.call(elements, elements);
                             Velocity(currentCall);
                         }

                         nextCall.options = $.extend({}, nextCall.options, options);
                     }
                 });

                 sequence.reverse();
             }

             Velocity(sequence[0]);
         };
     }((window.jQuery || window.Zepto || window), window, document);
 }));
