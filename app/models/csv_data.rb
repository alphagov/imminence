class CsvData
  include Mongoid::Document
  include Mongoid::Timestamps

  field :service_slug, type: String
  field :data_set_version, type: Integer
  field :data, type: String

  # Mongoid has a 16M limit on document size.  Set this to
  # 15M to leave some headroom for storing the rest of the document.
  validates :data, length: { maximum: 15.megabytes, message: "CSV file is too big (max is 15MB)" }
  validates :service_slug, presence: true
  validates :data_set_version, presence: true
  validates :data, presence: true

  def service
    @service ||= Service.find_by(slug: service_slug)
  end

  def data_set
    @data_set ||= service.data_sets.find_by(version: data_set_version) if service
  end

  def data_file=(file)
    self.data =
      if file.nil?
        nil
      else
        read_as_utf8(file)
      end
  end

private

  def read_as_utf8(file)
    string = File.read(file, mode: "r:bom|utf-8")
    unless string.valid_encoding?
      # Try windows-1252 (which is a superset of iso-8859-1)
      string.force_encoding("windows-1252")
      # Any stream of bytes should be a vaild Windows-1252 string, so we use the presence of any
      # ASCII control chars (except for \r and \n) as a good heuristic to determine if this is
      # likely to be the correct charset
      if string.valid_encoding? && !string.match(/[\x00-\x09\x0b\x0c\x0e-\x1f]/)
        return string.encode("utf-8")
      end

      raise InvalidCharacterEncodingError, "Unknown character encoding"
    end
    string
  end
end
