require "action_controller"

class ActionController::Base
  before_filter :pc_remove_angle_brackets_from_params

  class <<self
    def do_not_clean_param(*names)
      names.each do |name|
        pc_uncleaned_params.push([*name].map{ |s| s.to_s })
      end
    end

    def pc_uncleaned_params
      @pc_uncleaned_params ||= []
    end
  end

private
  def pc_remove_angle_brackets_from_params
    pc_remove_angle_brackets_from_hash(params)
  end

  def pc_remove_angle_brackets_from_hash(hash, hierarchy=[])
    hash.each do |key, value|
      h = hierarchy + [key]
      case value
      when Hash, HashWithIndifferentAccess
        pc_remove_angle_brackets_from_hash(value, h)
      when Array
        value.map!{ |v| pc_remove_angle_brackets_from_value(v, h) }
      when String
        hash[key] = pc_remove_angle_brackets_from_value(value, h)
      end
    end
  end

  def pc_remove_angle_brackets_from_value(value, hierarchy)
    if hierarchy.any?{ |k| k =~ /password/ }
      return value
    elsif self.class.pc_uncleaned_params.include?(hierarchy)
      return value
    else
      value.gsub(/<>/, "")
    end
  end
end
