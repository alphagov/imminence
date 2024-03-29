Given(/^I have previously created the "(.*?)" service$/) do |name|
  params = { name:, slug: name.parameterize, csv_path: csv_path_for_data(name) }

  @service = create_service(params)
end

Given(/^(?:a|an) (.*?) editor has previously created the "(.*?)" service$/) do |organisation_slug, name|
  params = { name:, slug: name.parameterize, organisation_slugs: [organisation_slug], csv_path: csv_path_for_data(name) }

  @service = create_service(params)
end

Given(/^I have previously created a service with the following attributes:$/) do |table|
  params = table.rows_hash.symbolize_keys!
  raise ArgumentError, "name cannot be nil" if params[:name].nil?

  params = {
    slug: params[:name].parameterize,
    csv_path: csv_path_for_data(params[:name]),
  }.merge(params)

  @service = create_service(params)
end

When(/^I go to the new service page$/) do
  visit new_admin_service_path
end

When(/^I go to the page for the "(.*?)" service$/) do |name|
  visit path_for_service(name)
end

When(/^I click on "(.*?)"/) do |name|
  click_link name
end

When("I reload the page") do
  visit current_path
end

When("I go to the service list page") do
  stub_search_finds_no_govuk_pages
  visit root_path
end

Then("I should be able to see the Register Offices service") do
  expect(page).to have_content("Register Offices")
end

Then("I should not be able to see the Register Offices service") do
  expect(page).to_not have_content("Register Offices")
end

When(/^I fill in the form to create the "(.*?)" service with a bad CSV$/) do |name|
  params = {
    name:,
    slug: name.parameterize,
    csv_path: Rails.root.join("features/support/data/bad.csv"),
  }

  fill_in_form_with(params)
end

When(/^I fill in the form to create the "(.*?)" service with a PNG claiming to be a CSV$/) do |name|
  params = {
    name:,
    slug: name.parameterize,
    csv_path: Rails.root.join("features/support/data/rails.csv"),
  }

  fill_in_form_with(params)
end

When(/^I fill in the form to create the "(.*?)" service with a PNG$/) do |name|
  params = {
    name:,
    slug: name.parameterize,
    csv_path: Rails.root.join("features/support/data/rails.png"),
  }

  fill_in_form_with(params)
end

When(/^I fill out the form with the following attributes to create a service:$/) do |table|
  params = table.rows_hash.symbolize_keys!
  raise ArgumentError, "name cannot be nil" if params[:name].nil?

  params = {
    slug: params[:name].parameterize,
    csv_path: csv_path_for_data(params[:name]),
  }.merge(params)

  fill_in_form_with(params)
end

Then(/^I should be on the page for the "(.*?)" service$/) do |name|
  current_path = URI.parse(current_url).path
  expect(path_for_service(name)).to eq(current_path)
end

Then(/^there should not be a "(.*?)" service$/) do |name|
  expect(Service.where(name:).count).to eq(0)
end

Then(/^I should see that the current service has (\d+) missing GSS codes$/) do |count|
  content = "#{count} with missing GSS codes"
  expect(page).to have_content(content)
end

Then(/^I should see that the current data set has (\d+) missing GSS codes$/) do |count|
  content = "#{count} with missing GSS codes"
  expect(page).to have_content(content)
end

Then(/^I should not see any text about missing GSS codes$/) do
  expect(page).to_not have_content("with missing GSS codes")
end

When(/^I activate the most recent data set for the "(.*?)" service$/) do |name|
  steps %(
    And I go to the page for the "#{name}" service
    And I visit the history tab
    And I activate the most recent data set
  )
end

When(/^I should see (\d+) version panels?$/) do |count|
  version_panels = page.all(:css, "div .data-set")
  expect(version_panels.size).to eq(count.to_i)
end

Then("I should see the version is {int}") do |int|
  expect(page).to have_content("Active Data set version #{int}")
end

Then(/^the first version panel has the title "(.*?)"$/) do |title|
  within "div.data-set:nth-child(1)" do
    within "h3.panel-title" do
      expect(page).to have_content(title)
    end
  end
end

Then(/^the first version panel has the text "(.*?)"$/) do |text|
  within "div.data-set:nth-child(1)" do
    expect(page).to have_content(text)
  end
end

Then(/^the first version panel shows a warning about missing GSS codes$/) do
  within "div.data-set:nth-child(1)" do
    expect(page).to have_css("p.missing-gss-warning")
  end
end
