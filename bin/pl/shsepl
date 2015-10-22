#!/usr/bin/env perl

use strict;
use warnings;
use 5.14.0;
use Tkx;
use IO qw(File);

#Let's just get this out of the way.
#Keep menus from tearing away.
Tkx::option_add("*tearOff", 0);
#Consider this program as proof that 
#OOP does not solve modularity problems.
#Or gratuitous code commenting.

#Let's do some basic file-info hashref fun.
our %newfile = (
	'filename' 	=> 'UNTITLED',
	'contents'	=> '',
	'lang'		=> '',
	'encoding'	=> 'utf-8',
);
our %realfile = (
	'filename' 	=> 'UNTITLED',
	'contents'	=> '',
	'lang'		=> '',
	'encoding'	=> 'utf-8',
);
#Initialize the current state to a new file.
say "Initializing internal hashref to a new file.";
our $current = \%realfile;

#Let's try to get user preferences ironed out in an easily-fixable way.
our $preferences = {
	'windowheight' 	=> '550',
	'windowwidth' 	=> '345',
};

#Elements
#Container
my $framewidth = $preferences->{windowheight};
my $frameheight = $preferences->{windowwidth};
my $mw = Tkx::widget->new(".");
$mw->g_wm_title($current->{filename} . " - shse");
$mw->g_wm_minsize($framewidth, $frameheight);
my $content = $mw->new_ttk__frame;
my $frame = $content->new_ttk__frame();

#Menu
#Toplevel
my $menu = $frame->new_menu;
my $filemenu = $menu->new_menu;
my $editmenu = $menu->new_menu;
my $helpmenu = $menu->new_menu;
$menu->add_cascade(-menu => $filemenu, -label => "File");
$menu->add_cascade(-menu => $editmenu, -label => "Edit");
$menu->add_cascade(-menu => $helpmenu, -label => "Help");
#File Menu
$filemenu->add_command(-label => "New", -command => sub {new_file()});
$filemenu->add_command(-label => "Open", -command => sub {open_file()});
$filemenu->add_command(-label => "Save", -command => sub {save_file()});
$filemenu->add_command(-label => "Save As...", -command => sub {save_as_file()});
$filemenu->add_separator;
$filemenu->add_command(-label => "Exit", -command => sub {exit_file()});
#Edit Menu
$editmenu->add_command(-label => "Undo", -command => sub {undo_edit()});
$editmenu->add_command(-label => "Redo", -command => sub {redo_edit()});
$editmenu->add_command(-label => "Cut", -command => sub {cut_edit()});
$editmenu->add_command(-label => "Copy", -command => sub {copy_edit()});
$editmenu->add_command(-label => "Paste", -command => sub {paste_edit()});
$editmenu->add_separator;
$editmenu->add_command(-label => "Preferences", -command => sub {preferences_edit()});
#Help Menu. Yes, there is a "better" way to do it. Let's avoid it.
$helpmenu->add_command(-label => "Documentation", -command => sub {documentation_help()});
$helpmenu->add_separator;
$helpmenu->add_command(-label => "About", -command => sub {about_help()});

#Textbox
my $text = $frame->new_tk__text(-wrap => "none");
#Scrollbar
my $verticalscrollbar = $frame->new_ttk__scrollbar(-orient => 'vertical', -command => [$text, 'yview']);
$text->configure(-yscrollcommand => [$verticalscrollbar, 'set']);
my $horizontalscrollbar = $content->new_ttk__scrollbar(-orient => 'horizontal', -command => [$text, 'xview']);
$text->configure(-xscrollcommand => [$horizontalscrollbar, 'set']);
#Statusbar
my $linenum = 7;
my $colnum = 10; #Dummy values
my $statusbar = $content->new_ttk__frame(-width => $preferences->{windowwidth}, -height => 15);
my $statusbarlinetext = $statusbar->new_ttk__label(-text => "Line ");
my $statusbarlinevar = $statusbar->new_ttk__label(-textvariable => \$linenum);
my $statusbarcoltext = $statusbar->new_ttk__label(-text => ", Column ");
my $statusbarcolvar = $statusbar->new_ttk__label(-textvariable => \$colnum);

##The next 32 lines are an atrocity.

#Element layout.
#$mw->configure(-menu => $menu);
#$content->g_grid(-column => 0, -row => 0, -sticky => "nesw");
#$frame->g_grid(-column => 0, -row => 0, -sticky => "nesw");
#$text->g_grid(-column=> 0, -row => 0, -sticky => "nesw");
#$verticalscrollbar->g_grid(-column => 1, -row => 0, -sticky => "ns");
#$horizontalscrollbar->g_grid(-column => 0, -row => 1, -sticky => "we");
#$statusbar->g_grid(-column => 0, -row => 2, -sticky => "we");
#$statusbarlinetext->g_grid(-column => 0, -row => 2, -sticky => "w");
#$statusbarlinevar->g_grid(-column => 0, -row => 2, -sticky => "w");
#$statusbarcoltext->g_grid(-column => 0, -row => 2, -sticky => "w");
#$statusbarcolvar->g_grid(-column => 0, -row => 2, -sticky => "w");
#$mw->new_ttk__sizegrip->g_grid(-column => 0, -row => 0, -sticky => "se");

