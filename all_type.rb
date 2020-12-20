# frozen_string_literal: true

require "./base_type"

class AllType
  include BaseType

  DOCUMENT_TYPE = "all"
  ABBREVIATION = "a"

  def create_item(item_node)
    title_anchor = item_node.css(".thread-list-item__title-link")[0]
    username_anchor = item_node.css(".thread-list-item-meta .thread-header__author")[0]
    datetime_anchor = item_node.css(".thread-list-item-meta__updated-at")[0]

    title = title_anchor&.inner_text
    url = title_anchor&.attributes["href"].value
    username = username_anchor&.inner_text
    datetime = datetime_anchor&.inner_text
    subtitle = "#{username} #{datetime}"
    icon_path = search_icon_path(item_node)

    {
      title: title,
      subtitle: subtitle,
      arg: url,
      icon: {
        path: icon_path
      }
    }
  end

  def search_icon_path(item_node)
    class_attrs = item_node.attributes["class"].value.split(" ")
    if class_attrs.include?("is-report")
      ReportType::ICON_PATH
    elsif class_attrs.include?("is-product")
      ProductType::ICON_PATH
    elsif class_attrs.include?("is-announcement")
      InfoType::ICON_PATH
    elsif class_attrs.include?("is-page")
      DocType::ICON_PATH
    elsif class_attrs.include?("is-practice")
      PracticeType::ICON_PATH
    elsif class_attrs.include?("is-question")
      QuestionType::ICON_PATH
    else
      BaseType::DEFAULT_ICON_PATH
    end
  end
end
