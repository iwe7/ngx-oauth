require 'moon.all'
import Left, Right, either, encase, encase2 from require 'ngx-oauth.either'


describe 'Left', ->
  left = Left(66)

  for func_name in *{'ap', 'map', 'chain'} do
    describe func_name, ->
      it 'returns self', ->
        assert.equal left, left[func_name](Right(42))


describe 'Right', ->
  right = Right(42)

  describe 'ap', ->
    fright = Right((x) -> x * 2)

    context 'given Right', ->
      it "returns Right which value is result of applying this Right's value to given Right's value", ->
        given = Right(42)
        result = fright.ap(given)
        assert.same Right, result._type
        assert.same 84, result.value

    context 'given Left', ->
      it 'returns given Left', ->
        given = Left(66)
        assert.equal given, fright.ap(given)

    context 'neither Left, nor Right', ->
      it 'throws error', ->
        assert.has_error -> fright.ap(66)

    context 'when this value is not a function', ->
      it 'throws error', ->
        assert.has_error -> right.ap(Left(66))

  describe 'map', ->
    it "returns Right which value is result of applying given function to this Right's value", ->
      result = right.map((x) -> x * 2)
      assert.same Right, result._type
      assert.same 84, result.value

  describe 'chain', ->
    it "returns result of applying given function to this Right's value", ->
      assert.same 84, right.chain((x) -> x * 2)


describe 'either', ->

  before_each ->
    export onleft = mock(->)
    export onright = mock(->)

  context 'given Left', ->
    it "calls onleft handler with Left's value", ->
      either(onleft, onright, Left(66))
      assert.stub(onleft).called_with(66)
      assert.stub(onright).not_called()

  context 'given Right', ->
    it "calls onright handler with Right's value", ->
      either(onleft, onright, Right(42))
      assert.stub(onleft).not_called()
      assert.stub(onright).called_with(42)

  context 'given neither Left, nor Right', ->
    it 'throws error and does not call any handler', ->
      assert.has_error -> either(->, ->, {})
      assert.stub(onleft).not_called()
      assert.stub(onright).not_called()


shared_encase = (encase_func) ->
  it 'returns a function that wraps the given func and passes its arguments to it', ->
    func = mock(->)
    func2 = encase_func(func)
    assert.is_function func2
    func2(1, 2, 3)
    assert.stub(func).called_with(1, 2, 3)


describe 'encase', ->

  shared_encase encase

  context 'when given func has not raised error', ->
    it "nested function returns Right with the func's return value", ->
      result = encase(-> 'hai!')()
      assert.same Right, result._type
      assert.same 'hai!', result.value

  context 'when given func has raised error', ->
    it 'nested function returns Left with an error message', ->
      result = encase(table.insert)()
      assert.same Left, result._type
      assert.match 'bad argument.*', result.value


describe 'encase2', ->

  shared_encase encase2

  context 'when given func returned non-nil value', ->
    func = -> 'OK!', nil

    it "nested function returns Right with the func's 1st result value", ->
      result = encase2(func)()
      assert.same Right, result._type
      assert.same 'OK!', result.value

  context 'when func returns nil and a value', ->
    func = -> nil, 'FAIL!'

    it "nested function returns Left with the func's 2nd result value", ->
      result = encase2(func)()
      assert.same Left, result._type
      assert.same 'FAIL!', result.value