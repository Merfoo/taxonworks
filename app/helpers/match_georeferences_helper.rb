module MatchGeoreferencesHelper
=begin
  def link_to_filter_ce
    link_to('filter', '', class: 'filter-ce')
  end
  def link_to_tag_ce
    link_to('tag', '', class: 'tag-ce')
  end
  def link_to_draw_ce
    link_to('draw', '', class: 'draw-ce')
  end
  def link_to_recent_ce
    link_to('recent', '', class: 'recent-ce')
  end
  def link_to_filter_gr
    link_to('filter', '', class: 'filter-gr')
  end
  def link_to_tag_gr
    link_to('tag', '', class: 'tag-gr')
  end
  def link_to_draw_gr
    link_to('draw', '', class: 'draw-gr')
  end
  def link_to_recent_gr
    link_to('recent', '', class: 'recent-gr')
    end
=end
  # @param [String] method of (filter, tag, draw, recent)
  # @param [String] type of (ce, gr)
  # @return [Link] to visualize a particular partial
  def link_to_georeference_match_type(method, type)
    link_to("#{method}", '#', data: { turbolinks: false }, class: "#{method}-#{type}")
  end
end
