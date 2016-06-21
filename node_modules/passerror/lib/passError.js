(function (root, factory) {
    if (typeof exports === 'object') {
        module.exports = factory();
    } else if (typeof define === 'function' && define.amd) {
        define(factory);
    } else {
        root.passError = factory();
    }
}(this, function () {
    return function passError(errorCallback, successCallback) {
        return function (err) { // ...
            if (err) {
                errorCallback(err);
            } else if (successCallback) {
                successCallback.apply(this, [].slice.call(arguments, 1));
            }
        };
    };
}));
