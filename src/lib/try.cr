class Try(T)
  def self.try
    Success(T).new(yield)
  rescue err
    Failure(T).new(err)
  end
end

class Success(T) < Try(T)
  def initialize(@value : T)
  end

  def map(&block : T -> U)
    yield(@value)
  end

  def recover(&block : Exception -> U)
    self
  end
end

class Failure(T) < Try(T)
  def initialize(@value : Exception)
  end

  def map(&block)
    self
  end

  def recover(&block : Exception -> U)
    yield
  end
end
