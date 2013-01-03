class BusinessSupportScheme
  include Mongoid::Document
  
  field :title, type: String
  field :business_support_identifier, type: String
  field :priority, type: Integer, default: 1

  # These relations are required for data migration from facet ids to slugs
  # and can be removed once this task is complete.
  #
  has_and_belongs_to_many :business_support_business_types
  has_and_belongs_to_many :business_support_locations
  has_and_belongs_to_many :business_support_purposes
  has_and_belongs_to_many :business_support_sectors
  has_and_belongs_to_many :business_support_stages
  has_and_belongs_to_many :business_support_types

  field :business_types,  type: Array, default: []
  field :locations,       type: Array, default: []
  field :purposes,        type: Array, default: []
  field :sectors,         type: Array, default: []
  field :stages,          type: Array, default: []
  field :support_types,   type: Array, default: []

  index :title, unique: true
  index :business_support_identifier, unique: true
  index :locations

  validates_presence_of :title, :business_support_identifier
  validates_uniqueness_of :title
  validates_uniqueness_of :business_support_identifier
  validates_presence_of :priority
  validates_inclusion_of :priority, in: [0,1,2]

  before_validation :populate_business_support_identifier, :on => :create 

  scope :for_relations, lambda { |relations|
    where({ "$and" => schemes_criteria(relations) }).order_by([:priority, :desc], [:title, :asc])
  }

  def self.schemes_criteria(relations)
    criteria = []
    relations.each do |k, v|
      collection = "#{k.to_s.singularize}s".to_sym
      slugs = v.split(",")
      criteria << { collection => { "$in" => slugs } } unless slugs.empty?
    end
    criteria 
  end

  def populate_business_support_identifier
    self.business_support_identifier ||= self.class.next_identifier
  end

  # TODO: This field originally stored a String identifier.
  # This was later changed to a numerical one, it would benefit from Integer field conversion.
  def self.next_identifier
    schemes = BusinessSupportScheme.all.sort do |a,b| 
      a.business_support_identifier.to_i <=> b.business_support_identifier.to_i
    end
    schemes.empty? ? 1 : schemes.last.business_support_identifier.to_i + 1
  end

end
