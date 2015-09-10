_ = require 'lodash'
pgp = require 'openpgp'
Promise = require 'when'

KeySchema = require './models/Key'

module.exports = (System) ->
  mongoose = System.getMongoose 'kerplunk-pgp'
  Key = KeySchema mongoose

  showPublicKey = (req, res, next) ->
    Key
    .where
      name: req.params.name ? 'primary'
    .findOne (err, pgpKey) ->
      return next err if err
      return next() unless pgpKey
      res.send
        publicKey: pgpKey.publicKey

  manage = (req, res, next) ->
    Key
    .find (err, pgpKeys) ->
      return next err if err
      res.render 'manage',
        pgpKeys: _.map pgpKeys, (pgpKey) ->
          _id: pgpKey._id
          name: pgpKey.name
          publicKey: pgpKey.publicKey

  create = (req, res, next) ->
    # return res.redirect '/admin/pgp/manage' unless req.body?.name
    return next new Error 'name required' unless req.body?.name
    pgp.generateKeyPair
      numBits: 2048
      userId: 'TODO: user id'
      passphrase: 'super long and hard to guess secret!'
    .then (keypair) ->
      pgpKey = new Key
        name: req.body.name
        privateKey: keypair.privateKeyArmored
        publicKey: keypair.publicKeyArmored
      pgpKey.save (err) ->
        return next err if err
        res.redirect '/admin/pgp/manage'
    .catch (err) ->
      next err

  edit = (req, res, next) ->
    return res.redirect '/admin/pgp/manage' unless req.body?._id
    Key
    .where
      _id: req.params._id
    .findOne (err, key) ->
      return next() if err or !key
      key.name = req.body.name
      key.save (err) ->
        return next err if err
        res.redirect '/admin/pgp/manage'

  remove = (req, res, next) ->
    Key
    .where
      _id: req.params._id
    .remove (err) ->
      return next err if err
      res.redirect '/admin/pgp/manage'

  routes:
    admin:
      '/admin/pgp/manage': 'manage'
      '/admin/pgp/:id/edit': 'edit'
      '/admin/pgp/:id/remove': 'remove'
      '/admin/pgp/new': 'create'
    public:
      '/pgp': 'showPublicKey'
      '/pgp/:name': 'showPublicKey'

  handlers:
    showPublicKey: showPublicKey
    manage: manage
    create: create
    edit: edit
    remove: remove

  methods:
    myPrivateKey: ->
      mpromise = Key
      .where
        name: 'primary'
      .findOne()
      Promise(mpromise).then (pgpKey) ->
        pgpKey?.privateKey
    myPublicKey: ->
      mpromise = Key
      .where
        name: 'primary'
      .findOne()
      Promise(mpromise).then (pgpKey) ->
        pgpKey?.publicKey

  globals:
    public:
      nav:
        Admin:
          Settings:
            PGP:
              Manage: '/admin/pgp/manage'

  init: (next) ->
    next()
