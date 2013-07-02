require 'test_helper'

class PlacesControllerTest < ActionController::TestCase

  setup do
    @service = Service.create!(
      name: "Important Government Service",
      slug: "important-government-service"
    )

    @buckingham_palace = Place.create!(
      service_slug: 'important-government-service',
      data_set_version: @service.data_sets.last.version,
      postcode: 'SW1A 1AA',
      source_address: 'Buckingham Palace, Westminster',
      override_lat: '51.501009611553926', override_lng: '-0.141587067110009'
    )
    @aviation_house = Place.create!(
      service_slug: 'important-government-service',
      data_set_version: @service.data_sets.last.version,
      postcode: 'WC2B 6SE',
      source_address: 'Aviation House',
      override_lat: '51.516960431', override_lng: '-0.120586400134'
    )
    @scottish_parliament = Place.create!(
      service_slug: 'important-government-service',
      data_set_version: @service.data_sets.last.version,
      postcode: 'EH99 1SP',
      source_address: 'Scottish Parliament',
      override_lat: '55.95439', override_lng: '-3.174706'
    )
    @utopia = Place.create!(
      service_slug: 'important-government-service',
      data_set_version: @service.data_sets.last.version,
      postcode: 'AB11 2CD',
      source_address: 'Nowhere'
    )
  end

  test "as a logged in user I can access a non-active data set" do
    as_logged_in_user do
      get :show, id: @service.slug, format: :json
      assert_response :success
      assert_equal 4, JSON.parse(response.body).size
    end
  end

  test "can show a JSON representation of places" do
    as_logged_in_user do
      get :show, id: @service.slug, format: :json
      assert_response :success
      json_data = JSON.parse(response.body)

      place = json_data.find { |p| p["source_address"] == "Aviation House" }
      assert_equal "WC2B 6SE", place["postcode"]
      location_hash = {
        "latitude" => 51.516960431,
        "longitude" => -0.120586400134
      }
      assert_equal location_hash, place["location"]
    end
  end

  test "can show a JSON representation of a place with no coordinates" do
    as_logged_in_user do
      get :show, id: @service.slug, format: :json
      assert_response :success
      json_data = JSON.parse(response.body)

      place = json_data.find { |p| p["source_address"] == "Nowhere" }
      assert_nil place["location"]
    end
  end

  test "can show a KML representation of places" do
    as_logged_in_user do
      get :show, id: @service.slug, format: :kml
      assert_response :success
      kml_data = Hash.from_xml(response.body)
      assert_equal 4, kml_data["kml"]["Document"]["Placemark"].size

      # Sort the places by their address field (effectively, by postcode)
      sorted_places = kml_data["kml"]["Document"]["Placemark"].sort { |a, b|
        a["address"] <=> b["address"]
      }
      location_points = [
        nil,
        Point.new(longitude: -3.174706, latitude: 55.95439),
        Point.new(longitude: -0.141587067110009, latitude: 51.501009611553926),
        Point.new(longitude: -0.120586400134, latitude: 51.516960431)
      ]
      sorted_places.zip(location_points) do |placemark, point|
        if point
          assert_equal(
            "#{point.longitude},#{point.latitude},0",
            placemark["Point"]["coordinates"]
          )
        else
          assert_nil placemark["Point"]
        end
      end
    end
  end
end
