module Faker
  class Address < Base
    DEFAULT_COUNTRY = 'US'
    attr_reader :street_address, :street_name, :secondary_address, :city, :province, :zip_code, :constituent_country, :country

    def initialize(country=nil)
      country = Faker::Country.country_for_code(country) if country.kind_of?(String)
      @country = country || Faker::Country.country

      number = fetch_by_country(@country.iso_3166_1_alpha2, "street_address")
      name = fetch_by_country(@country.iso_3166_1_alpha2, "street_name")
      suffix = fetch_by_country(@country.iso_3166_1_alpha2, "street_suffix")

      @street_address = self.class.numerify(number)
      @street_name = name + ' ' + suffix

      sec = fetch_by_country(@country.iso_3166_1_alpha2, "secondary_address")
      @secondary_address = self.class.numerify(sec)

      @city = fetch_by_country(@country.iso_3166_1_alpha2, "city").keys.sample
      @province = fetch_by_country(@country.iso_3166_1_alpha2, "city")[@city]
      if @province.kind_of?(Array) then
        @constituent_country = @province.last
        @province = @province.first
      end
      @province = nil if @province == @city

      zip = fetch_by_country(@country.iso_3166_1_alpha2, "postal_code")
      @zip_code = self.class.bothify(zip).upcase
    end

    def inspect
      "#<#{self.class.to_s} #{street_address} #{street_name}; #{secondary_address}; #{city} #{province} #{zip_code}; #{constituent_country} #{country.short_name}"
    end

    def latitude
      ((rand * 180) - 90).to_s
    end

    def longitude
      ((rand * 360) - 180).to_s
    end

    private
      def fetch_by_country(code, prop)
        Faker::Base.fetch("country_by_code.#{code}.#{prop}")
      rescue I18n::MissingTranslationData => e
        Faker::Base.fetch("country_by_code.#{DEFAULT_COUNTRY}.#{prop}")
      end
  end
end
