#!/usr/bin/ruby
# Example custom processor for use with Marked <http://markedapp.com> and Jekyll _posts
# It's geared toward my personal set of plugins and tags, but you'll get the idea.
#   It turns
# {% img alignright /images/heythere.jpg 100 100 "Hey there" "hi" %}
#   into
# <img src="../images/heythere.jpg" alt="Hey there" class="alignright" title="hi" />
#
# replaces alignleft and alignright classes with appropriate style attribute
# ---
# Replaces {% gist XXXXX filename.rb %} with appropriate script tag
#
# Replace various other OctoPress, Jekyll and custom tags
#
# Processes final output with /usr/bin/kramdown (install kramdown as system gem: `sudo gem install kramdown`)
#
# Be sure to run *without* stripping YAML headers in Marked Behavior preferences.
 
# full path to image folder
full_image_path = "/Users/warthurton/prj/blog.warthurton/source/"
 
require "rubygems"
require "rubypants"
 
content = STDIN.read
 
#def e_sh(str)
#  str.to_s.gsub(/(?=[^a-zA-Z0-9_.\/\-\x7F-\xFF\n])/, '\\').gsub(/\n/, "'\n'").sub(/^$/, "''")
#end
 
parts = content.split(/^---\s*$/)
 
# Read YAML headers as needed before cutting them out
post_title = parts[1].match(/^title:\s+(\!\s*)?["']?(.*?)["']?\s*$/i)[2].strip
 
# Remove YAML
# content.sub!(/^---.*?---\s*$/m,'')
content = parts[2]
 
# Fenced code
content.gsub!(/^```(\w+)?\s*\n(.*?)\n```/m,"<pre><code class=\"\\1\">\\2</code></pre>")
 
# Update image urls to point to absolute file path
content.gsub!(/([\("])\/uploads\/(\d+\/.*?)([ \)"])/,"\\1#{full_image_path}\\2\\3")
 
# Process image Liquid tags
content.gsub!(/\{% img (.*?) %\}/) {|img|
  if img =~ /\{% img (\S.*\s+)?(https?:\/\/\S+|\/\S+|\S+\/\s+)(\s+\d+\s+\d+)?(\s+.+)? %\}/i
    classes = $1.strip if $1
    src = $2
    size = $3
    title = $4
 
    if /(?:"|')([^"']+)?(?:"|')\s+(?:"|')([^"']+)?(?:"|')/ =~ title
      title  = $1
      alt    = $2
    else
      alt    = title.gsub!(/"/, '&#34;') if title
    end
    classes.gsub!(/"/, '') if classes
  end
 
  style = %Q{ style="float:right;margin:0 0 10px 10px"} if classes =~ /alignright/
  style = %Q{ style="float:left;margin:0 10px 10px 0"} if classes =~ /alignleft/
 
  %Q{<img src="#{File.join(full_image_path,src)}" alt="#{alt}" class="#{classes}" title="#{title}"#{style} />}
}
 
# Process gist tags
content.gsub!(/\{% gist(.*?) %\}/) {|gist|
    if parts = gist.match(/\{% gist ([\d]*) (.*?)?%\}/)
      gist_id = parts[1].strip
      file = parts[2].nil? ? '' : "?file-#{parts[2].strip}"
      %Q{<script src="https://gist.github.com/#{gist_id}.js#{file}"></script>}
    else
      ""
    end
}
 
# Replace YouTube tags with a placeholder block
# <http://brettterpstra.com/2013/01/20/jekyll-tag-plugin-for-responsive-youtube-video-embeds/>
content.gsub!(/\{% youtube (\S+) ((\d+) (\d+) )?%\}/) {|vid|
  id = $1
  width, height = $2.nil? ? [640, 480] : [$3, $4] # width:#{width}px;height:#{height}px;
  style = "position:relative;padding-bottom:56.25%;padding-top:30px;height:0;overflow:hidden;background:#666;"
  %Q{<div class="bt-video-container" style="#{style}"><h3 style="text-align:center;margin-top:25%;">YouTube Video</h3></div>}
}
 
# HTML5 semantic pullquote plugin
content.gsub!(/\{% pullquote(.*?) %\}(.*)\{% endpullquote %\}/m) {|q|
  quoteblock = $2
  if quoteblock =~ /\{"\s*(.+?)\s*"\}/m
    quote = RubyPants.new($1).to_html
    "<span class='pullquote' data-pullquote='#{quote}'>#{quoteblock.gsub(/\{"\s*|\s*"\}/, '')}</span>"
  else
    quoteblock
  end
}
 
# Custom downloads manager plugin shiv
content.gsub!(/\{% download(.*?) %\}/,%Q{<div class="download"><h4>A download</h4><p class="dl_icon"><a href="#"><img src="/Volumes/Raptor/Users/ttscoff/Sites/dev/octopress/source/images/serviceicon.jpg"></a></p><div class="dl_body"><p class="dl_link"><a href="#">Download this download</a></p><p class="dl_description">Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</p><p class="dl_updated">Updated Today</p><p class="dl_info"><a href="#" title="More information on this download">More info&hellip;</a></p></div></div>})
 
content = "## #{post_title}\n\n#{content}"
 
#puts %x{echo #{e_sh content}|kramdown}
#puts %x{echo #{content}}
puts "#{content}"
