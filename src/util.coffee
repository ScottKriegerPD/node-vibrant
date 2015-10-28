module.exports =
  defaults: () ->
    o = {}
    for _o in arguments
      for key, value of _o
        if not o[key]? then o[key] = value

    o

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
  getColorFamilyHue: (hue)->
    base_hues = [
      ["#FF0000",0],
      ["#FF7F00",30],
      ["#FFFF00",60],
      ["#7FFF00",90],
      ["#00FF00",120],
      ["#00FF7F",150],
      ["#00FFFF",180],
      ["#007FFF",210],
      ["#0000FF",240],
      ["#7F00FF",270],
      ["#FF00FF",300],
      ["#FF007F",330]
    ]
    differenceArray = []

    #Function to find the smallest value in an array
    Array.min = (array) ->
      Math.min.apply Math, array

    #Convert the HEX color in the array to RGB colors, split them up to R-G-B, then find out the difference between the "color" and the colors in the array
    differenceArray.push Math.sqrt( (hue - base_hue) * (hue - base_hue) ) for [name,base_hue] in base_hues
      
    #Get the lowest number from the differenceArray
    lowest = Array.min(differenceArray)
    #Get the index for that lowest number
    index = differenceArray.indexOf(lowest)
    #Return the RGB name code
    base_hue[index][0]
  getColorFamily: (color_r,color_g,color_b) ->
    # TODO: consider storing this centrally so is globally modifiable
    base_colors = [
      [64, 224, 208,"Turquoise"],
      [245, 245, 220,"Beige"],
      [0, 0, 0,"Black"],
      [0, 0, 255,"Blue"],
      [150, 75, 0,"Brown"],
      [144, 0, 32,"Burgandy"],
      [0, 255, 0,"Green"],
      [128, 128, 128,"Grey"],
      [255, 127, 0,"Orange"],
      [128, 0, 128,"Purple"]
    ]
    
    #Create an empty array for the difference betwwen the colors
    differenceArray = []

    #Function to find the smallest value in an array
    Array.min = (array) ->
      Math.min.apply Math, array

    #Convert the HEX color in the array to RGB colors, split them up to R-G-B, then find out the difference between the "color" and the colors in the array
    differenceArray.push Math.sqrt((color_r - base_colors_r) * (color_r - base_colors_r) + (color_g - base_colors_g) * (color_g - base_colors_g) + (color_b - base_colors_b) * (color_b - base_colors_b)) for [base_colors_r,base_colors_g,base_colors_b,name] in base_colors
      
    #Get the lowest number from the differenceArray
    lowest = Array.min(differenceArray)
    #Get the index for that lowest number
    index = differenceArray.indexOf(lowest)
    #Return the RGB name code
    base_colors[index][3]
