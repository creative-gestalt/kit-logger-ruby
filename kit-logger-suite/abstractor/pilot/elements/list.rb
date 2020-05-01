class List < DOMElement
  def initialize(driver_object, identifiers = {})
    super
  end

  def length
    retry_on_stale {
      run_script("
        return _element.options.length;
      ")}
  end

  def deselect_all
    options = list.options
    options.each do |option|
      @webdriver.execute_script("arguments[0].selected = false", option)
    end
  end

  def selected
    # Javascript builds an array of options, sees if their selected, and returns array of their text. Much faster than WD.
    retry_on_stale {
      run_script("
        rc_options = _element.options;
        rc_selected = [];
        for (var i = 0; i < rc_options.length; i++) {
          if(rc_options[i].selected){
            rc_selected.push(rc_options[i].text)
          }
        };
        return rc_selected;
      ")}
  end

  # Returns an array of text values for all items in the list.
  def items
    retry_on_stale {
      run_script("
        rc_options = _element.options;
        rc_text = [];
        for (var i = 0; i < rc_options.length; i++) {
          rc_text.push(rc_options[i].text)
        };
        return rc_text;
      ")}
  end

  # Evaluates whether an item in a list is selected
  def item_selected?(item)
    if item.class.eql? Regexp
      selected.grep(item).count > 0
    else
      selected.include? item
    end
  end

  def deselect_by_text(items)
    item_array = sanitize_items(items)
    item_array.each { |item|
      list.deselect_by :text, item
    }
  end

  # Select an item from a list. Use as select(value, "zp-infocard01")
  def select(item_selector, items)
    check_item_selector(item_selector)
    item_array = sanitize_items(items)

    fire_event "focus"

    case item_selector
    when :index
      item_array.each { |item|
        retry_on_stale {
          option = run_script("
            var index = #{item.to_i};
            return _element.options[index]
          ")
          option.click
        }
      }
    when :value
      item_array.each { |item|
        list.select_by item_selector, item
      }
    when :text
      item_array.each { |item|
        case item.class.name
        when "Regexp"
          wait_until(45) {
            select_items_by_regex(item)
            redo if selected.grep(item).empty?
            true
          }

        when "String"
          wait_until {
            begin
              list.select_by item_selector, item
            rescue Selenium::WebDriver::Error::NoSuchElementError => e
              retry
            end
            redo unless selected.include? item
            true
          }
        end
      }
    end
  rescue Timeout::Error
    raise ElementNotSelectedError, "Unable to select #{item_selector}: #{items.inspect} from list identified by: #{self.identifiers}"
  end

  def select_all
    element.send_keys [:control, 'a']
  end

  def selected_items_count
    selected = list.selected_options
    selected.count
  end

  def show_items_for_video(seconds_between_item_scroll: 0.1)
    click
    items.count.times do
      sleep seconds_between_item_scroll
      send_keys([:arrow_down])
    end
  end

  def show_available_items_for_video(seconds_between_item_scroll: 0.1)
    click
    select(:index, 0)
    count = 0
    (1..items.count-10).each do
      sleep seconds_between_item_scroll
      send_keys([:arrow_down])
    end
    true
  end

  def display_selected_in_list(target, seconds_between_item_scroll: 0.5)
    target = [target] if !target.respond_to?("each")
    item_count = self.items.length
    item_array = sanitize_items(items)
    items_till_target = 0
    target_index = 0
    item_array.each do |item|
      if item == target[target_index]
        jscript = "var scrollBar = _element,
            lineHeight = scrollBar.scrollHeight/#{item_count};
            scrollBar.scrollTop = lineHeight*#{items_till_target};"
        run_script(jscript)
        target_index += 1
        sleep seconds_between_item_scroll
      else
        items_till_target += 1
      end
    end
  end

  private

  def check_item_selector(item_selector)
    unless VALID_LIST_ITEM_SELECTORS.include? item_selector
      raise "\n\n'#{item_selector}' is not valid selector for list elements. Valid selectors are :#{VALID_LIST_ITEM_SELECTORS.join(", :")}."
    end
  end

  def select_items_by_regex item
    options = list.options
    options.each do |option|
      option_text = option.attribute('text')
      if item.match(option_text)
        list.select_by :text, option_text
        break
      end
    end

  rescue Selenium::WebDriver::Error::StaleElementReferenceError
    # Sometimes a list is still loading, or re-loading after we get it's options.
    # If that happens, the individual option returned (which is not abstracted), might be stale.
    retry
  end

  def sanitize_items(items)
    item_array = []
    # If you're selecting by index and send in an int
    case items.class.to_s
    when "Fixnum"
      item_array << items.to_s
    when "Array"
      item_array = item_array + items
    # when "Regexp"
    #   item_array << items  #TODO:ruby 26 needs to be implement
    else
      item_array << items#.to_s
    end
  end

  def list
    Selenium::WebDriver::Support::Select.new(element)
  end

end
