require 'uri'
require 'open-uri'
require 'rss'

class RssAnalyzer < Analyzer
  DataSource = Struct.new(:url)

  # Wraps RSS::Rss::Channel::Item
  class ExternalRssTicket < Hash
    attr_reader :feed_url

    def initialize(item, feed_url)
      super()
      @item = item
      @feed_url = feed_url
    end

    def title
      @item.title
    end

    def url
      @item.link
    end

    def last_update_time
      @item.date
    end

    def external_id
      url
    end
  end

  # Wraps RSS::Atom::Feed::Entry
  class ExternalAtomTicket < Hash
    attr_reader :feed_url

    def initialize(item, feed_url)
      super()
      @item = item
      @feed_url = feed_url
    end

    def title
      @item.title.content
    end

    def url
      @item.links[0].href
    end

    def last_update_time
      @item.updated.content
    end

    def external_id
      url
    end
  end

protected
  def support_source_class
    RssSupportSource
  end

  def get_data_sources
    data_sources = {}
    @support_sources.each do |support_source|
      key = support_source.rss_url
      data_sources[key] ||= DataSource.new(support_source.rss_url)
    end
    data_sources.values
  end

  def fetch_unanswered_external_tickets
    feeds = fetch_feeds_for_all_data_sources
    feeds.reject! { |feed| feed.items.empty? }
    external_tickets = fetch_external_tickets_for_feeds(feeds)

    # At the moment of writing, we only use RssSupportSource for Stack Overflow.
    # The following code fetches each Stack Overflow post and checks
    # whether the answer is accepted.
    result = []
    external_tickets.each do |external_ticket|
      future = execute_future do
        response = RestClient.get(external_ticket.url)
        if external_ticket_is_answered?(external_ticket, response.body)
          nil
        else
          external_ticket
        end
      end
      result << future
    end

    result.map! { |future| future.value! }
    result.compact!
    result
  end

  def id_for_external_ticket(external_ticket)
    external_ticket.external_id
  end

  def different_support_sources_see_different_tickets?
    false
  end

  def synchronize_internal_ticket(internal_ticket, external_ticket)
    super

    internal_ticket.title = external_ticket.title
    internal_ticket.display_id = nil
    internal_ticket.external_last_update_time = external_ticket.last_update_time
  end

  def support_sources_eligible_for_external_ticket(external_ticket)
    @support_sources.find_all do |support_source|
      support_source.rss_url == external_ticket.feed_url
    end
  end

private
  def fetch_feeds_for_all_data_sources
    feeds = []
    @data_sources.each do |data_source|
      feed = execute_future do
        f = open(data_source.url) do |io|
          RSS::Parser.parse(io)
        end
        f.instance_variable_set(:@data_source, data_source)
        f
      end
      feeds << feed
    end
    feeds.map! { |feed| feed.value! }
    feeds
  end

  def fetch_external_tickets_for_feeds(feeds)
    external_tickets = []
    feeds.each do |feed|
      data_source = feed.instance_variable_get(:@data_source)
      external_ticket_class = infer_external_ticket_class(feed.items[0])
      feed.items.each do |item|
        external_tickets << external_ticket_class.new(item, data_source.url)
      end
    end
    external_tickets
  end

  def infer_external_ticket_class(rss_parser_item)
    if rss_parser_item.is_a?(RSS::Rss::Channel::Item)
      ExternalRssTicket
    elsif rss_parser_item.is_a?(RSS::Atom::Feed::Entry)
      ExternalAtomTicket
    else
      raise "Unsupport RSS format: #{rss_parser_item.class}"
    end
  end

  def external_ticket_is_answered?(external_ticket, body)
    doc = Nokogiri.HTML(body)
    !(doc / '.vote-accepted-on').empty?
  end
end
