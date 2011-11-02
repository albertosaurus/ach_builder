Given /^an empty wells fargo ach file$/ do
  @file = well_fargo_empty_filename
end

When /^I read this file with ach reader$/ do
  @result = ACH::Reader.from_file @file
end

Then /^it should be converted to ach file instance$/ do
  @result.should be_instance_of ACH::File
end