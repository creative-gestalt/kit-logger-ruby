require 'selenium-webdriver'
require 'tempfile'
require_relative 'page_name_translator'

Dir["#{File.dirname(__FILE__)}/pilot/**/*.rb"].sort.each do |f|
  require_relative f
end

class Page
  attr_reader :driver

  def initialize abstracted_webdriver
    @driver = abstracted_webdriver
    extension_on_page_load if respond_to? :extension_on_page_load
    _on_page_load if respond_to? :_on_page_load
  end


  def self.loaded?(msg = '')
    page_elements = methods.keep_if do |method|
      method.match(/_element$/) && method != :close_element && method != :please_wait_element
    end

    page_elements.sample(3).each do |item|
      begin
        return true if send(item).exists?
      rescue MissingFrameError
      end
    end

    false
  end

  def self.button(name, identifiers, &block)
    add_standard_element_interfaces('button', name, identifiers)
    block ||= -> { @driver.button(identifiers).click }
    attach_method_to_page name:name, code:block
  end

  def self.element(name, identifiers, &block)
    add_standard_element_interfaces('element', name, identifiers)
    block ||= -> { @driver.element(identifiers).click }
    attach_method_to_page name:name, code:block
  end

  def self.link(name, identifiers, &block)
    add_standard_element_interfaces('link', name, identifiers)
    block ||= -> { @driver.link(identifiers).click }
    attach_method_to_page name:name, code:block
  end

  def self.list(name, identifiers, &block)
    name = sanitize(name)
    define_method("#{name}_element") do
      @driver.list(identifiers)
    end

    define_method("#{name}?") do
      @driver.list(identifiers).exists?
    end

    define_method(name) do
      @driver.list(identifiers).selected
    end

    define_method("#{name}_items") do
      @driver.list(identifiers).items
    end
    block ||= ->(value){ @driver.list(identifiers).select :text, value}
    define_method "#{name}=", block
  end

  def self.checkbox(name, on_name = "enable_#{sanitize(name)}", off_name = "disable_#{sanitize(name)}", identifiers, &block)
    name = sanitize(name)
    add_standard_element_interfaces('checkbox', name, identifiers)
    block ||= -> { @driver.checkbox(identifiers).checked? }

    attach_method_to_page name:name, code:block

    define_method(on_name) do
      @driver.checkbox(identifiers).on
    end

    define_method(off_name) do
      @driver.checkbox(identifiers).off
    end

    define_method("toggle_#{name}") do
      @driver.checkbox(identifiers).click
    end
  end

  def self.file(name, identifiers, &block)
    name = sanitize(name)
    add_standard_element_interfaces('file', name, identifiers)

    define_method(name) do
      @driver.file(identifiers).attribute('value')
    end

    block ||= ->(value) { @driver.file(identifiers).upload value}
    attach_method_to_page name: "#{name}=", code: block
  end

  def self.radio(name, identifiers, &block)
    add_standard_element_interfaces('radio', name, identifiers)

    block ||= -> { @driver.radio(identifiers).click }
    attach_method_to_page name:name, code:block
  end

  def self.text(name, identifiers, &block)
    name = sanitize(name)
    add_standard_element_interfaces('text', name, identifiers)

    define_method(name) do
      @driver.text(identifiers).attribute('value')
    end

    block ||= ->(value) { @driver.text(identifiers).set value }
    attach_method_to_page name: "#{name}=", code: block
  end

  def self.in_frame(identifier, frame = [], &block)
    frame = frame.dup << identifier
    block.call(frame)
  end

  # Selectors

  def self.id(value, frame = nil, index = 0)
    if value[/\s/]
      value = "[id='#{value}']"
      return css value, frame, index
    end
    create_selector_hash :id, value, frame, index
  end

  def self.xpath(value, frame = nil, index = 0)
    create_selector_hash :xpath, value, frame, index
  end

  def self.element_name(value, frame = nil, index = 0)
    create_selector_hash :name, value, frame, index
  end

  def self.element_class(value, frame = nil, index = 0)
    create_selector_hash :class, value, frame, index
  end

  def self.css(value, frame = nil, index = 0)
    create_selector_hash :css, value, frame, index
  end

  private

  def self.attach_method_to_page(name:, code:)
    name = sanitize(name)
    execution_chain = proc { |*value|
      element_name = "#{name.gsub('=', '')}_element"
      instance_exec(send(element_name.to_s), &self.class.pre_event) if self.class.respond_to? :pre_event
      default_block_value = instance_exec(*value, &code)
      instance_exec(send(element_name.to_s), &self.class.post_event) if self.class.respond_to? :post_event
      default_block_value
    }
    define_method name, execution_chain
  end

  def self.create_selector_hash(selector, value, frame, index, *args)
    {selector.to_sym => value, :frame => frame, :index => index}
  end

  def self.add_standard_element_interfaces(class_name, name, identifiers)
    name = sanitize(name)
    define_method "#{name}_element" do
      @driver.send(class_name.to_s, identifiers)
    end

    define_method "#{name}_elements" do
      @driver.send(class_name.to_s, identifiers).all
    end

    define_method "#{name}?" do
      @driver.send(class_name.to_s, identifiers).exists?
    end
  end

  # everything but dashes, underscores, numbers, and letters.
  # spaces are replaced with underscores.
  def self.sanitize(string)
    string = string.gsub(/[^0-9a-z\-_\s=]/i, '')
    string = string.gsub(/ /i, '_')
    string = string.downcase
  end

  # This creates proxy methods for instance to pass through to class.
  def self.create_proxy_instance_methods
    methods(false).each do |name|
      define_method(name) do |*arguments, &block|
        self.class.send(name, *arguments, &block)
      end
    end
  end
  create_proxy_instance_methods

end
include PageNameTranslator
