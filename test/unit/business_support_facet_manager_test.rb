require 'business_support_test_helper'
require 'business_support_facet_manager'

class BusinessSupportFacetManagerTest < ActiveSupport::TestCase

  include BusinessSupportTestHelper
  
  setup do
    make_facets(:business_support_business_type, ["Global megacorp", "Private company", "Charity"])
    make_facets(:business_support_location, ["England", "Scotland", "Wales", "Northern Ireland", "London",
                "South East", "Yorkshire and the Humber"])
    make_facets(:business_support_sector, ["Agriculture", "Healthcare", "Manufacturing"])
    make_facets(:business_support_stage, ["Pre-startup", "Startup", "Grow and sustain"])
    make_facets(:business_support_type, ["Award", "Loan", "Grant"])

    @superbiz = FactoryGirl.create(:business_support_scheme, title: "Super biz support",
                                   business_support_identifier: "111", priority: 1)
    @wunderbiz = FactoryGirl.create(:business_support_scheme, title: "Wunder biz support",
                                   business_support_identifier: "112", priority: 1)
    @megabiz = FactoryGirl.create(:business_support_scheme, title: "Mega biz support",
                                   business_support_identifier: "113", priority: 1)

    @superbiz.business_types = [@global_megacorp.slug, @private_company.slug]
    @superbiz.locations = [@england.slug, @wales.slug]
    @superbiz.save!

    @wunderbiz.sectors = [@agriculture.slug, @healthcare.slug]
    @wunderbiz.stages = [@pre_startup.slug, @startup.slug]
    @wunderbiz.support_types = [@award.slug, @loan.slug]
    @wunderbiz.save!

  end
 
  test "facet ids to slugs" do

    @ultrabiz = FactoryGirl.create(:business_support_scheme, title: "Ultra biz support",
                                   business_support_identifier: "10101", priority: 2,
                                   business_support_business_type_ids: [@private_company._id],
                                   business_support_location_ids: [@england._id, @scotland._id],
                                   business_support_sector_ids: [@agriculture._id, @healthcare._id],
                                   business_support_stage_ids: [@startup._id],
                                   business_support_type_ids: [@award._id, @grant._id])

    silence_stream(STDOUT) do
      BusinessSupportFacetManager.facet_ids_to_slugs
    end

    @ultrabiz.reload

    assert @ultrabiz.business_support_business_type_ids.empty?
    assert @ultrabiz.business_support_location_ids.empty?
    assert @ultrabiz.business_support_sector_ids.empty?
    assert @ultrabiz.business_support_stage_ids.empty?
    assert @ultrabiz.business_support_type_ids.empty?

    assert_equal [@private_company.slug], @ultrabiz.business_types
    assert_equal [@england.slug, @scotland.slug], @ultrabiz.locations
    assert_equal [@agriculture.slug, @healthcare.slug], @ultrabiz.sectors
    assert_equal [@startup.slug], @ultrabiz.stages
    assert_equal [@award.slug, @grant.slug], @ultrabiz.support_types
  end

  test "clear facet relations" do
    @superbiz.business_support_sectors << @agriculture
    @superbiz.save

    silence_stream(STDOUT) do
      BusinessSupportFacetManager.clear_facet_relations
    end

    @agriculture.reload

    assert @agriculture.business_support_scheme_ids.empty?

  end
  
end
