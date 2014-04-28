class AntWorldPhysics extends Phaser.Plugin
  constructor: (@game, @antWorld, @antGroup, @appleGroup, @antQueen) ->
    @numApplesFeed = 0
    @numApplesNeededToFeed = @appleGroup.length
    @applesToFeedText = @game.add.text(795, 5, "Apples #{@numApplesFeed}/#{@numApplesNeededToFeed}")
    @applesToFeedText.anchor.x = 1
    @applesToFeedText.font = 'Thirteen Pixel Fonts Regular'
    @applesToFeedText.fontSize = 24

  update: () ->
    @checkAntAppleCollisions()
    @checkAntAntQueenCollisions()

  postUpdate: () ->
    @antGroup.forEach(@checkAntWorldCollision)

  checkAntWorldCollision: (ant) =>
    tileX = @antWorld.tileForWorld(ant.body.x + (ant.width/2 * ant.scale.x))
    tileX = Phaser.Math.clamp(tileX, 0, @antWorld.width-1)
    tileY = @antWorld.tileForWorld(ant.body.y + ant.height)
    tileY = Phaser.Math.clamp(tileY, 0, @antWorld.height-1)
    tileHexColor = @antWorld.data[tileX][tileY]

    if @antWorld.isWalkable(tileHexColor)
      ant.body.acceleration.y = 100
      ant.body.velocity.x = 50 * ant.scale.x
    else
      ant.body.acceleration.y = 0
      ant.body.velocity.y = 0
      ant.body.velocity.x = 100 * ant.scale.x
      highestNonFreeTileY = @antWorld.highestNonFreeYTile(tileX, tileY)
      if highestNonFreeTileY > tileY - 3
        ant.body.y = ant.y = highestNonFreeTileY * 4 - ant.height + 1
      else
        ant.body.y = ant.y = tileY * 4 - ant.height + 1
        ant.changeDirection()

  checkAntAppleCollisions: () ->
    for ant in @antGroup.children
      continue if ant.apple
      # iterate backwards over apple list because we remove the apple from the group in a collision
      if @appleGroup.length > 0
        for appleIndex in [@appleGroup.length-1..0]
          apple = @appleGroup.getAt(appleIndex)
          if Phaser.Rectangle.intersects(ant.getBounds(), apple.getBounds())
            @handleAntAppleCollision(ant, apple)
    null

  handleAntAppleCollision: (ant, apple) =>
    console.log('ant apple collision')
    @appleGroup.remove(apple)
    @game.add.existing(apple)
    ant.attachApple(apple)

  checkAntAntQueenCollisions: () ->
    for ant in @antGroup.children
      continue unless ant.apple
      if Phaser.Rectangle.intersects(ant.getBounds(), @antQueen.getBounds())
        @handleAntAntQueenCollision(ant, @antQueen)
    null

  handleAntAntQueenCollision: (ant, antQueen) =>
    ant.apple.destroy()
    ant.apple = null

    @numApplesFeed += 1

    @applesToFeedText.text = "Apples #{@numApplesFeed}/#{@numApplesNeededToFeed}"

    if @numApplesFeed >= @numApplesNeededToFeed
      console.log('you win!!')
      setTimeout(() =>
        if @antWorld.level >= 5
          @game.state.start('WinState')
        else
          @game.state.start('GameState', true, false, @antWorld.level + 1)
      , 2000)
