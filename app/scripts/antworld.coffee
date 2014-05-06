clearColor = '#c3ffff'
brownColor = '#aa7941'
stoneColor1 = '#a0a0a0'

class TouchOperationSelector
  constructor: (@game, @antWorld) ->
    tileSelector = game.add.group()
    tileSelectorBackground = game.make.graphics()
    tileSelectorBackground.beginFill(0x000000, 0.7)
    tileSelectorBackground.drawRect(0, 0, 96, 48)
    tileSelectorBackground.endFill()
    tileSelector.add(tileSelectorBackground)
    tileSelector.fixedToCamera = true

    marker = @game.add.graphics()
    marker.lineStyle(4, 0xff0000, 1)
    marker.drawRect(2, 2, 44, 44)
    marker.x = 48

    buttonBrown = tileSelector.create(2, 2, 'button_brown')
    buttonBrown.inputEnabled = true
    buttonBrown.events.onInputDown.add(() =>
      @antWorld.currentColor = brownColor
      marker.x = 0)

    buttonCyan = tileSelector.create(50, 2, 'button_cyan')
    buttonCyan.inputEnabled = true
    buttonCyan.events.onInputDown.add(() =>
      @antWorld.currentColor = clearColor
      marker.x = 48)


class AntWorldCreator
  antPixel = '#000000'
  antReversePixel = '#0000ff'
  applePixel = '#ff0000'
  antQueenPixel = '#ffff00'

  @loadFromImage: (game, imgKey, level) ->
    img = game.cache.getImage(imgKey)
    canvas = document.createElement('canvas')
    canvas.getContext('2d').drawImage(img, 0, 0, img.width, img.height)
    pixelData = canvas.getContext('2d').getImageData(0, 0, img.width, img.height).data

    antWorld = new AntWorld(game, level)

    antGroup = game.add.group()
    appleGroup = game.add.group()

    for y in [0..img.height-1]
      for x in [0..img.width-1]
        red = pixelData[((img.width * y) + x) * 4]
        green = pixelData[((img.width * y) + x) * 4 + 1]
        blue = pixelData[((img.width * y) + x) * 4 + 2]
        alpha = pixelData[((img.width * y) + x) * 4 + 3]
        hex = Helper.rgbToHex(red, green, blue)
        if hex == antPixel
          antGroup.add(new Ant(game, x*4+4, y*4+4))
          hex = clearColor
        else if hex == antReversePixel
          ant = new Ant(game, x*4+4, y*4+4)
          ant.changeDirection()
          antGroup.add(ant)
          hex = clearColor
        else if hex == applePixel
          appleGroup.add(new Apple(game, x*4+4, y*4+4))
          hex = clearColor
        else if hex == antQueenPixel
          antQueen = new AntQueen(game, x*4+4, y*4+4)
          game.add.existing(antQueen)
          hex = clearColor
        antWorld.data[x][y] = antWorld.futureData[x][y] = hex
    antWorld.render(true)

    antWorldPhysics = new AntWorldPhysics(game, antWorld, antGroup, appleGroup, antQueen)
    game.plugins.add(antWorldPhysics)

    unless @antQueen
      console.log('no ant queen error')

    return antWorld


class AntWorld
  data: []
  futureData: []

  levelTexts = {
    1: 'Dig a tunnel! Feed the queen!'
    2: 'Hard, hard stone'
    3: 'Build a bridge'
    4: 'Up and down again'
    5: "It's hard work"
  }

  isWalkable: (hexColor) ->
    hexColor in [clearColor]

  isFixed: (hexColor) ->
    color = Helper.hexToRgb(hexColor)
    return color.r == color.g == color.b

  _initData: () ->
    for x in [0..@width-1]
      @data[x] = []
      for y in [0..@height-1]
        @data[x][y] = clearColor
    @futureData = _.cloneDeep(@data)

  constructor: (@game, @level, @tileSize=4) ->
    @currentColor = clearColor
    @width = 800 / @tileSize
    @height = 600 / @tileSize

    @_initData()

    @bmp = @game.add.bitmapData(800, 600)
    @sprite = @game.add.sprite(0, 0, @bmp)
    @sprite.inputEnabled = true
    @sprite.events.onInputDown.add(() =>
      console.log('sprite input Down'))
    @render(true)

    touchOperationSelector = new TouchOperationSelector(@game, this)

    levelDescriptionText = @game.add.text(100, 5, levelTexts[@level])
    levelDescriptionText.font = 'Thirteen Pixel Fonts Regular'
    levelDescriptionText.fontSize = 24


  update: () ->
    if @sprite.input.pointerDown()
      tileX = @tileForWorld(@sprite.input.pointerX())
      tileY = @tileForWorld(@sprite.input.pointerY())
      @handleClick(@currentColor, tileX, tileY)
    else if @sprite.input.pointerDown(1)
      # needed for touch events
      tileX = @tileForWorld(@sprite.input.pointerX(1))
      tileY = @tileForWorld(@sprite.input.pointerY(1))
      @handleClick(@currentColor, tileX, tileY)

  handleClick: (color, tileX, tileY) ->
    circleRadius = 5
    for x in [-circleRadius..circleRadius]
      for y in [-circleRadius..circleRadius]
        # draw only pixels in circle
        distanceSquared = x*x + y*y
        if distanceSquared < circleRadius*circleRadius
          drawTileX = Phaser.Math.clamp(tileX + x, 0, @width-1)
          drawTileY = Phaser.Math.clamp(tileY + y, 0, @height-4)
          @futureData[drawTileX][drawTileY] = color unless @isFixed(@futureData[drawTileX][drawTileY])
    null

  render: (force=false) ->
    for x in [0..@width-1]
      for y in [0..@height-1]
        if @data[x][y] != @futureData[x][y] || force
          @data[x][y] = @futureData[x][y]
          @_drawTilePixel(@data[x][y], x, y)
          @bmp.dirty = true
    true

  tileForWorld: (world) ->
    Math.floor(world / @tileSize)

  highestNonFreeYTile: (x, y) ->
    currentY = y
    while currentY >= 0
      break if @isWalkable(@data[x][currentY])
      currentY -= 1
    currentY + 1

  _drawTilePixel: (color, x, y) ->
    @bmp.ctx.fillStyle = color
    @bmp.ctx.fillRect(4 * x, 4 * y, 4, 4)
