# frozen_string_literal: true

require "./base_type"

class ReportType
  include BaseType

  DOCUMENT_TYPE = "reports"
  ABBREVIATION = "r"
  ICON_PATH = "#{BaseType::IMAGES_PATH}/#{DOCUMENT_TYPE}.png"

  def create_item(item_node)
    title_anchor = item_node.css(".thread-list-item__title-link")[0]
    username_anchor = item_node.css(".thread-list-item-meta .thread-header__author")[0]
    datetime_anchor = item_node.css(".thread-list-item-meta__updated-at")[0]

    title = title_anchor&.inner_text
    url = title_anchor&.attributes["href"].value
    username = username_anchor&.inner_text
    datetime = datetime_anchor&.inner_text
    subtitle = "#{username} #{datetime}"

    {
      title: title,
      subtitle: subtitle,
      arg: url,
      icon: {
         path: ICON_PATH
      }
    }
  end
end
