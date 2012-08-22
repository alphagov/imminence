Given /^I have previously created the "(.*?)" service$/ do |name|
  @service = create_service(name)
end

Given /^I have uploaded a second data set$/ do
  upload_extra_data_set(@service)
end

When /^I go to the new service page$/ do
  visit new_admin_service_path
end

When /^I go to the page for the "(.*?)" service$/ do |name|
  visit path_for_service(name)
end

When /^I upload a new data set$/ do
  within "#new-data" do
    attach_file "Data file", csv_path_for_data("Register Offices")
    click_button "Create Data set"
  end
end

When /^I click "Activate"$/ do
  click_button 'Activate'
end

When /^I fill in the form to create the "(.*?)" service with a bad CSV$/ do |name|
  fill_in_form_with(name, Rails.root.join('features/support/data/bad.csv'))
end

Then /^I should see an indication that my data set import failed$/ do
  assert page.has_content?("This may well mean the imported data was in the wrong format")
end

Then /^show me the page$/ do
  save_and_open_page
end

Then /^I fill in the form to create the "(.*?)" service$/ do |name|
  fill_in_form_with(name, csv_path_for_data(name))
end

Then /^I should be on the page for the "(.*?)" service$/ do |name|
  current_path = URI.parse(current_url).path
  assert_equal path_for_service(name), current_path
end

Then /^I should see an indication that my data set contained (\d+) items$/ do |count|
  assert page.has_content?("containing #{count} places")
end

Then /^I should see that there are now two data sets$/ do
  assert page.has_content?("Version 2 uploaded at")
end

Then /^I should see that the second data set is active$/ do
  assert page.has_content?("Currently serving version 2")
end