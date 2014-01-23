#
# Copyright (c) 2014 SoftLayer Technologies, Inc. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

$: << File.expand_path(File.join(File.dirname(__FILE__), "../lib"))

require 'rubygems'
require 'softlayer_api'
require 'rspec'
require 'rspec/autorun'

describe SoftLayer::Service, "#new" do
  before(:each) do
    $SL_API_USERNAME = "some_default_username"
    $SL_API_KEY = "some_default_api_key"
    $SL_API_BASE_URL = SoftLayer::API_PUBLIC_ENDPOINT
  end

  after(:each) do
    $SL_API_USERNAME = nil
    $SL_API_KEY = nil
    $SL_API_BASE_URL = SoftLayer::API_PUBLIC_ENDPOINT
  end

  it "should reject a nil or empty service name" do
    lambda() {service = SoftLayer::Service.new(nil)}.should raise_error
    lambda() {service = SoftLayer::Service.new("")}.should raise_error
  end

  it "should remember service name passed in" do
    service = SoftLayer::Service.new("SoftLayer_Account")
    service.service_name.should == "SoftLayer_Account"
  end

  it "should pickup default username" do
    $SL_API_USERNAME = "sample"
    service = SoftLayer::Service.new("SoftLayer_Account")
    service.username.should == "sample"
  end

  it "should accept a username in options" do
    $SL_API_USERNAME = "sample"
    service = SoftLayer::Service.new("SoftLayer_Account", :username => 'fred')
    service.username.should == "fred"
  end

  it "should pickup default api key" do
    $SL_API_KEY = "sample"
    service = SoftLayer::Service.new("SoftLayer_Account")
    service.api_key.should == "sample"
  end

  it "should accept an api key in options" do
    $SL_API_KEY = "sample"
    service = SoftLayer::Service.new("SoftLayer_Account", :api_key => 'fred')
    service.api_key.should == "fred"
  end

  it "should fail if username is empty" do
    lambda() do
      $SL_API_USERNAME = ""
      $SL_API_KEY = "sample"

      service = SoftLayer::Service.new("SoftLayer_Account")
    end.should raise_error

    lambda() do
      $SL_API_USERNAME = "good_username"
      $SL_API_KEY = "sample"

      service = SoftLayer::Service.new("SoftLayer_Account", :username => "")
    end.should raise_error
  end

  it "should fail if username is nil" do
    lambda() do
      $SL_API_USERNAME = nil
      service = SoftLayer::Service.new("SoftLayer_Account", :api_key => "sample")
    end.should raise_error

    lambda() do
      $SL_API_KEY = "sample"
      service = SoftLayer::Service.new("SoftLayer_Account", :username => nil, :api_key => "sample")
    end.should raise_error
  end

  it "should fail if api_key is empty" do
    lambda() do
      $SL_API_USERNAME = "good_username"
      $SL_API_KEY = ""

      service = SoftLayer::Service.new("SoftLayer_Account")
    end.should raise_error

    lambda() do
      $SL_API_USERNAME = "good_username"
      $SL_API_KEY = "good_api_key"

      service = SoftLayer::Service.new("SoftLayer_Account", :username => "sample", :api_key => "")
    end.should raise_error
  end

  it "should fail if api_key is nil" do
    lambda() do
      $SL_API_KEY = nil
      service = SoftLayer::Service.new("SoftLayer_Account", :username => "sample")
    end.should raise_error

    lambda() do
      $SL_API_KEY = nil
      service = SoftLayer::Service.new("SoftLayer_Account", :username => "sample", :api_key => nil)
    end.should raise_error
  end

  it "should pickup default base url" do
    $SL_API_BASE_URL = nil
    service = SoftLayer::Service.new("SoftLayer_Account")
    service.endpoint_url.should == SoftLayer::API_PUBLIC_ENDPOINT
  end

  it "should get base URL from globals" do
    $SL_API_BASE_URL = "http://someendpoint.softlayer.com/from/globals"
    service = SoftLayer::Service.new("SoftLayer_Account")
    service.endpoint_url.should == "http://someendpoint.softlayer.com/from/globals"
  end

  it "should accept a base url through options" do
    service = SoftLayer::Service.new("SoftLayer_Account", :endpoint_url => "http://someendpoint.softlayer.com")
    service.endpoint_url.should == "http://someendpoint.softlayer.com"
  end
end #describe SoftLayer#new

describe SoftLayer::Service, "#username=" do
  it "should not allow you to set a nil or empty username" do
    service = SoftLayer::Service.new("SoftLayer_Account", :username => "sample", :api_key => "sample")
    lambda() {service.username = ""}.should raise_error
    lambda() {service.username = nil}.should raise_error
  end

  it "should strip whitespace" do
    service = SoftLayer::Service.new("SoftLayer_Account", :username => "sample", :api_key => "sample")
    service.username = "    whitespace   "
    service.username.should == "whitespace"
  end
end  #describe SoftLayer#username=

