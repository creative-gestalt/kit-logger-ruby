require 'open-uri'

require 'json'
module PageNameTranslator
  def self.append_methods_to their_instance, containing_module
    page_names = containing_module.constants.select {|c| Class === containing_module.const_get(c)}
    page_names.each do |page_name|
      module_name = "::#{containing_module.to_s}::#{page_name}"
      their_instance.define_singleton_method page_name.downcase do
        Module.const_get(module_name).new driver, their_instance
      end
    end
  end
end
