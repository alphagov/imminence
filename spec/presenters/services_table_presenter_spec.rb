require "rails_helper"
require "presenters/table_presenter_shared_examples"

RSpec.describe(ServicesTablePresenter, type: :model) do
  include TablePresenterSharedExamples

  before do
    stub_search_finds_no_govuk_pages
    @service = FactoryBot.create(:service)
    @presenter = ServicesTablePresenter.new([@service], fake_view_context)
  end
end
