
#
#Manages file uploading.
#
class Files < DOMElement

  def upload(path)
    element.send_keys path
  end
end
