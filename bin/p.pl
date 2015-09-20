#!/usr/bin/perl

# md5sum over a binary tree

    use strict;
    use warnings;

    use POSIX qw( ceil floor );
    use Digest::MD5 qw( md5_hex );
    use List::Util qw( max );
    use Data::Dumper;

my @lines = <>;

#my $levels = 4;
my $levels = ceil(log(scalar(@lines)) / log(2));

## traverse the binary tree, generate the table
my @table = (map { [ map {''} 1..$levels ] } 1..(2**$levels) );        # rows first, columns second
for (my $col=1; $col<$levels-1; $col++) {
    for (my $row=0; $row<2**$levels; $row++) {
        $table[$row][$col] =
            ($col % 2) ? "|\n|\n|" : "#\n#\n#";
    }
}
for (my $level=0; $level<=$levels; $level++) {
    my $cells_per_section = 2**($levels - $level);
    for (my $section=0; $section<2**$level; $section++) {
        my ($checksum, $lines) = calculate_checksum(\@lines, $section, 2**$level);
        $table[$section * $cells_per_section][$level] = "$checksum\n$lines\n";
    }
}
    #print Dumper \@table; exit;

print_table_multiline(\@table, 0);



sub calculate_checksum {
    my ($lines, $numerator, $denominator) = @_;

    my $numlines = scalar(@$lines);
    my $start_line = floor($numerator * $numlines / $denominator);
    my $end_line = floor(($numerator + 1) * $numlines / $denominator) - 1;
    $end_line = max($end_line, $start_line);        # When the tree doesn't extend all the way to the leaf, somehow we get our range flipped.  Very weird.
    my $line_range = ($start_line+1) . "-" . ($end_line+1);
    if ($start_line == $end_line) {
        $line_range =~ s/-.*//;     # for single lines, don't display the range
    }

    my $lines_str = join '', @$lines[$start_line .. $end_line];
    my $checksum = substr(md5_hex($lines_str), 0, 7);

    return ($checksum, $line_range);
}


# Takes in a table (2D array), and displays it to the user, auto-adjusting the column width.
#
# Each cell should have NO NEWLINES.  (use print_table_multiline() for that)
# The table is formatted:    $table->[$row][$col]
#
# TODO: Add a feature that chr(1) within a cell indicates that the character that comes just before
#       the chr(1) should be repeated as much as needed to fill out the cell.
#       This is useful for two separate things:
#           1. it lets you specify a header-separator row, where the separator spans the entire
#              column, using:     "-\x01"
#           2. it lets you right-justify anything, using:           " \x01anything"
#                    (here, it would even add zero spaces, in the case that the column is already
#                     wide enough)
sub print_table {
    my ($table) = @_;
    my $format = '';
    my $num_cols = num_cols($table);
    for (my $col=0; $col<$num_cols-1; $col++) {        # calculate the max-width of each column
        $format .= '%-' . List::Util::max( map { length $_->[$col]} @$table ) . 's ';
    }
    $format .= ' %s';
    foreach my $row (@$table) {
        printf "$format\n", @$row,
                ('') x $num_cols;       # pad out the row, for rows that have fewer cols
    }
}


# Just like print_table(), except it accepts cells that have multi-line contents.
# (i.e. the cells can have variable height too, not just variable width)
#
# Paramters:
#       $table                  Same as print_table()
#       $pad_between_rows       (boolean) Should there be an extra line added in between each row?
sub print_table_multiline {
    my ($table, $pad_between_rows) = (shift, shift);
    ## normalise the rows
    my @table_normalised;
    my $num_cols = num_cols($table);
    foreach my $row (@$table) {
        # calculate the max-height of this row
        my $subrow_start = scalar(@table_normalised);
        my @subrows = map { [ split /\n/, $_ ] } @$row;
        my $height = List::Util::max( map { scalar(@$_) } @subrows );
        $height++ if ($pad_between_rows);
        for (my $col=0; $col<$num_cols; $col++) {
            for (my $subrow=0; $subrow<$height; $subrow++) {
                $table_normalised[$subrow_start + $subrow][$col] = $subrows[$col][$subrow] || '';
            }
        }
    }
            #print Dumper \@table_normalised;  exit;
    print_table \@table_normalised, @_;             # pass through all remaining parameters untouched to print_table()
}


# Given a table in the form of   $table->[$row][$col]
# it's pretty easy to get the number of rows.  But what about the number of columns?
# Here, the number of columns can vary, so you can't just take the size of the first row.
# This finds the max columns across all rows.
sub num_cols {
    my ($table) = @_;
    return List::Util::max map { scalar(@$_) } @$table;
}
