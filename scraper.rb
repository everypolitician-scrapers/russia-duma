#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
require 'scraped_page_archive/open-uri'
# require 'open-uri/cached'

# OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.css('#lists_list_elements_35').xpath('.//tr[td]').each do |tr|
    tds = tr.css('td')
    link = tds[1].css('a/@href').text
    raise "No link" if link.empty?
    link = URI.join(url, link).to_s

    data = {
      id: link.split('/').last,
      name: tds[1].text.tidy,
      faction: tds[2].text.sub('Фракция ','').tidy,
      region: tds[4].text.tidy,
      image: tds[0].css('img/@src').text,
      term: 6,
      source: link,
    }
    data[:image] = URI.join(url, data[:image]).to_s unless data[:image].to_s.empty?
    # puts data
    ScraperWiki.save_sqlite([:id, :term], data)
  end
end

scrape_list('http://www.duma.gov.ru/structure/deputies/?letter=%D0%92%D1%81%D0%B5')
