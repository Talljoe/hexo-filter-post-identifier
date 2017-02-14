require! {
  sinon
  "../src/post-identifier.ls" : sut
  "chai"
  moment
  bluebird: Promise
}

{expect} = chai
chai.use require \chai-sinon

getHexo = -> new (require \hexo) __dirname

post = (title, date, identifier = void) ->
  title: title
  date: date
  identifier: identifier

describe "hexo-filter-post-identifier" ->
  var hexo

  beforeEach ->
    hexo := getHexo!
    hexo.extend.filter.store = {}
    sinon.spy(hexo.extend.filter, \register)

  afterEach -> hexo.extend.filter.register.restore!

  withFields = !->
    hexo.config.post_identifier_fields = it

  runSut = !->
    sut(hexo)
    hexo.extend.filter.execSync \before_post_render, it, { context: hexo }

  specify "should register a function" ->
    sut hexo
    expect(hexo.extend.filter.register).to.have.been.called

  context "should return consistent results" ->
    tests =
      * title: "for both title and date"
        data: post \Title, moment '2000-01-01T00:00:00Z'
        expected: \HitXAYElOEKuvPsnlidQO/c5K1s=
      * title: "for date and empty title"
        data: post '', moment '2010-07-15T12:34:56Z'
        expected: \Yn5Z0JYEDdzPDq9hVcCPjuIOF9Y=
      * title: "for only date"
        data: post void, moment '2017-01-01T00:00:00Z'
        expected: \/bQGo79m3q0IOBMB25/pizvx640=
      * title: "for only title"
        data: post "Another Void", void
        expected: \eqetU5Vb/IQRFWBQJkR3oj1bnAg=
      * title: "for no matching fields"
        data: { alt: "not this" }
        expected: \2jmj7l5rSw0yVb/vlWAYkK/YBwk=
      * title: "for alternate fields"
        data: { foo: \Title, up: moment '2000-01-01T00:00:00Z' }
        fields: <[ foo up ]>
        expected: \HitXAYElOEKuvPsnlidQO/c5K1s=
      * title: "for alternate date field"
        data: { publishedDate: moment '2017-01-01T00:00:00Z' }
        fields: <[ publishedDate ]>
        expected: \/bQGo79m3q0IOBMB25/pizvx640=
      * title: "for object property"
        data: { extra: foo: \bar }
        fields: <[ extra ]>
        expected: \pedE0BZFQNM7HX6mFsKPL6l+dUo=

    for let { title, data, expected, fields } in tests
      specify title, ->
        hexo.config.post_identifier_properties ?= fields
        runSut data
        expect data.identifier .to .equal expected

  specify "should set identifier if missing" ->
    const data = post \Title, moment!
    runSut data
    expect(data.identifier).to.not.be.undefined

  specify "should behave with no title" ->
    const data = post void, moment!
    runSut data
    expect(data.identifier).to.not.be.undefined

  specify "should behave with no date" ->
    const data = post \Title, void
    runSut data
    expect(data.identifier).to.not.be.undefined

  specify "should not overwrite existing identifier" ->
    const data = post \Title, moment!, \1234
    runSut data
    expect(data.identifier).to.equal \1234

  context "different posts" ->
    const now = moment!
    const post1 = post \Title1, now
    const post2 = post \Title2, now.clone!.add 1 \second

    specify "should produce different ids" ->
      runSut post1
      runSut post2
      expect(post1.identifier).to.not.equal post2.identifier

  context "same posts" ->
    const now = moment!
    const post1 = post \Title, now
    const post2 = post \Title, now

    specify "should produce same ids" ->
      runSut post1
      runSut post2
      expect(post1.identifier).to.equal post2.identifier

  context "different content" ->
    const now = moment!
    const post1 = with (post \Title, now)
      ..content = \content1
    const post2 = with (post \Title, now)
      ..content = \content2

    specify "should produce same ids" ->
      runSut post1
      runSut post2
      expect(post1.identifier).to.equal post2.identifier

  context "different titles" ->
    const now = moment!
    const post1 = post \Title1, now
    const post2 = post \Title2, now

    specify "should produce different ids" ->
      runSut post1
      runSut post2
      expect(post1.identifier).to.not.equal post2.identifier

  context "different dates" ->
    const now = moment!
    const post1 = post \Title, now
    const post2 = post \Title, now.clone!.add 1 \second

    specify "should produce different ids" ->
      runSut post1
      runSut post2
      expect(post1.identifier).to.not.equal post2.identifier

  context "different time zones" ->
    const now = moment!
    const post1 = post \Title, now.clone!.utcOffset(120)
    const post2 = post \Title, now.clone!.utcOffset(60)

    specify "should produce same ids" ->
      runSut post1
      runSut post2
      expect(post1.identifier).to.equal post2.identifier

  context "different objects" ->
    const fields = <[ custom ]>
    const post1 = custom: key: \Value1
    const post2 = custom: key: \Value2

    specify "should produce different ids" ->
      hexo.config.post_identifier_properties = fields
      runSut post1
      runSut post2
      expect(post1.identifier).to.not.equal post2.identifier
