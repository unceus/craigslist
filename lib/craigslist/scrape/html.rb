module Craigslist::Scrape::HTML
  class << self
    def scrape_data_from_page uri_data, max_results, options
      results = []
      get_uris_for_fetch(uri_data, max_results, options).each do |uri|
        doc = Nokogiri::HTML(open(uri))

        doc.css('p.row').each do |node|
          results << scrape_data_from_row(node)
          break if results.length == max_results
        end
      end
      results
    end

    def get_uris_for_fetch uri_data, max_results, options
      uris = []
      for i in 0..(([max_results - 1, -1].max) / 100)
        uris.push get_uri_for_fetch(uri_data, options, i)
      end
      uris
    end

    private
    def scrape_data_from_row row
      result = {}

      title = row.at_css('.pl a')
      result['text'] = title.text.strip
      result['href'] = title['href']

      if price = row.at_css('.l2 .price')
        result['price'] = price.text.strip
      else
        result['price'] = nil
      end

      if row['data-latitude']
        result['latitude'] = row['data-latitude']
      end

      if row['data-longitude']
        result['longitude'] = row['data-longitude']
      end

      info = row.at_css('.l2 .pnr')

      if location = info.at_css('small')
        # Remove brackets
        result['location'] = location.text.strip[1..-2].strip
      else
        result['location'] = nil
      end

      if listed_at = row.at_css('.date')
        result['listed_at'] = listed_at
      end

      attributes = info.at_css('.px').text
      result['has_img'] = attributes.include?('img') || attributes.include?('pic')

      result
    end

    def get_uri_for_fetch uri_data, options, page_number
      page_param = page_number < 0 ? nil : page_number * 100
      Craigslist::Net::build_uri(
        uri_data[:city],
        uri_data[:county],
        uri_data[:category_path],
        options,
        page_param
      )
    end
  end
end
