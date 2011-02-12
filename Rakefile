require 'rake'
require 'rubygems'
require 'erubis'

task :default => [:pages]

SRC = FileList['./**/*.h','./**/*.m','./**/*.mm']

desc 'generate documentation'
task :docs do
  SRC.each { |file| sh "docco #{file}" }
  puts "finished generating documentation"
end

desc 'generate docs toc'
task :toc => ['docs/', :docs] do
  docs = FileList['docs/*.html'].map { |f| f.gsub "docs/", ""}.find_all { |f| f != "index.html" }
  template = Erubis::Eruby.new File.new("index.erb").read
  files = docs.map { |d| { :url => d, :name => d.gsub(".html","") } }  

  File.open("docs/index.html","w") do |file|
    file << template.result(:files => files)
  end

  puts "generated table of contents"
end

desc 'Update gh-pages branch'
task :pages => ['docs/.git', :toc] do
  rev = `git rev-parse --short HEAD`.strip
  Dir.chdir 'docs' do
    sh "git add *.html *.css"
    sh "git commit -m 'rebuild pages from #{rev}'" do |ok,res|
      if ok 
        verbose { puts "gh-pages updated" }
        sh "git push origin gh-pages"
      end
    end
  end
end
