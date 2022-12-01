class User < ActiveRecord::Base
  validates :name,
    :length => { :minimum => 2, :maximum => 24, :message => "has invalid length"},
    :presence => {:message => "can't be blank"}
  validates :last_name,
    :length => { :minimum => 2, :maximum => 50, :message => "has invalid length"},
    :presence => {:message => "can't be blank"}
  validates :address,
    :length => { :minimum => 5, :message => "too short length"},
    :presence => {:message => "can't be blank"}
  validates :email,
    :presence => {:message => "can't be blank"},
    :format => {:with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, :message => "has wrong email format"}
  validates :zip, :numericality => true, :length => { :minimum => 5 }
  validates_numericality_of :money, :allow_blank => true
  validates_numericality_of :money_proc, :allow_blank => true

  alias_attribute :money_custom, :money
  alias_attribute :money_value, :money
  alias_attribute :receive_email_default, :receive_email
  alias_attribute :receive_email_image, :receive_email
  alias_attribute :description_simple, :description

  has_many :test_results

  def address_format
    "<b>addr => [#{address}]</b>".html_safe
  end

  def markdown_desc
    RDiscount.new(description).to_html.html_safe
  end

  def zip_format
    nil
  end

  def tests
    TestResult::AVAILABLE_TESTS.map do |test_type|
      test_results.where(name: test_type).first || TestResult.new(name: test_type, user_id: id)
    end
  end
end
