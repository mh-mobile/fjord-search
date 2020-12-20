# frozen_string_literal: true

require "uri"

module BaseType
  attr_reader :keyword
  IMAGES_PATH = "./images"
  DEFAULT_ICON_PATH = "./icon.png"

  def initialize(keyword)
    @keyword = keyword || ""
  end

  def search_url
    word = URI.encode_www_form_component(@keyword.unicode_normalize)
    "https://bootcamp.fjord.jp/searchables?document_type=#{self.class::DOCUMENT_TYPE}&word=#{word}"
  end

  def create_item(item_node)
    raise "implement this method."
  end
end
