# Use in node.js or bunddle with browserify
Vibrant = require('../lib')
_ = require('underscore')
aCutAbove = "http://media.interface.com/is/image/InterfaceInc/install_09_5S?$tile=InterfaceInc/7274056788G15S001_a-cut-above_custom-260049-009_m0788&wid=300"
aPeeling = "http://media.interface.com/is/image/InterfaceInc/install_09_5S?$tile=InterfaceInc/7048014999G15S001_a-peeling_custom-249361-085&wid=300"
grayExample = 'http://interfaceinc.scene7.com/is/image/InterfaceInc/install_15_7A?$tile=InterfaceInc/7898008999G17S001_rms508_agave&wid=300'
brownExample = "http://media.interface.com/is/image/InterfaceInc/install_05_5S?$tile=InterfaceInc/1204013999G15S001_flannel_custom-255114-022&wid=300"
redExample = 'http://media.interface.com/is/image/InterfaceInc/install_05_7S?$tile=InterfaceInc/7948001999G17S001_custom_custom-260280-129&wid=300'
opts = 
  quality: 1
v = new Vibrant(brownExample,opts)

toPercent = (num,total)->
  if num?
    (num/total )*100
  else
    0
v.getSwatches (err, swatches) ->

  console.log("errors",err)
  console.log("swatches",swatches)
  populations = _.pluck swatches, "population"
  total = 0
  _.each populations, (population)=>
    total +=population if population?
  # percents = 
  #   "Vibrant": toPercent(swatches.Vibrant.population,total )
  #   "Muted": toPercent(swatches.Muted.population,total )
  #   "DarkVibrant": toPercent(swatches.DarkVibrant.population,total )
  #   "DarkMuted": toPercent(swatches.DarkMuted.population,total )
  
  # console.log "Vibrant population:", percents.Vibrant
  # console.log "Muted population:", percents.Muted
  # console.log "DarkVibrant population:",percents.DarkVibrant
  # console.log "DarkMuted population:",percents.DarkMuted
  # maxColor = _.max swatches, (swatch)->
  #   swatch.population if swatch?
  # console.log "this is image is mostly", maxColor.InterfaceColorFamily[1]

  swatches = _.sortBy swatches, (swatch)->
    -swatch.population if swatch?
  interfaceColorFamilies = []
  googleColorFamilies = []
  hueColorFamilies = []
  _.each swatches, (value,key,list)=>
    if value?
      console.log value
      if interfaceColorFamilies[value.InterfaceColorFamily[1]]?
        interfaceColorFamilies[value.InterfaceColorFamily[1]] += toPercent(value.population,total) 
      else
        interfaceColorFamilies[value.InterfaceColorFamily[1]] = toPercent(value.population,total)
      
      if googleColorFamilies[value.GoogleColorFamily[1]]?
        googleColorFamilies[value.GoogleColorFamily[1]] += toPercent(value.population,total) 
      else
        googleColorFamilies[value.GoogleColorFamily[1]] = toPercent(value.population,total)
      if hueColorFamilies[value.HueColorFamily[1]]?
        hueColorFamilies[value.HueColorFamily[1]] += toPercent(value.population,total) 
      else
        hueColorFamilies[value.HueColorFamily[1]] = toPercent(value.population,total)

  console.log "interfaceColorFamilies",interfaceColorFamilies
  console.log "googleColorFamilies",googleColorFamilies
  console.log "hueColorFamilies",hueColorFamilies
