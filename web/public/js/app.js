/**
 * Parts of this file are modified from "The Closure Library"
 * Copyright 2006 The Closure Library Authors. All Rights Reserved.
 *
 * Parts of this file are modified from https://github.com/thesmart/js-hypercube
 */

/**
 * Setup the Application namespace
 * @type {Object}
 */
var App = window.App = {};

//==============================================================================
// Utility Functions
//==============================================================================

/**
 * Serialize a form into a key-value object
 * @param {string|Element} element		A form element or a selector
 */
App.serializeForm = function(element) {
  var dataKv	= $(element).serializeArray();
  var data	= {};
  $.map(dataKv, function(item, i) {
    if (item.name.match(/.*\[\]$/)) {
      var name = item.name.replace('[]','');
      if (typeof data[name] == 'undefined') {
        data[name] = new Array();
      }
      data[name].push(item.value);
    } else {
      data[item.name]	= item.value;
    }
  });
  return data;
};

/**
 * Have one constructor inherit from another.
 *
 * @param {!Function} childCtor
 * @param {!Function} parentCtor
 */
App.inherits = function(childCtor, parentCtor) {
  /** @constructor */
  function tempCtor() {};
  tempCtor.prototype = parentCtor.prototype;
  childCtor.superClass_ = parentCtor.prototype;
  childCtor.prototype = new tempCtor();
  childCtor.prototype.constructor = childCtor;
};

//==============================================================================
// Language Enhancements
//==============================================================================

/**
 * Returns true if the specified value is not |undefined|.
 * WARNING: Do not use this to test if an object has a property. Use the in
 * operator instead.  Additionally, this function assumes that the global
 * undefined variable has not been redefined.
 * @param {*} val Variable to test.
 * @return {boolean} Whether variable is defined.
 */
App.isDef = function(val) {
  return val !== undefined;
};


/**
 * Returns true if the specified value is |null|
 * @param {*} val Variable to test.
 * @return {boolean} Whether variable is null.
 */
App.isNull = function(val) {
  return val === null;
};

/**
 * Returns true if the specified value is defined and not null
 * @param {*} val Variable to test.
 * @return {boolean} Whether variable is defined and not null.
 */
App.isDefAndNotNull = function(val) {
  // Note that undefined == null.
  return val != null;
};

/**
 * Returns true if the specified value is a string
 * @param {*} val Variable to test.
 * @return {boolean} Whether variable is a string.
 */
App.isString = function(val) {
  return typeof val == 'string';
};


/**
 * Returns true if the specified value is a boolean
 * @param {*} val Variable to test.
 * @return {boolean} Whether variable is boolean.
 */
App.isBoolean = function(val) {
  return typeof val == 'boolean';
};


/**
 * Returns true if the specified value is a number
 * @param {*} val Variable to test.
 * @return {boolean} Whether variable is a number.
 */
App.isNumber = function(val) {
  return (typeof val == 'number') && !isNaN(val) && isFinite(val);
};

/**
 * Returns true if the specified value is a function
 * @param {*} val Variable to test.
 * @return {boolean} Whether variable is a function.
 */
App.isFunction = function(val) {
  return $.isFunction(val);
};

/**
 * Returns true if the specified value is an object of some kind
 * WARNING: if you want be test "IFF val is a plain object", use App.isPlainObject.
 *
 * @param {*} val Variable to test.
 * @return {boolean} Whether variable is a function.
 */
App.isObject = function(val) {
  return typeof val === 'object';
};

/**
 * Returns true if the specified value is an object.  This includes arrays
 * and functions.
 * WARNING: slightly more expensive than App.isObject
 *
 * @param {*} val Variable to test.
 * @return {boolean} Whether variable is an object.
 */
App.isPlainObject = function(val) {
  return $.isPlainObject(val);
};

/**
 * Returns true if the specified value is an array
 * @param {*} val Variable to test.
 * @return {boolean} Whether variable is an array.
 */
App.isArray = function(val) {
  return $.isArray(val);
};

/**
 * Detect if value is an Element
 * @param {*} val Variable to test.
 * @return {boolean}
 */
App.isElement = function(val) {
  return App.isObject(val) && val.nodeType === 1;
};

