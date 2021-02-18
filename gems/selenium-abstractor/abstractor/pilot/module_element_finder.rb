require_relative 'constants'

module ElementFinder
  include AdapterConstants

  private

  def element
    ensure_element_available
    send_not_stale_element
  end

  def wd_element
    ensure_element_available
    @elements[@index]
  end

  def find_matching_elements(by, value)
    @elements = @webdriver.find_elements by.to_sym, value
  end

  def prepare_frames(frames)
    @webdriver.switch_to.default_content
    if frames
      wait_until {
        frames.each do |frame|
          begin
            @webdriver.switch_to.frame(frame)
          rescue Selenium::WebDriver::Error::NoSuchFrameError
            retry
          end
        end
      }
    end
  rescue Timeout::Error
    raise MissingFrameError, "Frame route #{frames.inspect} failed for elements identified by: #{@identifiers}"
  end

  def find_elements_after_frame_load
    prepare_frames @frames
    wait_until { @webdriver.execute_script("return document.readyState") == "complete" }
    find_matching_elements @by, @value
  end

  def validate_selectors(identifiers)
    VALID_SELECTORS.each_key do |selector|
      if identifiers.has_key? selector
        @by = selector
        @value = identifiers[selector]
      end
    end
    raise("Invalid selector in:\n#{identifiers.inspect}") unless !@by.nil?
  end

  def ensure_element_available
    #If we didn't find anything, we'll keep looking until we do.
    if @elements.length == 0
      begin
        wait_until {
          prepare_frames @frames
          find_matching_elements @by, @value
          @elements.length > 0
        }
      rescue Timeout::Error
      end
    end
    raise MissingElementError, "Unable to find '#{@by}' matching '#{@value}' in frame:'#{@frames.inspect}'" unless @elements.length > 0
  end

  def send_not_stale_element
    NotStaleElement.new @elements[@index], self
  end

end
#This is not the right way to handle stale elements. especially the instance variable crap.
#But this is the best I can do at this time.
class NotStaleElement
  def initialize wd_element, a_element
    @wd_element = wd_element
    @a_element = a_element
  end

  def method_missing(method_name, *args, &block)
    #Send webdriver whatever command was requested
    @wd_element.send method_name, *args
  rescue Selenium::WebDriver::Error::StaleElementReferenceError
    refind_element
    retry
  rescue Selenium::WebDriver::Error::ElementNotInteractableError
    unless @frame_retry == 3
      @frame_retry = @frame_retry.nil? ? 0 : @frame_retry + 1
      refind_element
      retry
    end
  rescue NoMethodError
    unless @frame_retry == 3
      @frame_retry = @frame_retry.nil? ? 0 : @frame_retry + 1
      refind_element
      retry
    end
    #If we get here, either we called a bad WebDriver method (unlikely in production)
    # or an element was stale, and now is missing. Which is a good thing because it means
    # an element that was stale has left for good.
    raise MissingElementError, "Element Stale - it was there, and now isn't. Unable to find '#{@a_element.by}' matching '#{@a_element.value}' in frame:'#{@a_element.frames.inspect}'"
  end

  private

  def refind_element
    #If the Element was stale , we'll try again.
    @a_element.elements = []
    @a_element.send "find_elements_after_frame_load"
    @wd_element = @a_element.elements[@a_element.index]
  end

end
