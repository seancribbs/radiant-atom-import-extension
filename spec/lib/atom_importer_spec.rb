require File.dirname(__FILE__) + '/../spec_helper'

describe AtomImporter do
  before :each do
    Page.delete_all
    @importer = AtomImporter.new(File.dirname(__FILE__) + '/../fixtures/sean.xml')
  end
  
  it "should load the Atom XML from a file" do
    @importer.feed.should be
  end

  describe "creating the blog structure" do
    describe "the homepage" do
      before :each do
        @importer.create_blog_structure
        @homepage = Page.find_by_parent_id(nil)
      end
      
      it "should be created" do
        @homepage.should be
      end
      
      it "should have the title of the Atom feed as its title" do
        @homepage.title.should == "Sean Cribbs"
      end
      
      it "should be published" do
        @homepage.should be_published
      end
    end
    
    describe "the articles page" do
      before :each do
        @importer.create_blog_structure
        @homepage = Page.find_by_parent_id(nil)
        @blog = Page.find_by_parent_id(@homepage.id)
      end

      it "should be created" do
        @blog.should be
      end
      
      it "should be at the /blog url" do
        @blog.parent.should == @homepage
        @blog.slug.should == 'blog'
      end
      
      it "should be an Archive page" do
        @blog.should be_instance_of(ArchivePage)
      end
      
      it "should be published" do
        @blog.should be_published
      end
    end
  end
  
  describe "importing entries" do
    before :each do
      @importer.run
      @blog = Page.find_by_slug('blog')
    end
    
    it "should create a page for every entry" do
      @blog.children.size.should == 10
    end
  end
  
  describe "importing an entry" do
    before :each do
      @importer.create_blog_structure
      @entry = @importer.feed.entries.first
      @importer.import_entry(@entry)
    end
    
    it "should create a page with the same title" do
      Page.find_by_title(@entry.title).should be
    end
    
    describe "the created page" do
      before :each do
        @page = Page.find_by_title(@entry.title)
      end
      
      it "should be a child of the blog page" do
        @page.parent.slug.should == 'blog'
      end
      
      it "should be published" do
        @page.should be_published
      end
      
      it "should have the published date of the entry" do
        @page.published_at.should == @entry.published
      end
      
      it "should have the content as the body part" do
        @page.part(:body).content.should == @entry.content.value
      end
    end
  end
end