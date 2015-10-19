#! /usr/bin/env perl
use strict;

#-----------------------------------------------------------------------------
#-                                                                          --
#-                         GNAT COMPILER COMPONENTS                         --
#-                                                                          --
#-                             G N A T H T M L                              --
#-                                                                          --
#-                            $Revision: 1.34.1.13 $                             --
#-                                                                          --
#-          Copyright (C) 1998 Free Software Foundation, Inc.               --
#-                                                                          --
#- GNAT is free software;  you can  redistribute it  and/or modify it under --
#- terms of the  GNU General Public License as published  by the Free Soft- --
#- ware  Foundation;  either version 2,  or (at your option) any later ver- --
#- sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
#- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
#- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License --
#- for  more details.  You should have  received  a copy of the GNU General --
#- Public License  distributed with GNAT;  see file COPYING.  If not, write --
#- to  the Free Software Foundation,  59 Temple Place - Suite 330,  Boston, --
#- MA 02111-1307, USA.                                                      --
#-                                                                          --
#- GNAT is maintained by Ada Core Technologies Inc (http://www.gnat.com).   --
#-                                                                          --
#-----------------------------------------------------------------------------

## This script converts an Ada file (and its dependency files) to Html.
## Keywords, comments and strings are color-hilighted. If the cross-referencing
## information provided by Gnat (when not using the -gnatx switch) is found,
## the html files will also have some cross-referencing features, i.e. if you
## click on a type, its declaration will be displayed.
##
## To find more about the switches provided by this script, please use the
## following command :
##     perl gnathtml.pl -h
## You may also change the first line of this script to indicates where Perl is
## installed on your machine, so that you can just type
##     gnathtml.pl -h
##
## Unless you supply another directory with the -odir switch, the html files
## will be saved saved in a html subdirectory


### Print help if necessary
sub print_usage
{
  print "Usage is:\n";
  print "  $0 [switches] main_file[.adb] main_file2[.adb] ...\n";
  print "     -83       : Use Ada83 keywords only (default is Ada95)\n";
  print "     -cc color : Choose the color for comments\n";
  print "     -d        : Convert also the files which main_file depends on\n";
  print "     -D        : same as -d, also looks for files in the standard library\n";
  print "     -f        : Include cross-references for local entities too\n";
  print "     -h        : Print this help page\n";
  print "     -lnb      : Display line numbers every nb lines\n";
  print "     -Idir     : Specify library/object files search path\n";
  print "     -odir     : Name of the directory where the html files will be\n";
  print "                 saved. Default is 'html/'\n";
  print "     -pfile    : Use file as a project file (.adp file)\n";
  print "     -sc color : Choose the color for symbol definitions\n";
  print "     -Tfile    : Read the name of the files from file rather than the\n";
  print "                 command line\n";
  print "This program attempts to generate an html file from an Ada file\n";
  exit;
}

### Parse the command line
our ($ada83_mode)    = 0;
our ($prjfile)       = "";
our (@list_files)    = ();
our ($line_numbers)  = 0;
our ($dependencies)  = 0;
our ($standard_library) = 0;
our ($output_dir)    = "html";
our ($xref_variable) = 0;
our (@search_dir)    = ('.');
our ($tab_size)      = 8;
our ($comment_color) = "green";
our ($symbol_color)  = "red";

