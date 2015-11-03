// Generated by CoffeeScript 1.10.0
(function() {
  var Vibrant, _, aCutAbove, aPeeling, grayExample, opts, toPercent, v;

  Vibrant = require('../lib');

  _ = require('underscore');

  aCutAbove = "http://media.interface.com/is/image/InterfaceInc/install_09_5S?$tile=InterfaceInc/7274056788G15S001_a-cut-above_custom-260049-009_m0788&wid=640&hei=640";

  aPeeling = "http://media.interface.com/is/image/InterfaceInc/install_09_5S?$tile=InterfaceInc/7048014999G15S001_a-peeling_custom-249361-085&wid=640&hei=640";

  grayExample = 'http://interfaceinc.scene7.com/is/image/InterfaceInc/install_15_7A?$tile=InterfaceInc/7898008999G17S001_rms508_agave&wid=640&hei=640&align=-1,0&fit=crop';

  opts = {
    quality: 1
  };

  v = new Vibrant(grayExample, opts);

  toPercent = function(num, total) {
    return (num / total) * 100;
  };

  v.getSwatches(function(err, swatches) {
    var googleColorFamilies, hueColorFamilies, interfaceColorFamilies, populations, total;
    console.log("errors", err);
    console.log("swatches", swatches);
    populations = _.pluck(swatches, "population");
    total = 0;
    _.each(populations, (function(_this) {
      return function(population) {
        if (population != null) {
          return total += population;
        }
      };
    })(this));
    swatches = _.sortBy(swatches, function(swatch) {
      if (swatch != null) {
        return -swatch.population;
      }
    });
    interfaceColorFamilies = [];
    googleColorFamilies = [];
    hueColorFamilies = [];
    _.each(swatches, (function(_this) {
      return function(value, key, list) {
        if (value != null) {
          if (interfaceColorFamilies[value.InterfaceColorFamily[1]] != null) {
            interfaceColorFamilies[value.InterfaceColorFamily[1]] += toPercent(value.population, total);
          } else {
            interfaceColorFamilies[value.InterfaceColorFamily[1]] = toPercent(value.population, total);
          }
          if (googleColorFamilies[value.GoogleColorFamily[1]] != null) {
            googleColorFamilies[value.GoogleColorFamily[1]] += toPercent(value.population, total);
          } else {
            googleColorFamilies[value.GoogleColorFamily[1]] = toPercent(value.population, total);
          }
          if (hueColorFamilies[value.HueColorFamily[1]] != null) {
            return hueColorFamilies[value.HueColorFamily[1]] += toPercent(value.population, total);
          } else {
            return hueColorFamilies[value.HueColorFamily[1]] = toPercent(value.population, total);
          }
        }
      };
    })(this));
    console.log("interfaceColorFamilies", interfaceColorFamilies);
    console.log("googleColorFamilies", googleColorFamilies);
    return console.log("hueColorFamilies", hueColorFamilies);
  });

}).call(this);