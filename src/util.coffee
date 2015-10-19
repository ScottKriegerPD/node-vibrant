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
  getSimilarColors = (color_r,color_g,color_b) ->
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
    #Convert to RGB, then R, G, B
    # color_rgb = hex2rgb(color)
    # color_r = color_rgb.split(',')[0]
    # color_g = color_rgb.split(',')[1]
    # color_b = color_rgb.split(',')[2]
    #Create an emtyp array for the difference betwwen the colors
    differenceArray = []
    #Function to find the smallest value in an array
    #Function to convert HEX to RGB

    # hex2rgb = (colour) ->
    #   r = undefined
    #   g = undefined
    #   b = undefined
    #   if colour.charAt(0) == '#'
    #     colour = colour.substr(1)
    #   r = colour.charAt(0) + colour.charAt(1)
    #   g = colour.charAt(2) + colour.charAt(3)
    #   b = colour.charAt(4) + colour.charAt(5)
    #   r = parseInt(r, 16)
    #   g = parseInt(g, 16)
    #   b = parseInt(b, 16)
    #   r + ',' + g + ',' + b

    Array.min = (array) ->
      Math.min.apply Math, array

    #Convert the HEX color in the array to RGB colors, split them up to R-G-B, then find out the difference between the "color" and the colors in the array
    $.each base_colors, (index, value) ->
      base_colors_r = value[0]
      base_colors_g = value[1]
      base_colors_b = value[2]
      #Add the difference to the differenceArray
      differenceArray.push Math.sqrt((color_r - base_colors_r) * (color_r - base_colors_r) + (color_g - base_colors_g) * (color_g - base_colors_g) + (color_b - base_colors_b) * (color_b - base_colors_b))
      return
    #Get the lowest number from the differenceArray
    lowest = Array.min(differenceArray)
    #Get the index for that lowest number
    index = differenceArray.indexOf(lowest)
    #Return the RGB name code
    base_colors[index]
