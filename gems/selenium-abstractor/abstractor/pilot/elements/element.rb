require 'selenium-webdriver'
require_relative '../constants'
require_relative '../module_element_finder'

class DOMElement
  include ElementFinder
  attr_accessor :identifiers, :elements, :by, :value, :index, :frames

  def initialize(driver, identifiers)
    @webdriver = driver
    @identifiers = identifiers
    @frames = identifiers[:frame]
    @index = identifiers[:index] || 0

    validate_selectors(identifiers)

    prepare_frames(@frames)

    find_matching_elements(@by, @value)
  end


  # Performs a Blur() on an object, making it lose focus

  def fire_event(event)
    unless VALID_EVENTS.include? event
      raise "unsupported event. Supported events are \n #{VALID_EVENTS.inspect}"
    end

    # @webdriver.execute_script("arguments[0].#{event}()", element)
    retry_on_stale{
      @webdriver.execute_script("
      _element = arguments[0]
      if ((_element.#{event} || false) && typeof _element.#{event} == 'function')
      {
          // We have a valid onchange listener declared
          _element.#{event}({target : _element});
      } else {
          _element.#{event}();
      }
    ", wd_element)
    }
  end

  def drag_and_drop_on(other, move_up_or_down)
    mouse_to
    @webdriver.action.drag_and_drop(get_wd_element,other.get_wd_element).perform
    if move_up_or_down
      other_height = move_up_or_down<0 ? -1*other.height.to_i : other.height.to_i
      @webdriver.action.drag_and_drop_by(get_wd_element, 0, other_height).perform
    end
  end

  def get_wd_element
    wd_element
  end

  def all
    all_matching_elements = []
    @elements.each_index do |index|
      identifiers = @identifiers.dup
      identifiers[:index] = index
      all_matching_elements << self.class.new(@webdriver, identifiers)
    end

    all_matching_elements
  end

  def click
    element.click
  rescue Selenium::WebDriver::Error::UnknownError => e
    raise e unless e.message[/Other element would receive the click/]

    sleep 0.5
    scroll_into_view
    element.click
  end

  def enabled?
    element.enabled?
  end

  def exists?
    find_elements_after_frame_load
    @elements.length > 0 ? true : false
  end

  def attribute(attribute)
    element.attribute(attribute)
  end

  def height
    height = element.size.height
    # returns fixnum by default. We'd rather use strings.
    height.to_s
  end

  def highlight(time: 0.25, style: 'border: 2px solid yellow; color: yellow;')
    retry_on_stale{
      Highlighter::highlight wd_element, @webdriver, time, style
    }
  end

  def scroll_into_view
    # Bug 57188 - solution complicated.
    run_script "
      var centerY = window.innerHeight / 2;
      var centerX = window.innerWidth / 2;
      var elementPosY = _element.getBoundingClientRect().top + window.scrollY;
      var elementPosX = _element.getBoundingClientRect().left + window.scrollX;
      var scrollPosY = (elementPosY - centerY);
      var scrollPosX = (elementPosX - centerX);
      window.scrollTo(scrollPosX, scrollPosY);
    "
  end

  def scroll_into_view_with_savebar(adjustby = 260)
    run_script "
      var centerY = window.innerHeight / 2;
      var centerX = window.innerWidth / 2;
      var elementPosY = _element.getBoundingClientRect().top + window.scrollY;
      var elementPosX = _element.getBoundingClientRect().left + window.scrollX;
      var scrollPosY = (elementPosY - centerY);
      var scrollPosX = (elementPosX - centerX);
      window.scrollTo(scrollPosX, scrollPosY + #{adjustby});
    "
  end

  def scroll_to_element
    run_script '_element.scrollIntoView();'
  end

  def scroll_window_down(amount)
    # Bug 57188 - solution complicated.
    run_script "
      window.scrollTo(0, #{amount});
    "
  end

  def scroll_element_down(amount)
    run_script "
      _element.scrollTop = #{amount};
    "
  end

  def scroll_iframe_down(amount)
    run_script "
      _element.contentWindow.scrollTo(0, #{amount});
    "
  end

  def mouse_to
    @webdriver.action.move_to(wd_element).perform
  end

  def selected?
    element.selected?
  end

  def send_keys(keys)
    element.send_keys(keys)
  end

  def text
    remove_trailing_tab_for_d_06185 element.text
  end

  def xposition
    x = element.location.x
    x.to_s
  end

  def yposition
    y = element.location.y
    y.to_s
  end

  def visible?
    false
    if exists?
      begin
        element.displayed?
      rescue MissingElementError
        false
      end
    end
  end

  def width
    width = element.size.width
    width.to_s
  end

  # Allows you to run script from the context of the element you're running it on.
  # interact with the element directly in javascript as _element.
  def run_script(script_text)
    retry_on_stale{
      @webdriver.execute_script("_element = arguments[0]; #{script_text}", wd_element)
    }
  end

  def run_async_script(script_text)
    retry_on_stale{
      @webdriver.execute_async_script("_element = arguments[0]; #{script_text}", wd_element)
    }
  end

  def retry_on_stale(&block)
      block.call
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      find_elements_after_frame_load
      retry
  end

  def remove_trailing_tab_for_d_06185(text)
    element.tag_name == 'TD' ? text.strip : text
  end
end
