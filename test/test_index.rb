require_relative 'helper'

class IndexTest < MiniTest::Unit::TestCase


  def test_response
    get '/'
    assert last_response.ok?
  end

  def test_content_rendering
    get '/'
    assert_match %r{<h1>Trolo</h1>}, last_response.body
    assert_match %r{<h2>Fuuuu</h2>}, last_response.body
    assert_match %r{<h1>Fu</h1>}, last_response.body
    assert_match %r{Trolololo lo lo lo}, last_response.body
    assert_match %r{<h1>Hello World</h1>}, last_response.body
    assert_match %r{This is a test}, last_response.body
  end

  def test_template_rendering
    get '/'
    assert_match %r{<h1>3 Episodes</h1>}, last_response.body

    validate_meta_data("/", {
      title: "Derp Herp derp",
      show: "bar",
      show_title: "bar bar",
      id: "s01e01",
      date: "15.3.2012",
      status: "published",
      comments: "8",
    })
  end

end
