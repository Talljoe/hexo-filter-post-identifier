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
    sut(hexo)

  afterEach -> hexo.extend.filter.register.restore!

  runSut = !-> hexo.extend.filter.execSync \before_post_render, it, { context: hexo }

  specify "should register a function" ->
    expect(hexo.extend.filter.register).to.have.been.called

  context "should return consistent results" ->
    tests =
      * data: post \Title, moment '2000-01-01T00:00:00Z'
        expected: \HitXAYElOEKuvPsnlidQO/c5K1s=
      * data: post "A longer title", moment '2017-02-06T03:17:10Z'
        expected: \oBVTvuxEYwhOZy614BIvIbTP45k=
      * data: post "Something else", moment '1974-05-12T09:30:00Z'
        expected: \hvhtOkmOS/rA543jsqej1rjhlBk=
      * data: post \Testing, moment '2017-01-01T00:00:00Z'
        expected: \KoUckkId0yf24pdfduKkftJlTPo=
      * data: post void, moment '2017-01-01T00:00:00Z'
        expected: \/bQGo79m3q0IOBMB25/pizvx640=
      * data: post "Another Void", void
        expected: \eqetU5Vb/IQRFWBQJkR3oj1bnAg=

    for let { data, expected } in tests
      specify data.title ? \Void, ->
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
