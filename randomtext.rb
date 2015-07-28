#!/usr/bin/env ruby -Ku

require 'rubygems'
require 'raingrams'
require 'maruku'

include Raingrams

# All (min,max) pairs need max > min

@model = BigramModel.build do |model|
  model.train_with_text File.new(File.expand_path('/Users/warthurton/.words/alice.txt'),'r').read
end

@model.refresh

# generates a paragraph with random sentences
# min = minimum sentences
# max = maximum sentences
def graf(min,max)
  # grab the paragraph and split it into words
  para = @model.random_paragraph({:min_sentences => min,:max_sentences => max }).split(' ')
  # add a random italics element
  em = (rand(para.count - 10) + 10)
  para[em] = "*#{para[em]}*"
  # add a random bold element
  strong = (rand(para.count - 10) + 10)
  # make sure they don't overlap
  strong = strong - 2 if strong == em
  para[strong] = "**#{para[strong]}**"
  # add a multi-word link
  link = (rand(para.count - 10) + 10)
  linkend = link + (rand(6) + 2)
  para[link] = "[#{para[link]}"
  para[linkend] = "#{para[linkend]}](http://dummy.com)"
  return para.join(' ')
end

# returns a random sentence, used in headlines
# min = minumum words, max = max words
def sentence(min,max)
  return @model.random_sentence.split(' ')[0..(rand(max - min)+min)].join(' ')
end

# returns a random list
# type = ul or ol
# min = minimum number of list items
# max = maximum number of list items
def list(type,min,max)
  list = '';
  prefix = type == "ol" ? " 1. " : " * "
  (rand(max - min) + min).times do
	list += prefix + @model.random_gram.to_s + "\n"
  end
  list += "\n\n"
  return list
end

# Sequentially builds an output variable (o)
# Chop this apart to make snippets as needed

# Level 1 headline
o = "# " + sentence(2,5) + "\n\n"
# 2 medium paragraphs
2.times do
  o += "#{graf(4,6)}\n\n"
end
# Level 2 headline
o += "## " + sentence(4,7) + "\n\n"
# 1 short paragraph
o += graf(2,4) + "\n\n"
# an unordered list
o += list('ul',5,8) + "\n\n"
# 1 more long paragraph
o += graf(6,8) + "\n\n"
# Level 3 header
o += "### " + sentence(5,9) + "\n\n"
# medium paragraph
o += graf(4,6) + "\n\n"
# ordered list
o += list('ol',5,8) + "\n\n"

# Process Markdown to HTML

# if you want just the Markdown
# delete the two lines below
# and replace with 'puts o'
doc = Maruku.new(o)
puts doc.to_html.gsub(/\/li>\n/,'/li>').gsub(/\/li><\/([uo])l/,"/li>\n</\\1l")
# the gsub is just to clean up maruku's double-spaced list output
