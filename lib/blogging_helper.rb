module Nanoc3::Helpers
  
  module Blogging
    
    # Az összes tartalom időrendi sorrendben
    def documents
      collect_items_with_type.sort_by do |a|
        time = a[:created_at]
        time.is_a?(String) ? Date.parse(time) : time
      end.reverse
    end
    
    # Saját írások összegyűjtése
    # a posztok és tutorialok könyvtárak tartalmai
    def posts
      collect_items_with_type.select do |item|
        if item[:type] == "post" or item[:type] == "tutorial"
          item
        end
      end.sort_by do |a|
        time = a[:created_at]
        time.is_a?(String) ? Date.parse(time) : time
      end.reverse
    end
    
    # Linkelt tartalmak
    def links
      collect_items_with_type.select do |item|
        if item[:type] == "link"
          item
        end
      end.sort_by do |a|
        time = a[:created_at]
        time.is_a?(String) ? Date.parse(time) : time
      end.reverse
    end
    
    def tutorials
      collect_items_with_type.select do |item|
        if item[:type] == "tutorial"
          item
        end
      end.sort_by do |a|
        time = a[:created_at]
        time.is_a?(String) ? Date.parse(time) : time
      end.reverse
    end
    
    # Az items kollekció típusokkal való ellátása 
    # Attól függően mely könyvtárban található:
    # 
    # Könyvtárnév | Típus
    # posztok | post típus
    # tutorialok | tutorial típus
    # 
    def collect_items_with_type
      @items.select do |item| 
        if item.identifier =~ /posztok/ 
          item[:type] = "post"
          item
        elsif item.identifier =~ /tutorialok\/.+/ 
          item[:type] = "tutorial"
          item
        elsif item.identifier =~ /linkek/ 
          item[:type] = "link"
          item
        end
      end
    end

    # Returns a sorted list of articles, i.e. items where the `kind`
    # attribute is set to `"article"`. Articles are sorted by descending
    # creation date, so newer articles appear before older articles.
    #
    # @return [Array] A sorted array containing all articles
    def sorted_articles
      require 'time'
      articles.sort_by do |a|
        time = a[:created_at]
        time.is_a?(String) ? Time.parse(time) : time
      end.reverse
    end
    
    def rss 
      buffer=""
      xml = Builder::XmlMarkup.new(:target=>buffer, :indent => 2)
      xml.instruct! :xml, :version => '1.0'
      xml.rss :version => "2.0", "xmlns:atom"=>"http://www.w3.org/2005/Atom" do
    	  xml.channel do
    			xml.title "Rubysztán"
    			xml.description "Minden ami Ruby."
    			xml.link @site.config[:base_url]
    			xml.atom :link, 
    											:href	=>	@site.config[:rss_url],
    											:rel	=>	"self",
    											:type	=>	"application/rss+xml"

    			documents.each do |doc|
    				xml.item do
    					xml.title doc[:title]
    					if doc[:type] == "link"
    					  xml.link doc[:url]
  					  else
    					  xml.link @site.config[:base_url]+doc.path
  					  end
    					xml.description doc.compiled_content
    					xml.pubDate Time.parse(doc[:created_at].to_s).rfc822()
    					xml.guid doc.path
    				end
    			end
    		end
  	  end
    	
    	buffer
    end
  end
end