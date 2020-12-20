# frozen_string_literal: true

require "./base_type"

class ProductType
  include BaseType

  DOCUMENT_TYPE = "products"
  ABBREVIATION = "t"
  ICON_PATH = "#{BaseType::IMAGES_PATH}/#{DOCUMENT_TYPE}.png"
end
