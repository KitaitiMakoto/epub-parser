Given /^the file "([^"]*)" exists$/ do |file_name|
  unless File.exist? File.join(File.dirname(__FILE__), '..', '..', file_name)
    raise "File #{file_name} does not exist"
  end
end
