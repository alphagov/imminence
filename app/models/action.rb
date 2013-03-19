class Action
  include Mongoid::Document

  embedded_in :data_set

  field :requester_id, :type => Integer
  field :approver_id,  :type => Integer
  field :approved,     :type => DateTime
  field :comment,      :type => String
  field :request_type, :type => String
  field :created_at, :type => DateTime, :default => lambda { Time.zone.now }

end
