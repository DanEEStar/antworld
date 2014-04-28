class Ant extends Phaser.Sprite
  constructor: (game, x, y) ->
    super(game, x-16, y-16, 'ant')
    @game.physics.enable(this, Phaser.Physics.ARCADE)
    @anchor.x = 0.5
    @anchor.y = 0

    @body.velocity.x = 100
    @body.collideWorldBounds = true
    @apple = null

  update: () ->
    if @body.blocked.right || @body.blocked.left
      @changeDirection()

    if @apple
      @apple.y = this.body.y - 16
      if @scale.x > 0
        @apple.x = this.body.x
      else
        @apple.x = this.body.x + 12

  changeDirection: () ->
    @scale.x = -@scale.x
    @body.velocity.x = 100 * @scale.x

  attachApple: (@apple) ->
