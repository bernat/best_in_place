# encoding: utf-8

describe "with new records", :js => true do
  before do
    @user = User.new :name => "Julian",
      :last_name => "Bronson",
      :email => "jbro@example.com",
      :address => '1925 Park Ave',
      :zip => '10001',
      :description => 'Excellent at taking tests.'
  end

  it "should create new records with proper associations" do
    @user.save!
    expect(@user.test_results.length).to eq 0

    visit admin_user_path(@user)
    expect(find('#test-results-table')).to have_content('Meyers-Briggs')
    expect(find('#test-results-table')).to have_content('Stanford-Binet')
    expect(find('#test-results-table')).to have_content('SAT')

    bip_text 'test_result_sat', :result, "1700"
    bip_text 'test_result_stanford_binet', :result, "120"
    bip_select 'test_result_meyers_briggs', :result, "INFJ"

    @user.reload
    expect(@user.test_results.length).to eq 3

    visit admin_user_path(@user)

    expect(find('#best_in_place_test_result_sat_result')).to have_content('1700')
    expect(find('#best_in_place_test_result_stanford_binet_result')).to have_content('120')
    expect(find('#best_in_place_test_result_meyers_briggs_result')).to have_content('INFJ')
  end

  it "should update persisted records as well" do
    @user.save!
    test_result = TestResult.new name: 'SAT', result: '1310', user_id: @user.id
    test_result.save!

    visit admin_user_path(@user)
    expect(find('#best_in_place_test_result_sat_result')).to have_content('1310')

    bip_text 'test_result_sat', :result, "1410"
    bip_select 'test_result_meyers_briggs', :result, "ISFP"

    visit admin_user_path(@user)

    expect(find('#best_in_place_test_result_sat_result')).to have_content('1410')
    expect(find('#best_in_place_test_result_meyers_briggs_result')).to have_content('ISFP')
  end

  it "should create new records then change the bip instance to updating the persited record" do
    @user.save!

    visit admin_user_path(@user)
    bip_text 'test_result_stanford_binet', :result, "110"

    @user.reload
    expect(@user.test_results.length).to eq 1
    expect(@user.test_results.first.result).to eq "110"

    bip_text 'test_result_stanford_binet', :result, "120"

    @user.test_results.reload
    expect(@user.test_results.length).to eq 1
    expect(@user.test_results.first.result).to eq "120"
  end

end
