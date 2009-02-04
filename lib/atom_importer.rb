begin
  require 'atom'
rescue LoadError, NameError
  warn "AtomImporter extension requires ratom."
  exit 1
end

class AtomImporter
  attr_accessor :feed
  
  def initialize(filename)
    self.feed = Atom::Feed.new(File.read(filename))
  end
  
  def run
    create_blog_structure
    import_entries
  end
  
  def create_blog_structure
    create_or_find_homepage
    create_or_find_blog_page
  end
  
  def import_entries
    feed.entries.each(&method(:import_entry))
  end
  
  def import_entry(entry)
    page = blog.children.find_or_initialize_by_title(entry.title)
    page.breadcrumb = entry.title
    page.slug = entry.title.to_slug
    page.status = Status[:published]
    page.published_at = entry.published
    page.parts.build(:name => "body", :content => entry.content.value)
    page.save
  end
  
  private
    def homepage
      @homepage ||= Page.find_by_parent_id(nil) || Page.new
    end
    
    def blog
      @blog ||= @homepage.children.find_or_initialize_by_slug('blog')
    end
  
    def create_or_find_homepage
      homepage.slug = '/'
      homepage.breadcrumb = @homepage.title = feed.title
      homepage.status = Status[:published]
      homepage.save!
    end
    
    def create_or_find_blog_page
      blog.breadcrumb ||= (@blog.title ||= "Blog")
      blog.class_name = "ArchivePage"
      blog.status = Status[:published]
      blog.save!
    end
    
end