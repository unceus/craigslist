require 'coveralls'
Coveralls.wear!

require 'craigslist'

describe 'Craigslist' do
  let (:net) { Craigslist::Net }

  describe 'Net' do
    describe '#build_city_uri' do
      subject { net.build_city_uri city_path }
      let (:city_path) { "portland" }
      it { should eq 'http://portland.craigslist.org' }
    end

    describe '#build_county_uri' do
      subject { net.build_county_uri county_path }
      context "empty county_path" do
        let (:county_path) { nil }
        it { should be_nil }
      end
      context "non-empty county_path" do
        let (:county_path) { 'atl' }
        it { should eq "#{county_path}/" }
      end
    end

    describe '#build_uri' do
      subject { net.build_uri city_path, county_path, category_path, options }
      let (:city_path) { :portland }
      let (:county_path) { nil }
      let (:category_path) { :bia }
      let (:options) { {} }

      context "minimum required parameters" do
        it { should eq "http://portland.craigslist.org/bia/" }
      end
      context "county" do
        let (:county_path) { :wsc }
        it { should eq "http://portland.craigslist.org/wsc/bia/" }
      end
      context "query" do
        before { options.merge!( query: 'fixie' ) }
        it { should eq "http://portland.craigslist.org/search/bia/?query=fixie" }
      end
      context "min_ask" do
        before { options.merge!( min_ask: 500 ) }
        it { should eq "http://portland.craigslist.org/search/bia/?minAsk=500" }
      end
      context "max_ask" do
        before { options.merge!( max_ask: 5000 ) }
        it { should eq "http://portland.craigslist.org/search/bia/?maxAsk=5000" }
      end
      context "has_image" do
        context "zero" do
          before { options.merge!( has_image: 0 ) }
          it { should eq "http://portland.craigslist.org/bia/" }
        end
        context "non-zero" do
          before { options.merge!( has_image: 1 ) }
          it { should eq "http://portland.craigslist.org/search/bia/?hasPic=1" }
        end
      end
      context "bedrooms" do
        before { options.merge!( bedrooms: 5 ) }
        it { should eq "http://portland.craigslist.org/search/bia/?bedrooms=5" }
      end
      context "neighborhoods" do
        before { options.merge!( neighborhoods: [2, 1] ) }
        it { should eq "http://portland.craigslist.org/search/bia/?nh=2&nh=1" }
      end
    end
  end
end
