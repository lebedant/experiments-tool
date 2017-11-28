class CiCalculator
  attr_reader :data, :variable, :confidence_level


  def initialize(data, variable, confidence_level = 0.95)
    @data = data
    @variable = variable
    @confidence_level = confidence_level
  end

  def alpha
    1 - @confidence_level
  end

  # Sample size
  def n
    @data.size.to_f
  end

  def mean
    @mean ||= @data.sum / n
  end

  def positive_count
    @data.select{ |value| value == @variable.positive_value }.size
  end

  def proportion
    positive_count / n
  end

  def standard_deviation
    Math.sqrt(@data.map{ |el| (el - mean)**2 }.sum / n)
  end

  def t_value
    df = n - 1 # degrees of freedom
    # 2-tail critival value for alpha
    Distribution::T.ptsub(alpha, df)
  end

  def z_value
    (Distribution::Normal.p_value(alpha/2) * -1)
  end

  def adj_proportion
    (positive_count + (z_value**2)/2) / adj_n
  end

  def adj_n
    n + z_value**2
  end


  def mean_and_error
    # continious data
    if @variable.double?
      x = mean
      delta = t_value * (standard_deviation / Math.sqrt(n))
    else
      x = adj_proportion
      delta = z_value * Math.sqrt((adj_proportion*(1 - adj_proportion))/adj_n)
    end

    upper = x + delta
    lower = x - delta

    # return
    [x.round(3), upper.round(3), lower.round(3)]
  end
end