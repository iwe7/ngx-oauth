require 'moon.all'
import merge from require 'ngx-oauth.util'
config = require 'ngx-oauth.config'


describe 'load', ->

  required_vars = {
    client_id: 'abc'
    client_secret: '123'
    authorization_url: 'http://oaas.org/authorize'
    token_url: 'http://oaas.org/token'
    check_token_url: 'http://oaas.org/check_token'
  }

  before_each ->
    _G.ngx = { var: {} }


  context 'when all variables are set', ->
    expected = merge {
      scope: 'read'
      redirect_path: 'http://example.rg'
      server_url: 'not-used'
      success_path: '/app/home'
      cookie_path: '/app'
      max_age: 600
      aes_bits: 128
      debug: true
    }, required_vars

    before_each ->
      for key, val in pairs expected do
        _G.ngx.var['oauth_'..key] = val

    it 'returns settings built from ngx.var.oauth_* variables, and falsy', ->
      actual, errs = config.load()
      assert.same expected, actual
      assert.is_falsy errs


  context 'when only required variables are set', ->
    expected = merge {
      scope: ''
      server_url: ''
      redirect_path: '/_oauth/callback'
      success_path: ''
      cookie_path: '/'
      max_age: 2592000
      aes_bits: 256
      debug: false
    }, required_vars

    before_each ->
      for key, val in pairs expected do
        _G.ngx.var['oauth_'..key] = val

    it 'returns settings built from ngx.var.oauth_* variables and defaults, and falsy', ->
      actual, errs = config.load()
      assert.same expected, actual
      assert.is_falsy errs


  context 'when ngx.var.oauth_server_url is set', ->
    before_each ->
      _G.ngx.var.oauth_server_url = 'http://example.org'

    for key, default_value in pairs {
      token_url: 'token',
      authorization_url: 'authorize',
      check_token_url: 'check_token'
    } do
      context "and ngx.var.#{key} is not set", ->
        it "prefixes default #{key} with server_url", ->
          assert.same "http://example.org/#{default_value}", config.load()[key]


  context 'when ngx.var.oauth_server_url is not set', ->

    for varname in *{'authorization_url', 'token_url', 'check_token_url'} do
      context "and ngx.var.#{varname} is not set", ->
        it 'returns table with error message as 2nd value', ->
          _, errs = config.load()
          assert.is_table errs
          assert.contains "Neither variable $oauth_#{varname} nor $oauth_server_url is set.", errs


  for varname in *{'client_id', 'client_secret'} do
    context "when ngx.var.oauth_#{varname} is not set", ->
      it 'returns table with error message as 2nd value', ->
        _, errs = config.load()
        assert.is_table errs
        assert.contains "Variable $oauth_#{varname} is not set.", errs