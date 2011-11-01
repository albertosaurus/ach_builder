module AchFilesExamples

  def well_fargo_empty_filename
    File.expand_path(File.dirname(__FILE__) + '/../examples/well_fargo_empty.ach')
  end

end

include AchFilesExamples