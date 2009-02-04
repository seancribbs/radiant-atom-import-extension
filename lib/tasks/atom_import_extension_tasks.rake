namespace :radiant do
  namespace :extensions do
    namespace :atom_import do
      
      desc "Imports an Atom XML file into pages under /articles. Specify ATOM environment variable to point to the file."
      task :run => :environment do
        AtomImporter.new(ENV["ATOM"]).run
      end
      
      desc "Runs the migration of the Atom Import extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          AtomImportExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          AtomImportExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Atom Import to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        puts "Copying assets from AtomImportExtension"
        Dir[AtomImportExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(AtomImportExtension.root, '')
          directory = File.dirname(path)
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end  
    end
  end
end
