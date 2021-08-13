class Object
  def or(v)
    self ? self : v
  end

  def with(&b)
    self ? yield self : nil
  end
end
