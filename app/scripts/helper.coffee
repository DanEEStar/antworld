class Helper
  @rgbToHex: (r, g, b) ->
    "#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1)

  @hexToRgb = (hex) ->
    result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex)
    (if result
      r: parseInt(result[1], 16)
      g: parseInt(result[2], 16)
      b: parseInt(result[3], 16)
    else null)
