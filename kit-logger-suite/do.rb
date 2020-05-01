class DoStuff < SCPage

  include PageNameTranslator

  Dir[File.dirname(__FILE__) +"/do/*.rb"].each { |file|
    if file != __FILE__
      require_relative file
      file = File.basename(file, ".rb").capitalize
      include Module.const_get("Do#{File.basename(file, ".rb")}")
    end
  }

end
