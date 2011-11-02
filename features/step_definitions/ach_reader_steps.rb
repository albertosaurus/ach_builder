Given /^an empty wells fargo ach file$/ do
  @filename = well_fargo_empty_filename
end

When /^I read this file with ach reader$/ do
  @result = ACH::File::Reader.from_file @filename
end

Then /^it should be converted to ach file instance$/ do
  @result.should be_instance_of ACH::File
end

Given /^an wells fargo with data ach file$/ do
  @filename = well_fargo_with_data
end

When /^I convert ach file instance to string$/ do
  @result = @file.to_s!
end

Then /^string should be equal to given ach file$/ do
  @result.should == File.read(@filename)
end

When /^I take this ach file instance$/ do
  @file = @result
end

Then /^ach file instance should has "([^"]*)" batches$/ do |count|
  @file.batches.count.should == count.to_i
end

Then /^ach file instance should has header$/ do
  @file.header.should be_an ACH::File::Header
end

When /^I cut tail with the nines$/ do
  @result.gsub! /^9+\n?$/, ''
  @result.gsub! /^\n$/, ''
end
