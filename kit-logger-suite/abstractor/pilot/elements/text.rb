require_relative 'element'

class Text < DOMElement

  def clear
    element.clear
  end

  def type(text)
    element.send_keys text
  end

  def set(text = '')
    element.send_keys([:control, 'a'], :delete, text, [:tab])
  end
end
