require_relative '../../integration_test_helper'

class PlaceCreateEditTest < ActionDispatch::IntegrationTest

  setup do
    @controller = Admin::PlacesController
    GDS::SSO.test_user = FactoryGirl.create(:user)
    GdsApi::Mapit.any_instance.stubs(:location_for_postcode).returns(nil)
    @service = FactoryGirl.create(:service)
    @data_set = @service.data_sets.create!(:version => 2)
    @place = FactoryGirl.create(:place, service_slug: @service.slug, data_set_version: @data_set.version)
  end

  test "Editing a place to override location coordinates" do
    visit "/admin/services/#{@service.to_param}/data_sets/#{@data_set.to_param}/places/#{@place.to_param}/edit"
        
    fill_in "Override latitude", :with => "54.9949"
    fill_in "Override longitude", :with => "-1.4274"

    click_on "Update Place"
    
    within('table.table-places') do
      assert page.has_css?("td", :text => "54.9949, -1.4274")
    end
  end

  test "Editing a place to override location coordinates with gibberish" do
    visit "/admin/services/#{@service.to_param}/data_sets/#{@data_set.to_param}/places/#{@place.to_param}/edit"
        
    fill_in "Override latitude", :with => "Barry"
    fill_in "Override longitude", :with => "Manilow"

    click_on "Update Place"
    
    within("form#edit_place_#{@place.to_param}") do
      assert page.has_css?("div#place_override_lat_input", :text => "is not a number")
      assert page.has_css?("div#place_override_lng_input", :text => "is not a number")
    end
  end

  test "Editing a place to override one location coordinate" do
    visit "/admin/services/#{@service.to_param}/data_sets/#{@data_set.to_param}/places/#{@place.to_param}/edit"
        
    fill_in "Override latitude", :with => "54.9949"

    click_on "Update Place"
    
    within("form#edit_place_#{@place.to_param}") do
      assert page.has_css?("div#place_override_lng_input", :text => "longitude must be a valid coordinate")
    end
  end

  test "Editing a place without overriding location coordinates" do
    visit "/admin/services/#{@service.to_param}/data_sets/#{@data_set.to_param}/places/#{@place.to_param}/edit"

    click_on "Update Place"
    
    within('table.table-places') do
      assert page.has_css?("td", :text => "53.1055, -2.0175")
    end
  end

end
