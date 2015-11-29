# Copyright 2007-2015 Mitchell mitchell.att.foicica.com. See LICENSE.

require 'rdoc/generator'

##
# Textadept format for RDoc.
# This class is used by RDoc to create an Textadept autocompletions and
# documentation for Ruby with a "fake" ctags file and an api file.
# In addition to the normal ctags kinds for Ruby, the kind 'C' is recognized as
# a constant and 'a' as an attribute.
#
# Requires Ruby 1.9.
#
# Install this file to your `rdoc/generator/` folder and add it to the bottom of
# `rdoc/rdoc.rb`.
#
# Usage: rdoc -f textadept [files]
# Two files are generated in the output directory: `tags` and `api`.
class RDoc::Generator::TEXTADEPT
  CTAGS_FMT = "%s\t_\t0;\"\t%s\t%s\n"

  RDoc::RDoc.add_generator self

  def self.for(options) new(options) end
  def initialize(options)
    @options = options
    @generated = {}
    @tags = File.new(options.op_dir + '/tags', 'wb')
    @api = File.new(options.op_dir + '/api', 'wb')
  end

  ##
  # Called by RDoc to process context objects.
  def generate(toplevels)
    RDoc::TopLevel.all_classes_and_modules.each { |c| process_context c }
    @tags.close
    @api.close
  end

  ##
  # Process the context.
  # @param context The RDoc context to process.
  def process_context(context)
    ext_fields = Array.new

    # Determine inheritence (if any).
    inherits = Array.new
    superclass = context.superclass unless context.module?
    inherits << superclass unless superclass.nil? or superclass !~ /^[\w:]+$/
    context.includes.each { |i| inherits << i.full_name }
    inherits << 'Object' unless inherits.include?('Object')
    ext_fields << 'inherits:' + inherits.join(',') unless inherits.empty?

    # Determine the parent class/module (if any).
    parent = (context.full_name.scan(/^.+::/).first || '')[0...-2]
    #ext_fields << 'class:' + parent unless parent.empty?

    # Write the ctag.
    write_tag(@tags, context.full_name, context.module? ? 'm' : 'c', ext_fields)
    write_tag(@tags, context.name, 'C', 'class:' + parent) unless parent.empty?

    # Write ctags for all methods.
    context.each_method do |m|
      next if m.name !~ /^\w/
      ext_fields = 'class:' + context.full_name
      ext_fields += ',' + inherits.join(',') unless inherits.empty?
      write_tag(@tags, m.name, 'f', ext_fields)
      write_method_apidoc(@api, context, m)
    end

    # Write ctags for all constants.
    context.each_constant do |c|
      ext_fields = 'class:' + context.full_name
      ext_fields = '' if context.full_name.to_sym == :Object
      write_tag(@tags, c.name, 'C', ext_fields)
    end

    # Write ctags for all attributes.
    context.each_attribute do |a|
      write_tag(@tags, a.name, 'a', 'class:' + context.full_name)
    end
  end

  ##
  # Writes a ctag.
  # @param file The file to write to.
  # @param name The name of the tag.
  # @param k The kind of ctag. This generator uses 5 kinds: m Module, c Class,
  # f Method, C Constant, a Attribute.
  # @param ext_fields The ext_fields for the ctag.
  def write_tag(file, name, k, ext_fields)
    ext_fields = ext_fields.join("\t") if ext_fields.class == Array
    file << sprintf(CTAGS_FMT, name, k, ext_fields)
  end

  ##
  # Returns a formatted comment.
  # @param comment The comment to format.
  def format(comment)
    return comment.gsub(/^\s*#+/, '').gsub(/<\/?code>/, '`').
                   gsub("\\n", "\\\\\\\\n")
  end

  ##
  # Write a method apidoc.
  # @param file The file to write to.
  # @param c The RDoc class object.
  # @param m The RDoc method object.
  def write_method_apidoc(file, c, m)
    doc = %x(
fmt -s -w 80 <<"EOF"
#{c.full_name + '.' + m.name + m.params}
#{format(m.comment)}
EOF).gsub("\n", "\\\\n")
    file << m.name + ' ' + doc << "\n"
  end
end