while ($_ = shift @ARGV)
{
  /^-83$/  &&   do { $ada83_mode = 1; };
  /^-d$/   &&   do { $dependencies = 1; };
  /^-D$/   &&   do { $dependencies = 1;
		     $standard_library = 1; };
  /^-f$/   &&   do { $xref_variable = 1; };
  /^-h$/   &&   do { &print_usage; };
  /^[^-]/  &&   do { $_ .= ".adb" if (! /\.ad[bs]$/);
		     push (@list_files, $_); };

  if (/^-o\s*(.*)$/)
  {
    $output_dir = ($1 eq "") ? shift @ARGV : $1;
    chop $output_dir if ($output_dir =~ /\/$/);
    &print_usage if ($output_dir =~ /^-/ || $output_dir eq "");
  }

  if (/^-T\s*(.*)$/)
  {
      my ($source_file) = ($1 eq "") ? shift @ARGV : $1;
      local (*SOURCE);
      open (SOURCE, "$source_file") || die "file not found: $source_file";
      while (<SOURCE>) {
	  my @files = split;
	  foreach (@files) {
	      $_ .= ".adb" if (! /\.ad[bs]$/);
	      push (@list_files, $_);
	  }
      }
  }

  if (/^-cc\s*(.*)$/)
  {
      $comment_color = ($1 eq "") ? shift @ARGV : $1;
      &print_usage if ($comment_color =~ /^-/ || $comment_color eq "");
  }

  if (/^-sc\s*(.*)$/)
  {
      $symbol_color = ($1 eq "") ? shift @ARGV : $1;
      &print_usage if ($symbol_color =~ /^-/ || $symbol_color eq "");
  }

  if (/^-I\s*(.*)$/)
  {
    push (@search_dir, ($1 eq "") ? scalar (shift @ARGV) : $1);
  }

  if (/^-p\s*(.*)$/)
  {
    $prjfile = ($1 eq "") ? shift @ARGV : $1;
    &print_usage if ($prjfile =~ /^-/ || $prjfile eq "");
  }

  if (/^-l\s*(.*)$/)
  {
    $line_numbers = ($1 eq "") ? shift @ARGV : $1;
    &print_usage if ($line_numbers =~ /^-/ || $line_numbers eq "");
  }
}

