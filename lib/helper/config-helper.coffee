fs = require 'fs-plus'
cson = require 'season'
path = require 'path'
_ = require 'lodash'

module.exports = ConfigHelper =
  configFileName: '.sync-config.cson'

  initialise: (f) ->
    config = @getConfigPath f
    if not fs.isFileSync config
      csonSample = cson.stringify @sample
      fs.writeFileSync config, csonSample
    atom.workspace.open config

  load: (f) ->
    config = @getConfigPath f
    return if not config or not fs.isFileSync config
    cson.readFileSync config

  assert: (f) ->
    config = @load f
    if not config then throw new Error "You must create remote config first"
    config

  isExcluded: (str, exclude) ->
    for pattern in exclude
      return true if (str.indexOf pattern) isnt -1
    return false

  getRelativePath: (f) ->
     path.relative (@getRootPath f), f

  getRootPath: (f) ->
    _.find atom.project.getPaths(), (x) -> (f.indexOf x) isnt -1

  getConfigPath: (f) ->
    base = @getRootPath f
    return if not base
    path.join base, @configFileName

  sample:
    remote:
      host: "HOST_NICKNAME"  # The remote host name for rsync
      user: "USER"           # username on the remote host
      path: "TARGET_ROOT"    # path to the folder with which to sync
    behaviour:
      uploadOnSave: true     # Set to upload automatically on save.
      syncDownOnOpen: true   # Set to rsync remote -> local on opening files
      forgetConsole: false   # Set to not use the console.
      autoHideConsole: true  # Set to auto-hide the console
      alwaysSyncAll: false   # Set to always rsync the whole project folder
    option:
      deleteFiles: false     # Set to delete files on "Sync Local->Remote"
      autoHideDelay: 5000    # Parameter (msec) to control console display time
      exclude: [             # Put your files/folders for rsync to ignore here
        '.sync-config.cson'
        '.git'
        'node_modules'
        'tmp'
        'vendor'
      ]
