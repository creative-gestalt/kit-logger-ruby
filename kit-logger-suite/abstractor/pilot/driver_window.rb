require_relative 'module_element_finder'

class Window
  include ElementFinder

  def initialize(driver_object)
		@driver = driver_object
  end

  # Closes the active window.

  def close
    @driver.close
  end

  # Counts how many windows are known to the driver.

  def count
    list_windows().length
  end

  # Gets a unique ID for the current window which can be used to reference the window later.

  def id
    @driver.window_handle
  end

  # Switches to the window of your choice.

  def use_window(window_index)
    sleep 1
    # If the user sent a unique window identifier, use that to switch windows
    if window_index.class.eql? String
      wait_until do
        list_windows.include? window_index
      end

      @driver.switch_to.window(window_index)
    # otherwise, use an index number
    else
      wait_until do
        !list_windows[window_index].nil?
      end

      @driver.switch_to.window(list_windows()[window_index])
    end

    # return the window ID in case the tester wants to reference it directly in the future
    id()
  end

  # Maximizes the window

  def maximize
    @driver.manage.window.maximize
  end

  # Moves the window to the coordinates specified.

  def move_to x, y
    @driver.manage.window.move_to x,y
  end

  # Resizes the window

  def resize(width, height)
    @driver.manage.window.resize_to(width, height)
  end

  def ready?
    state = @driver.execute_script("return document.readyState")
    state == "complete"
  end

  # Gets the height of the window

  def height
    @driver.manage.window.size.height
  end

  # Get the URL of the page

  def url
    @driver.current_url
  end

  def title
    @driver.title
  end

  # Gets the width of the window

  def width
    @driver.manage.window.size.width
  end

  def list_windows
    # returns an array of windows.
    @driver.window_handles
  end

end
