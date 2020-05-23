require_relative 'element'

class Checkbox < DOMElement

  def checked?
    element.selected?
  end

  def on
    unless attribute('checked')
      click()
    end
  end

  def off
    if attribute('checked')
      click()
    end
  end
end
