var DELTAE94, RSHIFT, SIGBITS;

DELTAE94 = {
  NA: 0,
  PERFECT: 1,
  CLOSE: 2,
  GOOD: 10,
  SIMILAR: 50
};

SIGBITS = 5;

RSHIFT = 8 - SIGBITS;

module.exports = {
  clone: function(o) {
    var _o, key, value;
    if (typeof o === 'object') {
      if (Array.isArray(o)) {
        return o.map((function(_this) {
          return function(v) {
            return _this.clone(v);
          };
        })(this));
      } else {
        _o = {};
        for (key in o) {
          value = o[key];
          _o[key] = this.clone(value);
        }
        return _o;
      }
    }
    return o;
  },
  defaults: function() {
    var _o, i, key, len, o, value;
    o = {};
    for (i = 0, len = arguments.length; i < len; i++) {
      _o = arguments[i];
      for (key in _o) {
        value = _o[key];
        if (o[key] == null) {
          o[key] = this.clone(value);
        }
      }
    }
    return o;
  },
  hexToRgb: function(hex) {
    var m;
    m = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    if (m != null) {
      return [m[1], m[2], m[3]].map(function(s) {
        return parseInt(s, 16);
      });
    }
    return null;
  },
  rgbToHex: function(r, g, b) {
    return "#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1, 7);
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
  rgbToXyz: function(r, g, b) {
    var x, y, z;
    r /= 255;
    g /= 255;
    b /= 255;
    r = r > 0.04045 ? Math.pow((r + 0.005) / 1.055, 2.4) : r / 12.92;
    g = g > 0.04045 ? Math.pow((g + 0.005) / 1.055, 2.4) : g / 12.92;
    b = b > 0.04045 ? Math.pow((b + 0.005) / 1.055, 2.4) : b / 12.92;
    r *= 100;
    g *= 100;
    b *= 100;
    x = r * 0.4124 + g * 0.3576 + b * 0.1805;
    y = r * 0.2126 + g * 0.7152 + b * 0.0722;
    z = r * 0.0193 + g * 0.1192 + b * 0.9505;
    return [x, y, z];
  },
  xyzToCIELab: function(x, y, z) {
    var L, REF_X, REF_Y, REF_Z, a, b;
    REF_X = 95.047;
    REF_Y = 100;
    REF_Z = 108.883;
    x /= REF_X;
    y /= REF_Y;
    z /= REF_Z;
    x = x > 0.008856 ? Math.pow(x, 1 / 3) : 7.787 * x + 16 / 116;
    y = y > 0.008856 ? Math.pow(y, 1 / 3) : 7.787 * y + 16 / 116;
    z = z > 0.008856 ? Math.pow(z, 1 / 3) : 7.787 * z + 16 / 116;
    L = 116 * y - 16;
    a = 500 * (x - y);
    b = 200 * (y - z);
    return [L, a, b];
  },
  rgbToCIELab: function(r, g, b) {
    var ref, x, y, z;
    ref = this.rgbToXyz(r, g, b), x = ref[0], y = ref[1], z = ref[2];
    return this.xyzToCIELab(x, y, z);
  },
  deltaE94: function(lab1, lab2) {
    var L1, L2, WEIGHT_C, WEIGHT_H, WEIGHT_L, a1, a2, b1, b2, dL, da, db, xC1, xC2, xDC, xDE, xDH, xDL, xSC, xSH;
    WEIGHT_L = 1;
    WEIGHT_C = 1;
    WEIGHT_H = 1;
    L1 = lab1[0], a1 = lab1[1], b1 = lab1[2];
    L2 = lab2[0], a2 = lab2[1], b2 = lab2[2];
    dL = L1 - L2;
    da = a1 - a2;
    db = b1 - b2;
    xC1 = Math.sqrt(a1 * a1 + b1 * b1);
    xC2 = Math.sqrt(a2 * a2 + b2 * b2);
    xDL = L2 - L1;
    xDC = xC2 - xC1;
    xDE = Math.sqrt(dL * dL + da * da + db * db);
    if (Math.sqrt(xDE) > Math.sqrt(Math.abs(xDL)) + Math.sqrt(Math.abs(xDC))) {
      xDH = Math.sqrt(xDE * xDE - xDL * xDL - xDC * xDC);
    } else {
      xDH = 0;
    }
    xSC = 1 + 0.045 * xC1;
    xSH = 1 + 0.015 * xC1;
    xDL /= WEIGHT_L;
    xDC /= WEIGHT_C * xSC;
    xDH /= WEIGHT_H * xSH;
    return Math.sqrt(xDL * xDL + xDC * xDC + xDH * xDH);
  },
  rgbDiff: function(rgb1, rgb2) {
    var lab1, lab2;
    lab1 = this.rgbToCIELab.apply(this, rgb1);
    lab2 = this.rgbToCIELab.apply(this, rgb2);
    return this.deltaE94(lab1, lab2);
  },
  hexDiff: function(hex1, hex2) {
    var rgb1, rgb2;
    rgb1 = this.hexToRgb(hex1);
    rgb2 = this.hexToRgb(hex2);
    return this.rgbDiff(rgb1, rgb2);
  },
  DELTAE94_DIFF_STATUS: DELTAE94,
  getColorDiffStatus: function(d) {
    if (d < DELTAE94.NA) {
      return "N/A";
    }
    if (d <= DELTAE94.PERFECT) {
      return "Perfect";
    }
    if (d <= DELTAE94.CLOSE) {
      return "Close";
    }
    if (d <= DELTAE94.GOOD) {
      return "Good";
    }
    if (d < DELTAE94.SIMILAR) {
      return "Similar";
    }
    return "Wrong";
  },
  SIGBITS: SIGBITS,
  RSHIFT: RSHIFT,
  getColorIndex: function(r, g, b) {
    return (r << (2 * SIGBITS)) + (g << SIGBITS) + b;
  },
  getColorFamilyDeltas: function(r, g, b) {
    var base_hue, base_hues, differenceArray, hex, i, len, lowest, name, ref, thisHex;
    base_hues = [["#F44336", "Red"], ["#E91E63", "Pink"], ["#9C27B0", "Purple"], ["#673AB7", "DeepPurple"], ["#3F51B5", "Indigo"], ["#2196F3", "Blue"], ["#03A9F4", "LightBlue"], ["#00BCD4", "Cyan"], ["#009688", "Teal"], ["#4CAF50", "Green"], ["#8BC34A", "LightGreen"], ["#CDDC39", "Lime"], ["#FFEB3B", "Yellow"], ["#FFC107", "Amber"], ["#FF9800", "Orange"], ["#FF5722", "DeepOrange"], ["#795548", "Brown"], ["#9E9E9E", "Gray"], ["#607D8B", "BlueGray"], ["#000000", "Black"], ["#ffffff", "White"]];
    hex = this.rgbToHex(r, g, b);
    differenceArray = [];
    for (i = 0, len = base_hues.length; i < len; i++) {
      ref = base_hues[i], thisHex = ref[0], name = ref[1], base_hue = ref[2];
      differenceArray.push([this.hexDiff(hex, thisHex), name, this.getColorDiffStatus(this.hexDiff(hex, thisHex))]);
    }
    Array.min = function(array) {
      var item, j, len1, minValue, newArray;
      newArray = [];
      for (j = 0, len1 = array.length; j < len1; j++) {
        item = array[j];
        newArray.push(item[0]);
      }
      minValue = Math.min.apply(Math, newArray);
      return newArray.indexOf(minValue);
    };
    lowest = Array.min(differenceArray);
    return [base_hues[lowest][0], base_hues[lowest][1]];
  },
  getColorFamilyHue: function(hue) {
    var base_hue, base_hues, differenceArray, hex, i, index, len, lowest, name, ref;
    hue = hue * 360;
    base_hues = [["#FF0000", "Red", 0], ["#FF7F00", "RedYellow", 30], ["#FFFF00", "Yellow", 60], ["#7FFF00", "Chartreuse", 90], ["#00FF00", "Lime", 120], ["#00FF7F", "SpringGreen", 150], ["#00FFFF", "AquaCyan", 180], ["#007FFF", "BlueGreen", 210], ["#0000FF", "Blue", 240], ["#7F00FF", "BluePurple", 270], ["#FF00FF", "FuchiaMagenta", 300], ["#FF007F", "Purple", 330]];
    differenceArray = [];
    Array.min = function(array) {
      return Math.min.apply(Math, array);
    };
    for (i = 0, len = base_hues.length; i < len; i++) {
      ref = base_hues[i], hex = ref[0], name = ref[1], base_hue = ref[2];
      differenceArray.push(Math.sqrt((hue - base_hue) * (hue - base_hue)));
    }
    lowest = Array.min(differenceArray);
    index = differenceArray.indexOf(lowest);
    return [base_hues[index][0], base_hues[index][1]];
  },
  getColorFamily: function(color_r, color_g, color_b) {
    var base_colors, base_colors_b, base_colors_g, base_colors_r, differenceArray, hex, i, len, lowest, name, ref;
    base_colors = [[0, 0, 0, "Black"], [58, 121, 145, "Blue"], [137, 96, 67, "BrownTan"], [222, 204, 186, "CreamBeige"], [93, 130, 84, "Green"], [177, 173, 163, "Grey"], [210, 120, 60, "OrangeRust"], [112, 80, 140, "Purple"], [188, 45, 90, "RedPink"], [65, 167, 178, "Teal"], [244, 216, 50, "YellowGold"]];
    differenceArray = [];
    color_r = parseInt(color_r);
    color_g = parseInt(color_g);
    color_b = parseInt(color_b);
    console.log(color_r, color_g, color_b);
    hex = this.rgbToHex(color_r, color_g, color_b);
    Array.min = function(array) {
      return Math.min.apply(Math, array);
    };
    for (i = 0, len = base_colors.length; i < len; i++) {
      ref = base_colors[i], base_colors_r = ref[0], base_colors_g = ref[1], base_colors_b = ref[2], name = ref[3];
      differenceArray.push([this.rgbDiff([color_r, color_g, color_b], [base_colors_r, base_colors_g, base_colors_b]), name]);
    }
    Array.min = function(array) {
      var item, j, len1, minValue, newArray;
      newArray = [];
      for (j = 0, len1 = array.length; j < len1; j++) {
        item = array[j];
        newArray.push(item[0]);
      }
      minValue = Math.min.apply(Math, newArray);
      return newArray.indexOf(minValue);
    };
    lowest = Array.min(differenceArray);
    return [this.rgbToHex(base_colors[lowest][0], base_colors[lowest][1], base_colors[lowest][2]), base_colors[lowest][3]];
  }
};