&print_usage if ($#list_files == -1);
our (@original_list) = @list_files;


## This regexp should match all the files from the standard library (and only them)
## Note that at this stage the '.' in the file names has been replaced with __
our $standard_file_regexp="^([agis]-|ada__|gnat__|system__|interface__).*\$";


our (@src_dir) = ();
our (@obj_dir) = ();

if ($standard_library) {
    open (PIPE, "gnatls -v | ");
    my ($mode) = "";
    while (defined ($_ = <PIPE>)) {
	chop;
	s/^\s+//;
	$_ = './' if (/<Current_Directory>/);
	next if (/^$/);

	if (/Source Search Path:/) {
	    $mode = 's';
	}
	elsif (/Object Search Path:/) {
	    $mode = 'o';
	}
	elsif ($mode eq 's') {
	    push (@src_dir, $_);
	}
	elsif ($mode eq 'o') {
	    push (@obj_dir, $_);
	}
    }
    close (PIPE);
}
else
{
    push (@src_dir, "./");
    push (@obj_dir, "./");
}


foreach (@list_files) {
  my ($dir) = $_;
  $dir =~ s/\/([^\/]+)$//;
  push (@src_dir, $dir. '/');
  push (@obj_dir, $dir. '/');
}

### Defines and compiles the Ada key words :
our (@Ada_keywords) = ('abort', 'abs', 'accept', 'access', 'all', 'and',
			 'array', 'at', 'begin', 'body', 'case', 'constant',
			 'declare', 'delay', 'delta', 'digits', 'do', 'else',
			 'elsif', 'end', 'entry', 'exception', 'exit', 'for',
			 'function', 'generic', 'goto', 'if', 'in', 'is',
			 'limited', 'loop', 'mod', 'new', 'not', 'null', 'of',
			 'or', 'others', 'out', 'package', 'pragma', 'private',
			 'procedure', 'raise', 'range', 'record', 'rem',
			 'renames', 'return', 'reverse', 'select', 'separate',
			 'subtype', 'task', 'terminate', 'then', 'type',
			 'until', 'use', 'when', 'while', 'with', 'xor');
our (@Ada95_keywords) = ('abstract', 'aliased', 'protected', 'requeue',
			'tagged');

our (%keywords) = ();
grep (++ $keywords{$_}, @Ada_keywords);
grep (++ $keywords{$_}, @Ada95_keywords) unless ($ada83_mode);

### Symbols declarations for the current file
### format is   (line_column => 1, ...)
our (%symbols);

### Symbols usage for the current file
### format is  ($adafile#$line_$column => $htmlfile#$linedecl_$columndecl, ...)
our (%symbols_used);

### the global index of all symbols
### format is  ($name => [[file, line, column], [file, line, column], ...])
our (%global_index);

#########
##  This function create the header of every html file.
##  These header is returned as a string
##  Params:  - Name of the Ada file associated with this html file
#########
sub create_header
{
  my ($adafile) = shift;
  my $string = "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01//EN\">\n"
	. "<HTML>\n"
	. "<HEAD>\n"
	. "<TITLE>$adafile</TITLE>\n"
	. "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">\n"
	. "<style type=\"text/css\">\n"
	. "*.comment {\n"
	. "	color: $comment_color;\n"
	. "}\n"
	. "*.symbol {\n"
	. "	color: $symbol_color;\n"
	. "}\n"
	. "</style>\n"
	. "</HEAD>\n"
	. "<BODY>\n";

  if ($adafile ne "")
  {
    $string .= "<HR><DIV style=\"text-align:center\"><H1> File : $adafile "
	. "</H1></DIV><HR>\n<PRE>";
  }
  return $string;
}

#########
##  Protect a string (or character) from the Html parser
##  Params: - the string to protect
##  Out:    - the protected string
#########
sub protect_string
{
    my ($string) = shift;
    $string =~ s/&/&amp;/g;
    $string =~ s/</&lt;/g;
    $string =~ s/>/&gt;/g;
    return $string;
}

#########
##  This function creates the footer of the html file
##  The footer is returned as a string
##  Params :  - Name of the Ada file associated with this html file
#########
sub create_footer
{
  my ($adafile) = shift;
  my ($string) = "";
  $string = "</PRE>" if ($adafile ne "");
  return $string . "</BODY></HTML>\n";
}

#########
##  This function creates the string to use for comment output
##  Params :  - the comment itself
#########
sub output_comment
{
  my ($comment) = &protect_string (shift);
  return "<span class=\"comment\"><EM>--$comment</EM></span>";
}

sub tag($$)
{
  my ($lineno) = shift;
  my ($column) = shift;
  return "ref_$lineno\_$column";
}

# beginning of output_symbol()
sub before_symbol($$)
{
  my ($lineno) = shift;
  my ($column) = shift;
  return "<span class=\"symbol\"><A NAME=\"" . tag($lineno, $column) . "\"";
}

# ending of output_symbol()
sub after_symbol()
{
  return "</A></span>";
}

########
##  This function creates the string to use for symbols output
##  Params :  - the symbol to output
##            - the current line
##            - the current column
########
sub output_symbol
{
  my ($symbol) = &protect_string (shift);
  my ($lineno) = shift;
  my ($column) = shift;
  return before_symbol($lineno, $column) . ">" . $symbol . after_symbol();
}

########
##  This function creates the string to use for keyword output
##  Params :  - the keyword to output
########
sub output_keyword
{
  my ($keyw) = shift;
  return "<b>$keyw</b>";
}

########
##  This function outputs a line number
##  Params :  - the line number to generate
########
sub output_line_number
{
  my ($no) = shift;
  if ($no != -1)
  {
    return "<EM><FONT SIZE=-1>" . sprintf ("%4d ", $no) . "</FONT></EM>";
  }
  else
  {
    return "<FONT SIZE=-1>     </FONT>";
  }
}

########
##  Converts a character into the corresponding Ada type
##  This is based on the ali format (see lib-xref.adb) in the GNAT sources
##  Note: 'f' or 'K' should be returned in case a link from the body to the
##        spec needs to be generated.
##  Params : - the character to convert
########
sub to_type
{
  my ($char) = shift;
  $char =~ tr/a-z/A-Z/;

  return 'array'                              if ($char eq 'A');
  return 'boolean'                            if ($char eq 'B');
  return 'class'                              if ($char eq 'C');
  return 'decimal'                            if ($char eq 'D');
  return 'enumeration'                        if ($char eq 'E');
  return 'floating point'                     if ($char eq 'F');
  return 'signed integer'                     if ($char eq 'I');
  # return 'generic package'                    if ($char eq 'K');
  return 'block'                              if ($char eq 'L');
  return 'modular integer'                    if ($char eq 'M');
  return 'enumeration literal'                if ($char eq 'N');
  return 'ordinary fixed point'               if ($char eq 'O');
  return 'access'                             if ($char eq 'P');
  return 'label'                              if ($char eq 'Q');
  return 'record'                             if ($char eq 'R');
  return 'string'                             if ($char eq 'S');
  return 'task'                               if ($char eq 'T');
  return 'f'                                  if ($char eq 'U');
  return 'f'                                  if ($char eq 'V');
  return 'exception'                          if ($char eq 'X');
  return 'entry'                              if ($char eq 'Y');
  return "$char";
}

########
##  Changes a file name to be http compatible
########
sub http_string
{
  my ($str) = shift;
  $str =~ s/\//__/g;
  $str =~ s/\\/__/g;
  $str =~ s/:/__/g;
  $str =~ s/\./__/g;
  return $str;
}


########
##  Creates the complete file-name, with directory
##  use the variables read in the .prj file
##  Params : - file name
##  RETURNS : the relative path_name to the file
########
sub get_real_file_name
{
  my ($filename) = shift;
  my ($path) = $filename;

  foreach (@src_dir)
  {
      if ( -r "$_$filename")
      {
	  $path = "$_$filename";
	  last;
      }
  }

  $path =~ s/^\.\///;
  return $path if (substr ($path, 0, 1) ne '/');

  ## We want to return relative paths only, so that the name of the HTML files
  ## can easily be generated
  my ($pwd) = `pwd`;
  chop ($pwd);
  my (@pwd) = split (/\//, $pwd);
  my (@path) = split (/\//, $path);

  while (@pwd)
  {
    if ($pwd [0] ne $path [0])
    {
      return '../' x ($#pwd + 1) . join ("/", @path);
    }
    shift @pwd;
    shift @path;
  }
  return join ('/', @path);
}

########
##  Reads and parses .adp files
##  Params : - adp file name
########
sub parse_prj_file
{
  my ($filename) = shift;
  my (@src) = ();
  my (@obj) = ();

  print "Parsing project file : $filename\n";

  open (PRJ, $filename) || do { print " ... sorry, file not found\n";
				return;
			      };
  while (<PRJ>)
  {
    chop;
    s/\/$//;
    push (@src, $1 . "/") if (/^src_dir=(.*)/);
    push (@obj, $1 . "/") if (/^obj_dir=(.*)/);
  }
  unshift (@src_dir, @src);
  unshift (@obj_dir, @obj);
  close (PRJ);
}

########
##  Finds a file in the search path
##  Params  : - the name of the file
##  RETURNS : - the directory/file_name
########
sub find_file
{
  my ($filename) = shift;

  foreach (@search_dir) {
    if (-f "$_/$filename") {
      return "$_/$filename";
    }
  }
  return $filename;
}

########
##  Inserts a new reference in the list of references
##  Params: - Ref as it appears in the .ali file ($line$type$column)
##          - Current file for the reference
##          - Current offset to be added from the line (handling of
##            pragma Source_Reference)
##          - Current entity reference
##  Modifies: - %symbols_used
########
sub create_new_reference
{
    my ($ref) = shift;
    my ($lastfile) = shift;
    my ($offset) = shift;
    my ($currentref) = shift;
    my ($refline, $type, $refcol);

    ## Do not generate references to the standard library files if we
    ## do not generate the corresponding html files
    return if (! $standard_library && $lastfile =~ /$standard_file_regexp/);

    ($refline, $type, $refcol) = /(\d+)(.)(\d+)/;
    $refline += $offset;


    ## If we have a body, then we only generate the cross-reference from
    ## the spec to the body if we have a subprogram (or a package)


    if ($type eq "b")
#	&& ($symbols {$currentref} eq 'f' || $symbols {$currentref} eq 'K'))
    {
	my ($cref_file, $cref) = ($currentref =~ /([^\#]+).htm\#(.+)/);
	my $tag = "$lastfile.htm#" . tag($refline, $refcol);

	$symbols_used {"$cref_file#$cref"} = $tag;
	$symbols_used {"$lastfile#" . tag($refline, $refcol)} = $currentref;
	$symbols {$tag} = "body";
    }

    ## Do not generate cross-references for "e" and "t", since these point to the
    ## semicolon that terminates the block -- irrelevant for gnathtml
    ## "p" is also removed, since it is used for primitive subprograms
    ## "i" is removed since it is used for implicit references

    elsif ($type ne "e" && $type ne "t" && $type ne "p" && $type ne "i")
    {
	$symbols_used {"$lastfile#" . tag($refline, $refcol)} = $currentref;
    }
}

########
##  Parses the ali file associated with the current Ada file
##  Params :  - the complete ali file name
########
sub parse_ali
{
  my ($filename) = shift;
  my ($currentfile);
  my ($currentref);
  my ($lastfile);

  # A    file | line type column      reference
  my ($reference) = "(?:(?:\\d+\\|)?\\d+.\\d+|\\w+)";

  # The following variable is used to represent the possible xref information
  # output by GNAT when -gnatdM is used. It includes renaming references, and
  # references to the parent type.

  my ($typeref) = "(?:=$reference|<$reference>|\\{$reference\\}|\\($reference\\))?";

  # The beginning of an entity declaration line in the ALI file
  my ($decl_line) = "^(\\d+)(.)(\\d+)[ *]([\\w\\d.-]+|\"..?\")$typeref\\s+(\\S.*)?\$";

  # Contains entries of the form  [ filename source_reference_offset]
  # Offset needs to be added to the lines read in the cross-references, and are
  # used when the source comes from a gnatchop-ed file. See lib-write.ads, lines
  # with ^D in the ALI file.
  my (@reffiles) = ();

  open (ALI, &find_file ($filename)) || do {
    print "no ", &find_file ($filename), " file...\n";
    return;
  };
  my (@ali) = <ALI>;
  close (ALI);

  undef %symbols;
  undef %symbols_used;

  foreach (@ali)
  {
    ## The format of D lines is
    ## D source-name time-stamp checksum [subunit-name] line:file-name

    if (/^D\s+([\w\d.-]+)\s+\S+ \S+(\s+\D[^: ]+)?( (\d+):(.*))?/)
    {
	# The offset will be added to each cross-reference line. If it is
	# greater than 1, this means that we have a pragma Source_Reference,
	# and this must not be counted in the xref information.
	my ($file, $offset) = ($1, (defined $4) ? 2 - $4 : 0);

	if ($dependencies)
	{
	    push (@list_files, $1) unless (grep (/$file/, @list_files));
	}
	push (@reffiles, [&http_string (&get_real_file_name ($file)), $offset]);
    }

    elsif (/^X\s+(\d+)/)
    {
	$currentfile = $lastfile = $1 - 1;
    }

    elsif (defined $currentfile && /$decl_line/)
    {
      my ($line) = $1 + $reffiles[$currentfile][1];
      next if (! $standard_library
	       && $reffiles[$currentfile][0] =~ /$standard_file_regexp/);
      if ($xref_variable || $2 eq &uppercases ($2))
      {
	$currentref = $reffiles[$currentfile][0] . ".htm#" . tag($line, $3);
	$symbols {$currentref} = &to_type ($2);
	$lastfile = $currentfile;

	my ($endofline) = $5;

	foreach (split (" ", $endofline))
	{
	    (s/^(\d+)\|//) && do { $lastfile = $1 - 1; };
	    &create_new_reference
		($_, $reffiles[$lastfile][0],
		 $reffiles[$lastfile][1], $currentref);
	}
      }
      else
      {
	$currentref = "";
      }
    }
    elsif (/^\.\s(.*)/ && $reffiles[$currentfile][0] ne "" && $currentref ne "")
    {
      next if (! $standard_library
	       && $reffiles[$currentfile][0] =~ /$standard_file_regexp/);
      foreach (split (" ", $1))
      {
	  (s/^(\d+)\|//) && do { $lastfile = $1 - 1; };
	  &create_new_reference
	      ($_, $reffiles[$lastfile][0], $reffiles[$lastfile][1],
	       $currentref);
      }
    }
  }
}

#########
##  Return the name of the ALI file to use for a given source
##  Params:  - Name of the source file
##  return:  Name and location of the ALI file
#########

sub ali_file_name {
    my ($source) = shift;
    my ($alifilename, $unitname);
    my ($in_separate) = 0;

    $source =~ s/\.ad[sb]$//;
    $alifilename = $source;
    $unitname = $alifilename;
    $unitname =~ s/-/./g;

    ## There are two reasons why we might not find the ALI file: either the
    ## user did not generate them at all, or we are working on a separate unit.
    ## Thus, we search in the parent's ALI file.

    while ($alifilename ne "") {

      ## Search in the object path
      foreach (@obj_dir) {

	## Check if the ALI file does apply to the source file
	## We check the ^D lines, which have the following format:
	## D source-name time-stamp checksum [subunit-name] line:file-name

	if (-r "$_$alifilename.ali") {
	  if ($in_separate) {
	    open (FILE, "$_$alifilename.ali");

	    if (grep (/^D \S+\s+\S+\s+\S+ $unitname/, <FILE>)) {
	      close FILE;
	      return "$_$alifilename.ali";

	    } else {
	      ## If the ALI file doesn't apply to the source file, we can
	      ## return now, since there won't be a parent ALI file above
	      ## anyway
	      close FILE;
	      return "$source.ali";
	    }
	  } else {
	    return "$_$alifilename.ali";
	  }
	}
      }

      ## Get the parent's ALI file name

      if (! ($alifilename =~ s/-[^-]+$//)) {
	$alifilename = "";
      }
      $in_separate = 1;
    }

    return "$source.ali";
}

#########
##  This function outputs the html version of the file FILE
##  The output is send to FILE.htm.
##  Params :  - Name of the file to convert (ends with .ads or .adb)
#########
sub output_file
{
  my ($filename_param) = shift;
  my ($lineno)   = 1;
  my ($column);

  my ($alifilename) = &ali_file_name ($filename_param);

  my $filename = &get_real_file_name ($filename_param);

  ## Read the whole file
  open (FILE, &find_file ($filename)) || do {
    print &find_file ($filename), " not found ... skipping.\n";
    return 0;
  };
  my (@file) = <FILE>;
  close (FILE);

  ## Parse the .ali file to find the cross-references
  print "converting ", $filename, "\n";
  &parse_ali ($alifilename);

  ## Create and initialize the html file
  open (OUTPUT, ">$output_dir/" . &http_string ($filename) . ".htm")
      || die "Couldn't write $output_dir/" . &http_string ($filename)
	  . ".htm\n";
  print OUTPUT &create_header ($filename_param), "\n";

  ## Print the file
  $filename = &http_string ($filename);
  foreach (@file)
  {
      my ($index);
      my ($line) = $_;
      my ($comment);

      $column = 1;
      chop ($line);

      ## Print either the line number or a space if required
      if ($line_numbers)
      {
	  if ($lineno % $line_numbers == 0)
	  {
	      print OUTPUT &output_line_number ($lineno);
	  }
	  else
	  {
	      print OUTPUT &output_line_number (-1);
	  }
      }

      ## First, isolate any comment on the line
      undef $comment;
      $index = index ($line, '--');
      if ($index != -1) {
	  $comment = substr ($line, $index + 2);
	  if ($index > 1)
	  {
	      $line = substr ($line, 0, $index);
	  }
	  else
	  {
	      undef $line;
	  }
      }

      ## Then print the line
      if (defined $line)
      {
	  $index = 0;
	  while ($index < length ($line))
	  {
	      my ($substring) = substr ($line, $index);

	      if ($substring =~ /^\t/)
	      {
		  print OUTPUT ' ' x ($tab_size - (($column - 1) % $tab_size));
		  $column += $tab_size - (($column - 1) % $tab_size);
		  $index ++;
	      }
	      elsif ($substring =~ /^(\w+)/
		     || $substring =~ /^("[^\"]*")/
		     || $substring =~ /^(\W)/)
	      {
		  my ($word) = $1;
		  $index += length ($word);

		  my ($lowercase) = $word;
		  $lowercase =~ tr/A-Z/a-z/;

		  if ($keywords{$lowercase})
		  {
		      print OUTPUT &output_keyword ($word);
		  }
		  elsif ($symbols {"$filename.htm#" . tag($lineno, $column)})
		  {
		      ##  A symbol can both have a link and be a reference for
		      ##  another link, as is the case for bodies and
		      ##  declarations

		      if ($symbols_used{"$filename#" . tag($lineno, $column)})
		      {
			  print OUTPUT &before_symbol ($lineno, $column);
			  print OUTPUT " HREF=\"",
				  $symbols_used{"$filename#" . tag($lineno, $column)},
				  "\">", &protect_string ($word);
			  print OUTPUT &after_symbol ();
		      }
		      else
		      {
			  print OUTPUT &output_symbol ($word, $lineno, $column);
		      }

		      ## insert only functions into the global index

		      if ($symbols {"$filename.htm#" . tag($lineno, $column)} eq 'f')
		      {
			  push (@{$global_index {$word}},
				[$filename_param, $filename, $lineno, $column]);
		      }
		  }
		  elsif ($symbols_used{"$filename#" . tag($lineno, $column)})
		  {
		      print OUTPUT "<A HREF=\"",
		      $symbols_used{"$filename#" . tag($lineno, $column)},
		      "\">", &protect_string ($word), "</A>";
		  }
		  else
		  {
		      print OUTPUT &protect_string ($word);
		  }
		  $column += length ($word);
	      }
	      else
	      {
		  $index ++;
		  $column ++;
		  print OUTPUT &protect_string (substr ($substring, 0, 1));
	      }
	  }
      }

      ## Then output the comment
      print OUTPUT &output_comment ($comment) if (defined $comment);
      print OUTPUT "\n";

      $lineno ++;
  }

  print OUTPUT &create_footer ($filename);
  close (OUTPUT);
  return 1;
}


#########
##  This function generates the global index
#########
sub create_index_file
{
  open (INDEX, ">$output_dir/index.htm") || die "couldn't write $output_dir/index.htm";

  print INDEX <<"EOF";
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN">
<HTML>
<HEAD>
<TITLE>Source Browser</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</HEAD>
<FRAMESET COLS=\"250,*\">
<NOFRAMES>
EOF
  ;

  my (@files) = &create_file_index;
  print INDEX join ("\n", @files), "\n";

  print INDEX "<HR>\n";
  my (@functions) = &create_function_index;
  print INDEX join ("\n", @functions), "\n";

  print INDEX <<"EOF";
</NOFRAMES>
<FRAMESET ROWS=\"50%,50%\">
<FRAME NAME=files SRC=files.htm>
<FRAME NAME=funcs SRC=funcs.htm>
</FRAMESET>
<FRAME NAME=main SRC=main.htm>
</FRAMESET>
</HTML>
EOF
  ;
  close (INDEX);

  open (MAIN, ">$output_dir/main.htm") || die "couldn't write $output_dir/main.htm";
  print MAIN &create_header (""),
  "<P ALIGN=right>",
  "<A HREF=\"main.htm\" TARGET=\"_top\">[No frame version is here]</A>",
  "<P>",
  join ("\n", @files), "\n<HR>",
  join ("\n", @functions), "\n";

  if ($dependencies) {
      print MAIN "<HR>\n";
      print MAIN "You should start your browsing with one of these files:\n";
      print MAIN "<UL>\n";
      foreach (@original_list) {
	  print MAIN "<LI><A HREF=\"", &http_string (&get_real_file_name ($_)),
	     ".htm\">$_</A>\n";
      }
      print MAIN "</UL>\n";
  }
  print MAIN &create_footer ("");
  close (MAIN);
}

#######
##  Convert to upper cases (did not exist in Perl 4)
#######

sub uppercases {
  my ($tmp) = shift;
  $tmp =~ tr/a-z/A-Z/;
  return $tmp;
}

#######
##  This function generates the file_index
##  RETURN : - table with the html lines to be printed
#######
sub create_file_index
{
  my (@output) = ("<H2 ALIGN=CENTER>Files</H2>");


  open (FILES, ">$output_dir/files.htm") || die "couldn't write $output_dir/files.htm";
  print FILES &create_header (""), join ("\n", @output), "\n";


  if ($#list_files > 20)
  {
    my ($last_letter) = '';
    foreach (sort {&uppercases ($a) cmp &uppercases ($b)} @list_files)
    {
      next if ($_ eq "");
      if (&uppercases (substr ($_, 0, 1)) ne $last_letter)
      {
	if ($last_letter ne '')
	{
	  print INDEX_FILE "</UL></BODY></HTML>\n";
	  close (INDEX_FILE);
	}
	$last_letter = &uppercases (substr ($_, 0, 1));
	open (INDEX_FILE, ">$output_dir/files/$last_letter.htm")
	|| die "couldn't write $output_dir/files/$last_letter.htm";
	print INDEX_FILE <<"EOF";
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML>
<HEAD>
<TITLE>$last_letter</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</HEAD>
<BODY>
<H2>Files - $last_letter</H2>
<A HREF=\"../files.htm\" TARGET=\"_self\">[index]</A>
<UL COMPACT TYPE=DISC>
EOF
	;
	my ($str) = "<A HREF=\"files/$last_letter.htm\">[$last_letter]</A>";
	push (@output, $str);
	print FILES "$str\n";
      }
      print INDEX_FILE "<LI><A HREF=\"../",
      &http_string (&get_real_file_name ($_)),
      ".htm\" TARGET=\"main\">$_</A>\n";   ## Problem with TARGET when in no_frame mode!
    }

    print INDEX_FILE "</UL></BODY></HTML>\n";
    close INDEX_FILE;
  }
  else
  {
    push (@output, "<UL COMPACT TYPE=DISC>");
    print FILES "<UL COMPACT TYPE=DISC>";
    foreach (sort {&uppercases ($a) cmp &uppercases ($b)} @list_files)
    {
      next if ($_ eq "");
      my ($ref) = &http_string (&get_real_file_name ($_));
      push (@output, "<LI><A HREF=\"$ref.htm\">$_</A>");
      print FILES "<LI><A HREF=\"$ref.htm\" TARGET=\"main\">$_</A>\n";
    }
  }

  print FILES &create_footer ("");
  close (FILES);

  return @output;
}

#######
##  This function generates the function_index
##  RETURN : - table with the html lines to be printed
#######
sub create_function_index
{
  my (@output) = ("<H2 ALIGN=CENTER>Functions/Procedures</H2>");
  my ($initial) = "";

  open (FUNCS, ">$output_dir/funcs.htm") || die "couldn't write $output_dir/funcs.htm";
  print FUNCS &create_header (""), join ("\n", @output), "\n";


  ## If there are more than 20 entries, we just want to create some
  ## submenus
  if (scalar (keys %global_index) > 20)
  {
    my ($last_letter) = '';
    foreach (sort {&uppercases ($a) cmp &uppercases ($b)} keys %global_index)
    {
      if (&uppercases (substr ($_, 0, 1)) ne $last_letter)
      {
	if ($last_letter ne '')
	{
	  print INDEX_FILE "</UL></BODY></HTML>\n";
	  close (INDEX_FILE);
	}

	$last_letter = &uppercases (substr ($_, 0, 1));
	$initial = $last_letter;
	if ($initial eq '"')
	{
	    $initial = "operators";
	}
	if ($initial ne '.' && $initial ne ' ')
	{
	    open (INDEX_FILE, ">$output_dir/funcs/$initial.htm")
		|| die "couldn't write $output_dir/funcs/$initial.htm";
	    print INDEX_FILE <<"EOF";
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML>
<HEAD>
<TITLE>$initial</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</HEAD>
<BODY>
<H2>Functions - $initial</H2>
<A HREF=\"../funcs.htm\" TARGET=\"_self\">[index]</A>
<UL COMPACT TYPE=DISC>
EOF
				    ;
	    my ($str) = "<A HREF=\"funcs/$initial.htm\">[$initial]</A>";
	    push (@output, $str);
	    print FUNCS "$str\n";
	}
      }
      my ($ref);
      my ($is_overloaded) = ($#{$global_index {$_}} > 0 ? 1 : 0);
      foreach $ref (@{$global_index {$_}})
      {
	  my ($file, $full_file, $lineno, $column) = @{$ref};
	  my ($symbol) = ($is_overloaded ? "$_ -  $file:$lineno" : $_);
	  print INDEX_FILE "<LI><A HREF=\"../$full_file.htm#" . tag($lineno, $column) . "\" TARGET=\"main\">$symbol</A>\n";
      }
    }

    print INDEX_FILE "</UL></BODY></HTML>\n";
    close INDEX_FILE;
  }
  else
  {
    push (@output, "<UL COMPACT TYPE=DISC>");
    print FUNCS "<UL COMPACT TYPE=DISC>";
    foreach (sort {&uppercases ($a) cmp &uppercases ($b)} keys %global_index)
    {
      my ($ref);
      my ($is_overloaded) = ($#{$global_index {$_}} > 0 ? 1 : 0);
      foreach $ref (@{$global_index {$_}})
      {
	  my ($file, $full_file, $lineno, $column) = @{$ref};
	  my ($symbol) = ($is_overloaded ? "$_ -  $file:$lineno" : $_);
	  push (@output, "<LI><A HREF=\"$full_file.htm#" . tag($lineno, $column) . "\">$symbol</A>\n");
	  print FUNCS "<LI><A HREF=\"$full_file.htm#" . tag($lineno, $column) > "\" TARGET=\"main\">$symbol</A>\n";
      }
    }
    push (@output, "</UL>");
  }

  print FUNCS &create_footer ("");
  close (FUNCS);

  return (@output);
}

######
##  Main function
######

our ($index_file) = 0;

mkdir ($output_dir, 0777)          if (! -d $output_dir);
mkdir ($output_dir."/files", 0777) if (! -d $output_dir."/files");
mkdir ($output_dir."/funcs", 0777) if (! -d $output_dir."/funcs");

&parse_prj_file ($prjfile) if ($prjfile);

while ($index_file <= $#list_files)
{
  my ($file) = $list_files [$index_file];

  if (&output_file ($file) == 0)
    {
      $list_files [$index_file] = "";
    }
  $index_file ++;
}
&create_index_file;

my $indexfile = "$output_dir/index.htm";
$indexfile =~ s!//!/!g;
print "You can now download the $indexfile file to see the ",
  "created pages\n";
