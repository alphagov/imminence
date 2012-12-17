FactoryGirl.define do
  factory :business_support_business_type do
    name "Charity"
    slug "charity"
  end
  factory :business_support_location do
    name "England"
    slug "england"
  end
  factory :business_support_purpose do
    name "Setting up your business"
    slug "setting-up-your-business"
  end
  factory :business_support_scheme do
    title "EU Culture Programme"
    business_support_identifier "eu-culture-programme"
    priority 1
  end
  factory :business_support_sector do
    name "Tourism and travel"
    slug "tourism-and-travel"
  end
  factory :business_support_stage do
    name "Start-up"
    slug "start-up"
  end
  factory :business_support_type do
    name "Loan"
    slug "loan"
  end
end