/**
 * Detect if value is a jQuery element
 * @param {*} val Variable to test.
 * @return {boolean}
 */
App.isJquery = function(val) {
  return jQuery && val instanceof jQuery;
};

//==============================================================================
// Window Enhancements
//==============================================================================

/**
 * Redirect the user without adding to history
 * @param {string=} opt_url		The url to redirect to. If not passed, will refresh current url.
 */
App.redirect = function(opt_url) {
  if (opt_url) {
    window.location.replace(opt_url);
  } else {
    window.location.reload(true);
  }
};

/**
 * Redirect the user with history
 * NOTE: this is useful because Internet Explorer will throw exception if onbeforeunload has fired.
 *
 * @param {!string} url		The url to redirect to.
 */
App.navigateTo = function(url) {
  try {
    window.location.href = url;
  } catch (exception) {
    // do nothing
  }
};

/**
 * Get the element previous to currently executing script tag
 * WARNING: this should only be called from inside <script></script> blocks in the document.
 */
App.scriptPrev = function() {
  var scripts = document.getElementsByTagName("script");
  var current = $(scripts[scripts.length - 1]);
  while (current.prop("tagName") == 'SCRIPT')
    current = current.prev();
  return current;
};

/**
 * Checks if an element is in the document
 * @return {boolean}
 */
App.isInDocument = function(element) {
  element	= $(element);
  if (!element.length) {
    return false;
  }

  var node	= element[0];
  while (node.parentNode) {
    node	= node.parentNode;
  }
  return !!node.body;
};

//==============================================================================
// App API Handling
//==============================================================================

(function($) {
  /**
   * Same interface as jQuery.ajax
   * @param {Object} options
   * @returns {jQuery.jqXHR}
   */
  App.ajax = function(options) {
    if (options.data && options.data.query) {
      options.url += '?' + $.param(options.data.query)
      delete options.data.query;
    }

    var d = new $.Deferred();
    var on_done = function(data) {
      d.resolve(data.meta, data.message);
    };
    var on_fail = function(jqXHR, textStatus, errorThrown) {
      if (jqXHR.responseJSON && jqXHR.responseJSON.status) {
        d.reject(jqXHR.responseJSON.meta, jqXHR.responseJSON.message);
      } else {
        d.reject(null, 'Oops. The server is temporarily unavailable.')
      }
    };

    if (options.lock) {
      options.lock.lock();
      d.always(options.lock.unlockLater);
    }

    var xhr = $.ajax({
      type: options.type || 'GET',
      url: options.url,
      headers: App.ajax.headers,
      data: options.data || {},
      dataType: 'json'
    }).done(on_done).fail(on_fail);
    xhr.done = $.proxy(d.done, d);
    xhr.fail = $.proxy(d.fail, d);
    return xhr;
  };

  /**
   * Headers to send with every App.ajax request
   * @type {Object}
   */
  App.ajax.headers = {
    'X-Csrf-Bypass': 'yes'
  };

  /**
   * GET
   * @param {String} path
   * @param {Object} query
   * @param {App.lock|undefined} opt_lock
   * @returns {jQuery.jqXHR}
   */
  App.get = function(path, query, opt_lock) {
    return App.ajax({
      url: path,
      data: {
        query: query
      },
      lock: opt_lock
    });
  };

  /**
   * POST
   * @param {String} path
   * @param {Object|undefined} data
   * @param {App.lock|undefined} opt_lock
   * @returns {jQuery.jqXHR}
   */
  App.post = function(path, data, opt_lock) {
    if (data && data.lock) {
      opt_lock = data;
      data = undefined;
    }

    return App.ajax({
      type: 'POST',
      url: path,
      data: data,
      lock: opt_lock
    });
  };
})(jQuery);

/**
 * A lock mechanism for functions that wait for callbacks
 * @returns {Object}
 */
App.lock = function() {
  var lock = {};
  lock.lock = function() {
    lock.locked = true;
    lock.unlocked = false;
    return lock;
  };
  lock.unlock = function() {
    lock.locked = false;
    lock.unlocked = true;
    return lock;
  };
  lock.unlockLater = function() {
    window.setTimeout(lock.unlock, 1);
  };
  return lock.unlock();
};
