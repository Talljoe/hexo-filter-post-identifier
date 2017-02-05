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
      * data: post \Title, moment "2016-01-01"
        expected: \m7e4V3jVR22VTErAAqWhzroE+CI=
      * data: post "A longer title", moment "2016-09-30"
        expected: \U0pWFb9GbYHgKgGvHY5Oz2CsIm8=
      * data: post "Something else", moment "1974-05-12 09:30:00 Z"
        expected: \hvhtOkmOS/rA543jsqej1rjhlBk=
      * data: post \Testing, moment "2017-01-01 00:00:00 Z"
        expected: \KoUckkId0yf24pdfduKkftJlTPo=

    tests.forEach (testCase) ->
      specify testCase.data.title, ->
        runSut testCase.data
        expect(testCase.data.identifier).to.equal testCase.expected

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
