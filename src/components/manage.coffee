_ = require 'lodash'
React = require 'react'

{DOM} = React

PGPKey = React.createFactory React.createClass
  getInitialState: ->
    showKey: false

  toggleKey: (e) ->
    e.preventDefault()
    @setState
      showKey: !@state.showKey

  render: ->
    DOM.form
      method: 'post'
      action: "/admin/pgp/#{@props.pgpKey._id}/edit"
    ,
      DOM.p null,
        DOM.input
          name: 'name'
          defaultValue: @props.pgpKey.name
      DOM.div null,
        DOM.p null,
          DOM.a
            href: '#'
            onClick: @toggleKey
          ,
            if @state.showKey
              'hide key'
            else
              'show key'
        if @state.showKey
          DOM.pre null, @props.pgpKey.publicKey
        else
          null
      DOM.p null,
        DOM.input
          type: 'submit'
          value: 'save'
        DOM.a
          href: "/admin/pgp/#{@props.pgpKey._id}/remove"
        , 'delete'

module.exports = React.createFactory React.createClass
  render: ->
    DOM.section
      className: 'content'
    ,
      DOM.h3 null, 'PGP Keys'
      _.map @props.pgpKeys, (pgpKey) ->
        PGPKey
          key: "pgp-key-#{pgpKey.name}"
          pgpKey: pgpKey
      DOM.h3 null, 'Generate a new key'
      DOM.form
        method: 'post'
        action: '/admin/pgp/new'
      ,
        DOM.input
          name: 'name'
          placeholder: 'name'
        DOM.input
          type: 'submit'
          value: 'create'