#Pack it up, pack it in.
$mw->configure(-menu => $menu);
$content->g_pack(-expand => 1, -fill => "both");
$frame->g_pack(-expand => 1, -fill => "both");
$text->g_pack(-in => $frame, -expand => 1, -fill => "both", -side => "left");
$verticalscrollbar->g_pack(-in => $frame, -side => "right", -expand => 0, -fill => "y", -anchor => "e");
$horizontalscrollbar->g_pack(-in => $content, -expand => 0, -side => "top", -fill => "x");
$statusbar->g_pack(-expand => 0, -fill => "x");
$statusbarlinetext->g_grid(-column => 0, -row => 2, -sticky => "w");
$statusbarlinevar->g_grid(-column => 1, -row => 2, -sticky => "w");
$statusbarcoltext->g_grid(-column => 2, -row => 2, -sticky => "w");
$statusbarcolvar->g_grid(-column => 3, -row => 2, -sticky => "w");
#$statusbarlinetext->g_pack(-in => $statusbar, -anchor => "w",);
#$statusbarlinevar->g_pack(-in => $statusbar, -anchor => "w", -after => $statusbarlinetext);
#$statusbarcoltext->g_pack(-in => $statusbar, -anchor => "w", -after => $statusbarlinevar);
#$verticalscrollbar->g_pack(-in => $frame, -expand => 0, -fill => "y", -anchor => "e");

#Relevant original subroutines.

sub detect_filetype {
	$_ = $current->{filename};
	my $rev = scalar reverse;
	#Just looking for Perl for now.
	my @arr = split(/\./, $rev);
	$arr[0] = scalar reverse $arr[0];
	if ($arr[0] eq "pm" || $arr[0] eq "pl") { $current->{lang} = "perl"; }
	
	if ($current->{lang}) {
		say $current->{lang};
	} else {
		say "There is no language to be assumed.";
	}
}



sub update_current { #Updates the hashref
	say "Updating \$current hashref.";
	$current->{contents} = $text->get("1.0", "end");
	$mw->g_wm_title($current->{filename} . " - shse");
	#Everything else should be updated by other subs,
	#because modularity is for people who can't keep
	#an arbitrarily large number of layers in their heads.
	&detect_filetype;
}

sub update_actual { #Updates the text field.
	$text->delete('1.0', 'end'); #clear the way
	$text->insert('1.0', $current->{contents});
}

sub save {
	###Requires that all relevant details be resolved before being called,
	###Except for the contents of the text field.
	#Obviously save the current open file to disk.
	#Create instance of whatever file.
	say "Update internal hashref.";
	&update_current;
	if ($current->{filename} eq "UNTITLED") { $current->{filename} = Tkx::tk___getSaveFile() or return say "User cancelled save."; }
	say "Attempting to save.";
	open(my $fh, ">", $current->{filename}) or return say "Couldn't open for saving: $!";
	say "Opened for saving.";
	print $fh $current->{contents};
	say "Contents written to file.";
	close($fh) or warn "Couldn't close file: $!";
	say "File saved.";
}

sub confirm_save {
	my $confirm = Tkx::tk___messageBox(-type => "yesno",
	    -message => "Would you like to save the current file?",
	    -icon => "question", -title => "Confirm");
	given ($confirm) {
		when ("yes") { &save; }
		when ("no") { say "User chose not to save the file. Their loss."; }
	}
}

sub exit_file {
	#TODO: Put a save confirmation alert up.
	$mw->g_destroy;
}

sub save_file {
	&save;
}

sub save_as_file {
	$current->{filename} = Tkx::tk___getSaveFile() or return say "User cancelled save.";
	&save;
	&update_current;
}

sub open_file {
	$current->{filename} = Tkx::tk___getOpenFile();
	open(my $fh, "<", $current->{filename}) or warn "Couldn't open for reading: $!";
	local $/=undef; 
	my $file = <$fh>;
	close $fh;
	$current->{contents} = $file;
	&update_actual;
	&update_current;
}

sub new_file {
	&confirm_save;
	%realfile = %newfile;
	$text->delete('1.0', 'end'); #clear the way
	$text->insert('1.0', $current->{contents});
	&update_current;
	
}

#Blast off.
Tkx::MainLoop();
