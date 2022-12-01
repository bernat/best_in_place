class TestResult < ActiveRecord::Base
  belongs_to :user

  AVAILABLE_TESTS = %w(Meyers-Briggs Stanford-Binet SAT)

  def name_to_slug
    name.downcase.gsub(/\W/, '_')
  end

  def options
    if name == 'Meyers-Briggs'
      %w( ISTJ ISFJ INFJ INTJ ISTP ISFP ).map { |v| [v, v] }
    end
  end

end