describe SoftLayer::Service, "#api_key=" do
  it "should not allow you to set a nil or empty api_key" do
    service = SoftLayer::Service.new("SoftLayer_Account", :username => "sample", :api_key => "sample")
    lambda() {service.api_key = ""}.should raise_error
    lambda() {service.api_key = nil}.should raise_error
  end

  it "should strip whitespace" do
    service = SoftLayer::Service.new("SoftLayer_Account", :username => "sample", :api_key => "sample")
    service.api_key = "    fred  "
    service.api_key.should == "fred"
  end
end  #describe SoftLayer#api_key=

describe SoftLayer::Service, "#endpoint_url=" do
  it "should not allow you to set a nil or empty endpoint_url" do
    service = SoftLayer::Service.new("SoftLayer_Account", :username => "sample", :api_key => "sample", :endpoint_url => "http://someendpoint.softlayer.com")
    lambda() {service.endpoint_url = ""}.should raise_error
    lambda() {service.endpoint_url = nil}.should raise_error
  end

  it "should strip whitespace" do
    service = SoftLayer::Service.new("SoftLayer_Account", :username => "sample", :api_key => "sample", :endpoint_url => "http://someendpoint.softlayer.com")
    service.endpoint_url = "    http://someendpoint.softlayer.com  "
    service.endpoint_url.should == "http://someendpoint.softlayer.com"
  end
end  #describe SoftLayer#endpoint_url=

describe SoftLayer::Service, "#url_to_call_method" do
  it "should concatenate the method to the base url" do
    service = SoftLayer::Service.new("SoftLayer_Account", :username => "sample_username", :api_key => "blah")

    # make sure we've picked up the default API key (can be wrong if one of the other tests is misbehaving)
    service.endpoint_url.should == SoftLayer::API_PUBLIC_ENDPOINT

    call_url = service.url_to_call_method("getOpenTickets", nil);
    call_url.scheme.should == "https"
    call_url.host.should == "api.softlayer.com"
    call_url.path.should == "/rest/v3/SoftLayer_Account/getOpenTickets.json"
  end  #describe SoftLayer#url_to_call_method=
end

describe SoftLayer::Service, "#object_with_id" do
  it "should add an object to the URL for a request " do
      service = SoftLayer::Service.new("SoftLayer_Ticket", :username => "sample_username", :api_key => "blah")
      service.should_receive(:issue_http_request).with(URI.parse("https://api.softlayer.com/rest/v3/SoftLayer_Ticket/12345/getObject.json"), an_instance_of(Net::HTTP::Get))
      service.object_with_id(12345).getObject
  end
end

describe SoftLayer::Service, "#missing_method" do
  it "should translate unknown method into an api call" do
    service = SoftLayer::Service.new("SoftLayer_Account", :username => "sample_username", :api_key => "blah")
    service.should_receive(:call_softlayer_api_with_params).with(:getOpenTickets, nil, ["marshmallow"])
    response = service.getOpenTickets("marshmallow")
  end
end

describe SoftLayer::Service, "#http_request_for_method" do
  it "should only use HTTP GET for requests to the getObject method even if paramters are provided" do
    service = SoftLayer::Service.new("SoftLayer_Account", :username => "sample_username", :api_key => "blah")
    request = service.http_request_for_method(:getObject, URI.parse("https://api.softlayer.com/rest/v3/SoftLayer_Ticket/12345/getObject.json"), '{"simple" : "object"}')
    request.should be_a_kind_of(Net::HTTP::Get)
    request.should_not be_a_kind_of(Net::HTTP::Post)
  end
end

describe SoftLayer::Service, "#call_softlayer_api_with_params" do
  it "should issue an HTTP request for the given method" do
    service = SoftLayer::Service.new("SoftLayer_Account", :username => "sample_username", :api_key => "blah")
    service.should_receive(:issue_http_request).with(any_args())
    service.call_softlayer_api_with_params(:getObject, nil, []);
  end

  it "should include the object id in the url created" do
    service = SoftLayer::Service.new("SoftLayer_Ticket", :username => "sample_username", :api_key => "blah")
    service.should_receive(:issue_http_request).with(URI.parse("https://api.softlayer.com/rest/v3/SoftLayer_Ticket/12345/getObject.json"), an_instance_of(Net::HTTP::Get))
    service.call_softlayer_api_with_params(:getObject, SoftLayer::APIParameterFilter.new.object_with_id(12345), []);
  end

  it "should include the object mask in the url created" do
    expected_uri = "https://api.softlayer.com/rest/v3/SoftLayer_Account/getObject.json?objectMask=cow;duck;chicken;bull%20dog"

    service = SoftLayer::Service.new("SoftLayer_Account", :username => "sample_username", :api_key => "blah")
    service.should_receive(:issue_http_request).with(URI.parse(expected_uri), an_instance_of(Net::HTTP::Get))
    service.call_softlayer_api_with_params(:getObject, SoftLayer::APIParameterFilter.new.object_mask("cow  ", "  duck", "chicken", "bull dog"), []);
  end

  it "should return the parsed JSON when completing successfully" do
    service = SoftLayer::Service.new("SoftLayer_Account", :username => "sample_username", :api_key => "blah")
    service.should_receive(:issue_http_request).with(any_args()).and_return('{"successful":"Yipeee!", "array":[1,2,3], "bool":true}')
    result = service.getObject
    result.should == {"array"=>[1, 2, 3], "successful"=>"Yipeee!", "bool"=>true}
  end

  it "should raise an exception when completing unsuccessfully" do
    service = SoftLayer::Service.new("SoftLayer_Account", :username => "sample_username", :api_key => "blah")
    service.should_receive(:issue_http_request).with(any_args()).and_return('{"error":"Function (\"getSnargled\") is not a valid method for this service"}')
    lambda{ result = service.getSnargled }.should raise_error
  end
