describe "Quickbooks::Service::Changes" do
  let(:time) { Time.new(2013,2,1,5,30) }
  before(:all) do
    construct_service :changes
  end

  it "make batch request with success" do
    xml = fixture("changes_response.xml")
    stub_request(:get, "#{@service.url_for_resource('cdc')}?entities=Customer,SalesReceipt&changedSince=#{time.strftime('%Y-%m-%dT%H:%M:%S%z')}", ["200", "OK"], xml)
    change_resp = @service.make_request(entities: ["Customer", "SalesReceipt"], since: time)
    change_resp.class.should == Quickbooks::Model::ChangesResponse
    change_resp.response.should_not == nil

    change_resp.response.responses.size.should == 2
    change_resp.response.responses.first.customers.size.should == 1
    change_resp.response.responses.last.sales_receipts.size.should == 2
  end

  it "should provide easier yield to get results" do
    xml = fixture("changes_response.xml")
    stub_request(:get, "#{@service.url_for_resource('cdc')}?entities=Customer,SalesReceipt&changedSince=#{time.strftime('%Y-%m-%dT%H:%M:%S%z')}", ["200", "OK"], xml)
    change_resp = @service.make_request(entities: ["Customer", "SalesReceipt"], since: time)
    change_resp.class.should == Quickbooks::Model::ChangesResponse
    change_resp.response.should_not == nil

    results = []
    change_resp.each_change {|change|
      results << change
    }
    results.size.should == 3
    results[0].kind_of?(Quickbooks::Model::Customer).should == true
    results[1].kind_of?(Quickbooks::Model::SalesReceipt).should == true
    results[2].kind_of?(Quickbooks::Model::SalesReceipt).should == true
  end

  it "make batch request with error" do
    xml = fixture("changes_response.xml")
    stub_request(:get, "#{@service.url_for_resource('cdc')}?entities=Customer,SalesReceipt&changedSince=#{time.strftime('%Y-%m-%dT%H:%M:%S%z')}", ["400", "OK"], xml)
    
    Proc.new{
      @service.make_request(entities: ["Customer", "SalesReceipt"], since: time)
    }.should raise_error(Quickbooks::IntuitRequestException)
  end
end
