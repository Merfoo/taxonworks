module TopicsHelper

  def topic_tag(topic)
    return nil if topic.nil?
    topic.name
  end

  def topics_search_form
    render('/topics/quick_search_form')
  end

  def topic_list_tag(topics)
    content_tag(:span, topics.collect{|t| topic_tag(t)}.join("; "), class: 'topic_list')
  end

end
