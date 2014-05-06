Phaser.Tilemap.prototype.initFillLayer = (tileIndex, layer) ->
  layer = this.getLayer(layer);

  for y in [0..this.height]
    this.layers[layer].data[y] = []
    for x in [0..this.width]
      this.layers[layer].data[y][x] = new Phaser.Tile(this.layers[layer], tileIndex, x, y, this.tileWidth, this.tileHeight);
  this.layers[layer].dirty = true;
  this.calculateFaces(layer);


_.repeat = (t, elem) ->
  _.times(t, () -> elem )


class GameState extends Phaser.State
  init: (@level) ->
    @levelText = "level#{@level}"
    console.log('state init with level ' + @level)

  preload: () ->
    @game.load.image(@levelText, "images/#{@levelText}.png")

  create: () ->
    @game.time.advancedTiming = true
    @cursors = @game.input.keyboard.createCursorKeys();
    @antWorld = AntWorldCreator.loadFromImage(@game, @levelText, @level)

  movementKeyPressed: () ->
    return @cursors.up.isDown || @cursors.down.isDown || @cursors.left.isDown || @cursors.right.isDown;

  update: () ->
    @antWorld.update()

  render: () ->
    @antWorld.render()
    @game.debug.text("fps: #{@game.time.fps}", 10, 20);


class TitleState extends Phaser.State
  create: () ->
    @game.add.image(0, 0, 'title')

    style = { font: "75px Thirteen Pixel Fonts Regular", fill: "", align: "center" };
    startText = @game.add.text(400, 280, 'Start', style)
    startText.anchor.x = 0.5
    startText.inputEnabled = true
    startText.events.onInputDown.add(() =>
      @game.state.start('GameState', true, false, 1))

    ###
    helpText = @game.add.text(400, 360, 'Help', style)
    helpText.anchor.x = 0.5
    helpText.inputEnabled = true
    helpText.events.onInputDown.add(() =>
      console.log('help'))
    ###


class PreloaderState extends Phaser.State
  preload: () ->
    @game.load.image('ant', 'images/ant.png')
    @game.load.image('antqueen', 'images/antqueen.png')
    @game.load.image('button_cyan', 'images/button_cyan.png')
    @game.load.image('button_brown', 'images/button_brown.png')
    @game.load.image('apple', 'images/apple.png')
    @game.load.image('title', 'images/title.png')

  create: () ->
    @game.state.start('TitleState')


class WinState extends Phaser.State
  create: () ->
    @game.add.image(0, 0, 'title')

    style = { font: "75px Thirteen Pixel Fonts Regular", fill: "", align: "center" };
    startText = @game.add.text(400, 200, 'You win!!!\nGod save the Queen!', style)
    startText.anchor.x = 0.5
    startText.inputEnabled = true
    startText.events.onInputDown.add(() =>
      @game.state.start('TitleState', true, false, 1))


class Game extends Phaser.Game
  constructor: () ->
    super(800, 600, Phaser.AUTO, 'gameContainer', null);

    @state.add('PreloaderState', PreloaderState, false)
    @state.add('TitleState', TitleState, false)
    @state.add('GameState', GameState, false)
    @state.add('WinState', WinState, false)

    @state.start('PreloaderState')

window.onload = () ->
  game = new Game()



