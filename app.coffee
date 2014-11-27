#!/usr/bin/env coffee

global.app = exports

app.libs =
  _: require 'underscore'
  async: require 'async'
  bunyan: require 'bunyan'
  bodyParser: require 'body-parser'
  child_process: require 'child_process'
  cookieParser: require 'cookie-parser'
  expressBunyanLogger: require 'express-bunyan-logger'
  csrf: require 'csrf'
  crypto: require 'crypto'
  express: require 'express'
  fs: require 'fs'
  tmp: require 'tmp'
  harp: require 'harp'
  jade: require 'jade'
  markdown: require('markdown').markdown
  moment: require 'moment-timezone'
  mongoose: require 'mongoose'
  morgan: require 'morgan'
  nodemailer: require 'nodemailer'
  os: require 'os'
  path: require 'path'
  redis: require 'redis'
  redisStore: require 'connect-redis'
  request: require 'request'
  expressSession: require 'express-session'
  mongooseUniqueValidator: require 'mongoose-unique-validator'

  ObjectID: (require 'mongoose').Types.ObjectId

  ObjectId: (require 'mongoose').Schema.Types.ObjectId
  Mixed: (require 'mongoose').Schema.Types.Mixed

{bunyan, cookieParser, crypto, bodyParser, depd, express, fs, harp, mongoose} = exports.libs
{morgan, nodemailer, path, redis, _} = exports.libs

app.package = require './package'
app.utils = require './core/utils'

app.bunyanMongo = new app.utils.bunyanMongo()

app.logger = bunyan.createLogger
  name: app.package.name
  streams: [
    type: 'raw'
    level: 'info'
    stream: app.bunyanMongo
  ,
    level: process.env.LOG_LEVEL ? 'debug'
    stream: process.stdout
  ]

do ->
  config_path = path.join __dirname, 'config.coffee'

  unless fs.existsSync config_path
    fs.writeFileSync config_path, fs.readFileSync path.join __dirname, "./sample/core.config.coffee"

  fs.chmodSync config_path, 0o750

config = require './config'

do  ->
  if fs.existsSync config.web.listen
    fs.unlinkSync config.web.listen

  session_key_path = path.join __dirname, 'session.key'

  unless fs.existsSync session_key_path
    fs.writeFileSync session_key_path, crypto.randomBytes(48).toString('hex')
    fs.chmodSync session_key_path, 0o750

app.redis = redis.createClient 6379, '127.0.0.1',
  auth_pass: config.redis.password

app.mailer = nodemailer.createTransport config.email.account
app.express = express()

app.config = config
app.db = require './core/db'
app.cache = require './core/cache'
app.i18n = require './core/i18n'
app.pluggable = require './core/pluggable'

app.models = {}

require './core/model/Account'
require './core/model/Financials'
require './core/model/CouponCode'
require './core/model/Notification'
require './core/model/SecurityLog'
require './core/model/Ticket'
require './core/model/Component'

app.templates = require './core/templates'
app.billing = require './core/billing'
app.clusters = require './core/clusters'
app.middleware = require './core/middleware'
app.notification = require './core/notification'

app.express.use bodyParser.json()
app.express.use cookieParser()

app.express.use app.middleware.session()
app.express.use app.middleware.logger()
app.express.use app.middleware.errorHandling
app.express.use app.middleware.csrf()
app.express.use app.middleware.authenticate
app.express.use app.middleware.accountHelpers

app.express.set 'views', path.join(__dirname, 'core/view')
app.express.set 'view engine', 'jade'

app.express.get '/locale/:language?', app.i18n.downloadLocales

app.express.use '/account', require './core/router/account'
app.express.use '/billing', require './core/router/billing'
app.express.use '/ticket', require './core/router/ticket'
app.express.use '/coupon', require './core/router/coupon'
app.express.use '/admin', require './core/router/admin'
app.express.use '/panel', require './core/router/panel'

app.billing.initializePlans()
app.clusters.initializeNodes()
app.pluggable.initializePlugins()

app.express.get '/', (req, res) ->
  unless res.headerSent
    res.redirect '/panel/'

app.express.use harp.mount './core/static'

exports.start = _.once ->
  app.express.listen config.web.listen, ->
    app.started = true

    if fs.existsSync config.web.listen
      fs.chmodSync config.web.listen, 0o770

    app.pluggable.selectHook(null, 'app.started').forEach (hook) ->
      hook.action()

    app.logger.info "RootPanel start at #{config.web.listen}"

unless module.parent
  exports.start()
