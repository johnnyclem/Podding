# encoding: utf-8

require_relative '../helper'

describe Model do

  it "can't be created without content" do
    lambda { Model.new({ }) }.must_raise(ArgumentError)
  end

  it 'can be created with specific content' do
    model = Model.new(raw_content: '')
    model.must_be_instance_of Model
    model.content.must_equal ''
    model.data.must_equal({ })
  end

  it "can't be created with a broken YAML header" do
    content = <<-EOF
---
foo: [
---
    EOF
    lambda { Model.new(raw_content: content) }.must_raise(RuntimeError)
  end

  it 'can be created with a valid YAML header' do
    content = <<-EOF
---
foo: bar
hurr: durr
trolo: lala
---
    EOF

    Model.new(raw_content: content).data.must_equal({ 'foo' => 'bar', 'hurr' => 'durr', 'trolo' => 'lala' })
  end

  it 'can be created with a YAML header and content' do
    content = <<-EOF
---
asdf: hjkl
---
THIS IS SPARTA!
    EOF

    Model.new(raw_content: content).content.must_equal "THIS IS SPARTA!\n"
  end

  it 'can be created without a YAML header and content' do
    content = "CONTENT"
    Model.new(raw_content: content).content.must_equal "CONTENT"
  end

  it 'should be invalid without a name' do
    content = "CONTENT"
    Model.new(raw_content: content).valid?.must_equal false
  end

  it 'should be valid with a name' do
    content = <<-EOF
---
name: dawg
---
Content
    EOF
    Model.new(raw_content: content).valid?.must_equal true
  end

end
