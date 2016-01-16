# encoding: utf-8

class FilterItem
  def item_uid; end
  def item_valid; end
  def item_autocomplete; end
  def item_arg; end
  def item_type; end
  def item_title; end
  def item_subtitle; end
  def item_subtitle_shift; end
  def item_subtitle_fn; end
  def item_subtitle_ctrl; end
  def item_subtitle_alt; end
  def item_subtitle_cmd; end
  def item_icon_type; end
  def item_icon; end
  def item_text_copy; end
  def item_text_largetype; end
  def build_xml(o)
    o << "<item"
    # build_attr(o, 'uid', item_uid)
    # build_attr(o, 'valid', item_valid)
    # build_attr(o, 'autocomplete', item_autocomplete)
    build_attr(o, 'arg', item_arg)
    build_attr(o, 'type', item_type)
    o << ">\n"
    build_tag(o, item_title) {|s| "<title>#{s}</title>\n" }
    build_tag(o, item_subtitle) {|s| "<subtitle>#{s}</subtitle>\n" }
    build_tag(o, item_subtitle_shift) {|s| "<subtitle mod='shift'>#{s}</subtitle>\n" }
    # build_tag(o, item_subtitle_fn) {|s| "<subtitle mod='fn'>#{s}</subtitle>\n" }
    # build_tag(o, item_subtitle_ctrl) {|s| "<subtitle mod='ctrl'>#{s}</subtitle>\n" }
    # build_tag(o, item_subtitle_alt) {|s| "<subtitle mod='alt'>#{s}</subtitle>\n" }
    # build_tag(o, item_subtitle_cmd) {|s| "<subtitle mod='cmd'>#{s}</subtitle>\n" }
    build_tag(o, item_icon) {|s| "<icon#{ build_attr('', 'type', item_icon_type) }>#{s}</icon>\n" }
    build_tag(o, item_text_copy) {|s| "<text type='copy'>#{s}</text>\n" }
    build_tag(o, item_text_largetype) {|s| "<text type='largetype'>#{s}</text>\n" }
    o << "</item>\n"
  end
  def build_tag(o, s)
    o << yield(s.encode(xml: :text)) unless s.nil?
  end
  def build_attr(o, k, s)
    o << " #{k}=#{s.encode(xml: :attr)}" unless s.nil?
  end
end
