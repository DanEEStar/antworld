class AntQueen extends Phaser.Sprite
  constructor: (game, x, y) ->
    super(game, x, y, 'antqueen')
    @anchor.x = 1
    @anchor.y = 1