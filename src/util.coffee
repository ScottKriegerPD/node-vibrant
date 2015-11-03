DELTAE94 =
  NA: 0
  PERFECT: 1
  CLOSE: 2
  GOOD: 10
  SIMILAR: 50

SIGBITS = 5
RSHIFT = 8 - SIGBITS



module.exports =
  clone: (o) ->
    if typeof o == 'object'
      if Array.isArray o
        return o.map (v) => this.clone v
      else
        _o = {}
        for key, value of o
          _o[key] = this.clone value
        return _o
    o

  defaults: () ->
    o = {}
    for _o in arguments
      for key, value of _o
        if not o[key]? then o[key] = this.clone value

    o

  hexToRgb: (hex) ->
    m = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex)
    if m?
      return [m[1], m[2], m[3]].map (s) -> parseInt(s, 16)
    return null

  rgbToHex: (r, g, b) ->
    "#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1, 7)

  rgbToHsl: (r, g, b) ->
    r /= 255
    g /= 255
    b /= 255
    max = Math.max(r, g, b)
    min = Math.min(r, g, b)
    h = undefined
    s = undefined
    l = (max + min) / 2
    if max == min
      h = s = 0
      # achromatic
    else
      d = max - min
      s = if l > 0.5 then d / (2 - max - min) else d / (max + min)
      switch max
        when r
          h = (g - b) / d + (if g < b then 6 else 0)
        when g
          h = (b - r) / d + 2
        when b
          h = (r - g) / d + 4
      h /= 6
    [h, s, l]

  hslToRgb: (h, s, l) ->
    r = undefined
    g = undefined
    b = undefined

    hue2rgb = (p, q, t) ->
      if t < 0
        t += 1
      if t > 1
        t -= 1
      if t < 1 / 6
        return p + (q - p) * 6 * t
      if t < 1 / 2
        return q
      if t < 2 / 3
        return p + (q - p) * (2 / 3 - t) * 6
      p

    if s == 0
      r = g = b = l
      # achromatic
    else
      q = if l < 0.5 then l * (1 + s) else l + s - (l * s)
      p = 2 * l - q
      r = hue2rgb(p, q, h + 1 / 3)
      g = hue2rgb(p, q, h)
      b = hue2rgb(p, q, h - (1 / 3))
    [
      r * 255
      g * 255
      b * 255
    ]

  rgbToXyz: (r, g, b) ->
    r /= 255
    g /= 255
    b /= 255
    r = if r > 0.04045 then Math.pow((r + 0.005) / 1.055, 2.4) else r / 12.92
    g = if g > 0.04045 then Math.pow((g + 0.005) / 1.055, 2.4) else g / 12.92
    b = if b > 0.04045 then Math.pow((b + 0.005) / 1.055, 2.4) else b / 12.92

    r *= 100
    g *= 100
    b *= 100

    x = r * 0.4124 + g * 0.3576 + b * 0.1805
    y = r * 0.2126 + g * 0.7152 + b * 0.0722
    z = r * 0.0193 + g * 0.1192 + b * 0.9505

    [x, y, z]

  xyzToCIELab: (x, y, z) ->
    REF_X = 95.047
    REF_Y = 100
    REF_Z = 108.883

    x /= REF_X
    y /= REF_Y
    z /= REF_Z

    x = if x > 0.008856 then Math.pow(x, 1/3) else 7.787 * x + 16 / 116
    y = if y > 0.008856 then Math.pow(y, 1/3) else 7.787 * y + 16 / 116
    z = if z > 0.008856 then Math.pow(z, 1/3) else 7.787 * z + 16 / 116

    L = 116 * y - 16
    a = 500 * (x - y)
    b = 200 * (y - z)

    [L, a, b]

  rgbToCIELab: (r, g, b) ->
    [x, y, z] = this.rgbToXyz r, g, b
    this.xyzToCIELab x, y, z

  deltaE94: (lab1, lab2) ->
    # Weights
    WEIGHT_L = 1
    WEIGHT_C = 1
    WEIGHT_H = 1

    [L1, a1, b1] = lab1
    [L2, a2, b2] = lab2
    dL = L1 - L2
    da = a1 - a2
    db = b1 - b2

    xC1 = Math.sqrt a1 * a1 + b1 * b1
    xC2 = Math.sqrt a2 * a2 + b2 * b2

    xDL = L2 - L1
    xDC = xC2 - xC1
    xDE = Math.sqrt dL * dL + da * da + db * db

    if Math.sqrt(xDE) > Math.sqrt(Math.abs(xDL)) + Math.sqrt(Math.abs(xDC))
      xDH = Math.sqrt xDE * xDE - xDL * xDL - xDC * xDC
    else
      xDH = 0

    xSC = 1 + 0.045 * xC1
    xSH = 1 + 0.015 * xC1

    xDL /= WEIGHT_L
    xDC /= WEIGHT_C * xSC
    xDH /= WEIGHT_H * xSH

    Math.sqrt xDL * xDL + xDC * xDC + xDH * xDH

  rgbDiff: (rgb1, rgb2) ->
    lab1 = @rgbToCIELab.apply @, rgb1
    lab2 = @rgbToCIELab.apply @, rgb2
    @deltaE94 lab1, lab2

  hexDiff: (hex1, hex2) ->
    # console.log "Compare #{hex1} #{hex2}"
    rgb1 = @hexToRgb hex1
    rgb2 = @hexToRgb hex2
    # console.log rgb1
    # console.log rgb2
    @rgbDiff rgb1, rgb2

  DELTAE94_DIFF_STATUS: DELTAE94

  getColorDiffStatus: (d) ->
    if d < DELTAE94.NA
      return "N/A"
    # Not perceptible by human eyes
    if d <= DELTAE94.PERFECT
      return "Perfect"
    # Perceptible through close observation
    if d <= DELTAE94.CLOSE
      return "Close"
    # Perceptible at a glance
    if d <= DELTAE94.GOOD
      return "Good"
    # Colors are more similar than opposite
    if d < DELTAE94.SIMILAR
      return "Similar"
    return "Wrong"

  SIGBITS: SIGBITS
  RSHIFT: RSHIFT
  getColorIndex: (r, g, b) ->
    (r<<(2*SIGBITS)) + (g << SIGBITS) + b
  
  getColorFamilyDeltas: (r,g,b)->
    # console.log "getColorFamilyDeltas for ",r,g,b
    base_hues = [
      ["#F44336","Red"],
      ["#E91E63","Pink"],
      ["#9C27B0","Purple"],
      ["#673AB7","DeepPurple"],
      ["#3F51B5","Indigo"],
      ["#2196F3","Blue"],
      ["#03A9F4","LightBlue"],
      ["#00BCD4","Cyan"],
      ["#009688","Teal"],
      ["#4CAF50","Green"],
      ["#8BC34A","LightGreen"],
      ["#CDDC39","Lime"],
      ["#FFEB3B","Yellow"],
      ["#FFC107","Amber"],
      ["#FF9800","Orange"],
      ["#FF5722","DeepOrange"],
      ["#795548","Brown"],
      ["#9E9E9E","Gray"],
      ["#607D8B","BlueGray"],
      ["#000000","Black"],
      ["#ffffff","White"]
    ]

    # 
    # ["#FF0000","Red",0],
    # ["#FF7F00","RedYellow",30],
    # ["#FFFF00","Yellow",60],
    # ["#7FFF00","Chartreuse",90],
    # ["#00FF00","Lime",120],
    # ["#00FF7F","SpringGreen",150],
    # ["#00FFFF","AquaCyan",180],
    # ["#007FFF","BlueGreen",210],
    # ["#0000FF","Blue",240],
    # ["#7F00FF","BluePurple",270],
    # ["#FF00FF","FuchiaMagenta",300],
    # ["#7F007F","Purple",330]
    # ["#ffffff", "White", ""],
    # ["#7f7f7f", "Gray", ""],
    # ["#000000", "Black", ""],
    # [@rgbToHex(64, 224, 208),"Turquoise"],
    # [@rgbToHex(245, 245, 220),"Beige"],
    # [@rgbToHex(150, 75, 0),"Brown"],
    # [@rgbToHex(144, 0, 32),"Burgandy"],
    # console.log @
    hex = @rgbToHex(r,g,b)
    differenceArray = []

    differenceArray.push [@hexDiff(hex,thisHex),name,@getColorDiffStatus(@hexDiff(hex,thisHex))] for [thisHex,name,base_hue] in base_hues
    # console.log differenceArray

    #Function to find the smallest value in an array
    Array.min = (array) ->
      newArray = []
      newArray.push item[0] for item in array
      minValue = Math.min.apply Math, newArray
      newArray.indexOf(minValue)
    lowest = Array.min(differenceArray)
    # console.log lowest
    #Get the index for that lowest number
    # index = differenceArray.indexOf(lowest)
    # console.log index
    # #Return the RGB name code
    [base_hues[lowest][0],base_hues[lowest][1]]
  
  getColorFamilyHue: (hue)->
    hue = hue * 360
    base_hues = [
      ["#FF0000","Red",0],
      ["#FF7F00","RedYellow",30],
      ["#FFFF00","Yellow",60],
      ["#7FFF00","Chartreuse",90],
      ["#00FF00","Lime",120],
      ["#00FF7F","SpringGreen",150],
      ["#00FFFF","AquaCyan",180],
      ["#007FFF","BlueGreen",210],
      ["#0000FF","Blue",240],
      ["#7F00FF","BluePurple",270],
      ["#FF00FF","FuchiaMagenta",300],
      ["#FF007F","Purple",330]
    ]
    differenceArray = []

    #Function to find the smallest value in an array
    Array.min = (array) ->
      Math.min.apply Math, array

    #Convert the HEX color in the array to RGB colors, split them up to R-G-B, then find out the difference between the "color" and the colors in the array
    differenceArray.push Math.sqrt( (hue - base_hue) * (hue - base_hue) ) for [hex,name,base_hue] in base_hues
    
    #Get the lowest number from the differenceArray
    lowest = Array.min(differenceArray)
    #Get the index for that lowest number
    index = differenceArray.indexOf(lowest)
    #Return the RGB name code
    [base_hues[index][0],base_hues[index][1]]
  
  getColorFamily: (color_r,color_g,color_b) ->
    # console.log color_r,color_g,color_b
    # TODO: consider storing this centrally so is globally modifiable
    base_colors = [
      [0, 0, 0,"Black"],
      [58,  121, 145 ,"Blue"],
      [137, 96,  67  ,"BrownTan"],
      [222, 204, 186  ,"CreamBeige"],
      [93,  130, 84  ,"Green"],
      [177, 173, 163 ,"Grey"],
      [210, 120, 60  ,"OrangeRust"],
      [112, 80,  140 ,"Purple"],
      [188, 45,  90  ,"RedPink"],
      [65,  167, 178 ,"Teal"],
      [244, 216, 50  ,"YellowGold"]
    ]
    
    #Create an empty array for the difference betwwen the colors
    differenceArray = []
    color_r = parseInt(color_r)
    color_g = parseInt(color_g)
    color_b = parseInt(color_b)
    console.log color_r,color_g,color_b
    hex = @rgbToHex(color_r,color_g,color_b)
    #Function to find the smallest value in an array
    Array.min = (array) ->
      Math.min.apply Math, array

    #Convert the HEX color in the array to RGB colors, split them up to R-G-B, then find out the difference between the "color" and the colors in the array
    differenceArray.push [@rgbDiff([color_r,color_g,color_b],[base_colors_r,base_colors_g,base_colors_b]),name] for [base_colors_r,base_colors_g,base_colors_b,name] in base_colors
    
    Array.min = (array) ->
      newArray = []
      newArray.push item[0] for item in array
      minValue = Math.min.apply Math, newArray
      newArray.indexOf(minValue)
    lowest = Array.min(differenceArray)
    # console.log lowest
    #Get the index for that lowest number
    # index = differenceArray.indexOf(lowest)
    # console.log index
    # #Return the RGB name code
    [@rgbToHex(base_colors[lowest][0],base_colors[lowest][1],base_colors[lowest][2]),base_colors[lowest][3]]