end

describe SoftLayer::Service, "#object_with_id" do
  it "should return an APIParameterFilter with itself as the target" do
    service = SoftLayer::Service.new("SoftLayer_Account", :username => "sample_username", :api_key => "blah")
    filter = service.object_with_id(12345)

    filter.should_not be_nil
    filter.target.should === service
    filter.server_object_id.should == 12345
  end
end

describe SoftLayer::Service, "#object_mask" do
  it "should return an APIParameterFilter with itself as the target" do
    service = SoftLayer::Service.new("SoftLayer_Account", :username => "sample_username", :api_key => "blah")
    filter = service.object_mask("fish", "cow", "duck")

    filter.should_not be_nil
    filter.target.should === service
    filter.server_object_mask.should == ["fish", "cow", "duck"]
  end
end

describe SoftLayer::Service, "#result_limit" do
  it "should return an APIParameterFilter with itself as the target" do
    service = SoftLayer::Service.new("SoftLayer_Account", :username => "sample_username", :api_key => "blah")
    filter = service.result_limit(10)

    filter.should_not be_nil
    filter.target.should === service
    filter.server_result_limit.should == 10
  end
end

describe SoftLayer::Service, "#result_offset" do
  it "should return an APIParameterFilter with itself as the target" do
    service = SoftLayer::Service.new("SoftLayer_Account", :username => "sample_username", :api_key => "blah")
    filter = service.result_offset(5)

    filter.should_not be_nil
    filter.target.should === service
    filter.server_result_offset.should == 5
  end
end

describe SoftLayer::Service, "#marshall_arguments_for_call" do
  service = SoftLayer::Service.new("SoftLayer_Account", :username => "sample_username", :api_key => "blah")
  request_body = service.marshall_arguments_for_call(["first", 3, {"cow" => "chicken"}])
  request_body.should == '{"parameters":["first",3,{"cow":"chicken"}]}'
end

describe SoftLayer::Service, " creating option proxies" do
  it "should allow me to create a proxy object with just the object_with_id option" do
    service = SoftLayer::Service.new("SoftLayer_Ticket", :username => "sample_username", :api_key => "blah")
    ticket_proxy = service.object_with_id(123456)

    ticket_proxy.server_object_id.should eql(123456)
    service.should_receive(:call_softlayer_api_with_params).with(any_args())
    ticket_proxy.getObject
  end

  it "should allow me to create a proxy object with just the object_mask option" do
    service = SoftLayer::Service.new("SoftLayer_Ticket", :username => "sample_username", :api_key => "blah")
    ticket_proxy = service.object_mask("fish", "cow", "duck")

    ticket_proxy.server_object_mask.should eql(["fish", "cow", "duck"])
    service.should_receive(:call_softlayer_api_with_params).with(any_args())
    ticket_proxy.getObject
  end

  it "should not modify an object_with_id proxy even if that proxy is used with a mask" do
    service = SoftLayer::Service.new("SoftLayer_Ticket", :username => "sample_username", :api_key => "blah")
    ticket_proxy = service.object_with_id(123456)

    service.should_receive(:issue_http_request).with(URI.parse("https://api.softlayer.com/rest/v3/SoftLayer_Ticket/123456/getObject.json?objectMask=fish;cow;duck"), an_instance_of(Net::HTTP::Get))
    ticket_proxy.object_mask("fish", "cow", "duck").getObject

    ticket_proxy.server_object_id.should eql(123456)
    ticket_proxy.server_object_mask.should be_nil
  end

  it "should not modify an object_mask proxy even if it is used with an object ID" do
    service = SoftLayer::Service.new("SoftLayer_Ticket", :username => "sample_username", :api_key => "blah")
    masked_proxy = service.object_mask("fish", "cow", "duck")

    service.should_receive(:issue_http_request).with(URI.parse("https://api.softlayer.com/rest/v3/SoftLayer_Ticket/123456/getObject.json?objectMask=fish;cow;duck"), an_instance_of(Net::HTTP::Get))
    masked_proxy.object_with_id(123456).getObject

    masked_proxy.server_object_id.should be_nil
    masked_proxy.server_object_mask.should eql(["fish", "cow", "duck"])
  end
end
