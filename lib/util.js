(function() {
  module.exports = {
    defaults: function() {
      var _o, i, key, len, o, value;
      o = {};
      for (i = 0, len = arguments.length; i < len; i++) {
        _o = arguments[i];
        for (key in _o) {
          value = _o[key];
          if (o[key] == null) {
            o[key] = value;
          }
        }
      }
      return o;
    },
    rgbToHsl: function(r, g, b) {
      var d, h, l, max, min, s;
      r /= 255;
      g /= 255;
      b /= 255;
      max = Math.max(r, g, b);
      min = Math.min(r, g, b);
      h = void 0;
      s = void 0;
      l = (max + min) / 2;
      if (max === min) {
        h = s = 0;
      } else {
        d = max - min;
        s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
        switch (max) {
          case r:
            h = (g - b) / d + (g < b ? 6 : 0);
            break;
          case g:
            h = (b - r) / d + 2;
            break;
          case b:
            h = (r - g) / d + 4;
        }
        h /= 6;
      }
      return [h, s, l];
    },
    hslToRgb: function(h, s, l) {
      var b, g, hue2rgb, p, q, r;
      r = void 0;
      g = void 0;
      b = void 0;
      hue2rgb = function(p, q, t) {
        if (t < 0) {
          t += 1;
        }
        if (t > 1) {
          t -= 1;
        }
        if (t < 1 / 6) {
          return p + (q - p) * 6 * t;
        }
        if (t < 1 / 2) {
          return q;
        }
        if (t < 2 / 3) {
          return p + (q - p) * (2 / 3 - t) * 6;
        }
        return p;
      };
      if (s === 0) {
        r = g = b = l;
      } else {
        q = l < 0.5 ? l * (1 + s) : l + s - (l * s);
        p = 2 * l - q;
        r = hue2rgb(p, q, h + 1 / 3);
        g = hue2rgb(p, q, h);
        b = hue2rgb(p, q, h - (1 / 3));
      }
      return [r * 255, g * 255, b * 255];
    },
    getColorFamily: function(color_r, color_g, color_b) {
      var base_colors, base_colors_b, base_colors_g, base_colors_r, differenceArray, i, index, len, lowest, name, ref;
      base_colors = [[64, 224, 208, "Turquoise"], [245, 245, 220, "Beige"], [0, 0, 0, "Black"], [0, 0, 255, "Blue"], [150, 75, 0, "Brown"], [144, 0, 32, "Burgandy"], [0, 255, 0, "Green"], [128, 128, 128, "Grey"], [255, 127, 0, "Orange"], [128, 0, 128, "Purple"]];
      differenceArray = [];
      Array.min = function(array) {
        return Math.min.apply(Math, array);
      };
      for (i = 0, len = base_colors.length; i < len; i++) {
        ref = base_colors[i], base_colors_r = ref[0], base_colors_g = ref[1], base_colors_b = ref[2], name = ref[3];
        differenceArray.push(Math.sqrt((color_r - base_colors_r) * (color_r - base_colors_r) + (color_g - base_colors_g) * (color_g - base_colors_g) + (color_b - base_colors_b) * (color_b - base_colors_b)));
      }
      lowest = Array.min(differenceArray);
      index = differenceArray.indexOf(lowest);
      return base_colors[index][3];
    }
  };

}).call(this);
