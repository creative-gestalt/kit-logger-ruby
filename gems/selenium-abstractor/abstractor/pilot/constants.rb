module AdapterConstants
  VALID_SELECTORS = {
  :class             => 'class name',
  :class_name        => 'class name',
  :css               => 'css selector',
  :id                => 'id',
  :link              => 'link text',
  :link_text         => 'link text',
  :name              => 'name',
  :partial_link_text => 'partial link text',
  :tag_name          => 'tag name',
  :xpath             => 'xpath',
  }

  VALID_EVENTS = [
    "click",
    "dblclick",
    "focus",
    "onkeydown",
    "onkeypress",
    "onkeyup",
    "mousedown",
    "onmouseout",
    "mouseover",
    "mouseup",
    "onchange",
    "blur",
    "onblur"
  ]

  VALID_LIST_ITEM_SELECTORS = [
    :index, :value, :text, :id
  ]
end


