class CiCalculator
  attr_reader :data, :variable, :confidence_level, :orig_data


  def initialize(data, variable, calculate_method, precision = 2, confidence_level = 0.95)
    @data = data
    @variable = variable
    @confidence_level = confidence_level
    @precision = precision
    @calculate_method = calculate_method.to_i

    # save original data (then we will work with modified @data variable)
    @orig_data = data

    # filter only non zero values
    @data = @data.select{ |item| item > 0.0 }

    # transform data if "use log transform" selected
    @data.map!{ |item| Math.log(item) } if log_transform?


    # round values
    @data = @data.map{ |item| item.round(precision) }
  end

  def alpha
    1 - @confidence_level
  end

  # Sample size
  def n
    @data.size.to_f
  end

  def mean
    @mean ||= (@data.sum / n).round(@precision)
  end

  def orig_mean
    (@orig_data.sum / n).round(@precision)
  end

  def positive_count
    @data.select{ |value| value == @variable.positive_value }.size
  end

  def proportion
    positive_count / n
  end

  def standard_deviation
    Math.sqrt(@data.map{ |el| (el - mean)**2 }.sum / (n-1))
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

  def log_transform?
    @calculate_method == Experiment::Variable::LOG_TRANSFORM
  end

  def normal_dist?
    @calculate_method == Experiment::Variable::NORMAL_DIST
  end

  def binomial_dist?
    @calculate_method == Experiment::Variable::BINOMIAL_DIST
  end

  def margin_of_error
    t_value * standard_error
  end

  def standard_error
    standard_deviation / Math.sqrt(n)
  end

  def median
    middle_ind = n/2
    sorted = @orig_data.sort
    res = sorted[middle_ind-1]
    res = (res + sorted[middle_ind])/2 if n.to_i.even?
    res.round(@precision)
  end

  def mean_and_error
    return [0.0, 0.0, 0.0] if @data.empty?

    # continious data
    case @calculate_method
    when Experiment::Variable::NORMAL_DIST, Experiment::Variable::LOG_TRANSFORM
      x = mean
      delta = t_value * standard_error
    when Experiment::Variable::BINOMIAL_DIST
      x = adj_proportion
      delta = z_value * Math.sqrt((adj_proportion * (1 - adj_proportion))/adj_n)
    end

    upper = x + delta
    lower = x - delta

    # if log transfor data back
    if log_transform?
      x = Math.exp(x)
      upper = Math.exp(upper)
      lower = Math.exp(lower)
    end

    # return
    [x.round(@precision), upper.round(@precision), lower.round(@precision)]
  end
end