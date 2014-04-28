class ProcessManager
  processList: []

  update: () ->
    _.forEach(@processList, updateProcess)

    deadProcesses = _.filter(@processList, isDead)
    _.forEach(deadProcesses, @handleDead)
    @processList = _.reject(@processList, isDead)

  updateProcess = (process) ->
    unless process.paused || process.dead
      process.update()
      process.onUpdate.dispatch(process)

  isDead = (process) ->
    return process.dead

  handleDead: (process) =>
    process.exit()
    process.onExit.dispatch(process)

  attach: (process) ->
    process.manager = this
    process.enter()
    process.onEnter.dispatch(process)
    @processList.push(process)


class Process
  paused: false
  dead: false

  onEnter: new Phaser.Signal()
  onExit: new Phaser.Signal()
  onUpdate: new Phaser.Signal()

  update: () ->

  enter: () ->

  exit: () ->

  kill: () ->
    @dead = true


class ProcessSequence extends Process
  constructor: (@sequence=[]) ->
    @index = 0

  enter: () ->
    @attachNext()

  attachNext: () =>
    if @index < @sequence.length
      nextProcess = @sequence[@index]
      nextProcess.onExit.add(@attachNext)
      @manager.attach(nextProcess)
      @index += 1
    else
      @dead = true


class ProcessGroup extends Process
  constructor: (@group=[], @dieAfterIndex=@group.length) ->
    @diedNumber = 0

  enter: () ->
    _.forEach(@group, @attach)

  attach: (process) =>
    process.onExit.add(@handleExit)
    @manager.attach(process)

  handleExit: () =>
    @diedNumber += 1
    if @diedNumber >= @dieAfterIndex
      @killAll()
      @dead = true

  killAll: () =>
    _.forEach(@group, (p) -> p.kill())



class WaitProcess extends Process
  constructor: (@timeToLive) ->

  update: () ->
    @timeToLive -= (1000/60)

    if @timeToLive < 0
      @dead = true
