#!/usr/bin/gawk -f
#
#@ This program came from: ftp://ftp.armory.com/pub/scripts/altchars
#@ Look there for the latest version.
#@ If you don't find it, look through http://www.armory.com/~ftp/
#
# @(#) altchars 1.3.1 2003-05-06
# 1996-05-21 john h. dubois iii (john@armory.com)
# 1996-05-29 Added all options.
# 1996-08-06 Added ib options.
# 1996-11-30 Moved altInit code into a function
# 1998-11-02 Print characters in an order specified here, rather than in the
#            order they are given in the acsc capability.  Added u option.
# 1998-12-09 1.3 Added -AESRx options.
# 2003-05-06 1.3.1 Sort list of unknown chars

BEGIN {
    Name = "altchars"
    Usage = "Usage:\n"\
Name " [-ahobiu] [-T<termtype>] [-A<acsc>] [-E<enacs>] [-S<smacs>] [-R<rmacs>]"
    ARGC = Opts(Name,Usage,"abhioT;uA;E:S:R:x",0)
    if ("h" in Options) {
	printf \
"%s: print alternate character set for a terminal using terminfo database.\n"\
"%s\n"\
"%s prints the characters that are rendered in the alternate character set\n"\
"by terminfo-based programs that need to use the graphic (non-ASCII)\n"\
"characters that are recorded in the terminfo \"acsc\" capability.  Before\n"\
"printing the characters, these programs send a sequence that switches the\n"\
"terminal into the alternate set.  By default, %s does not send the\n"\
"character set switching sequence, so the characters it prints appear as\n"\
"they do in the acsc string.\n"\
"The 'Tag' column gives the VT100-equivalent character used in the acsc\n"\
"capability to tell what the function of each character is.\n"\
"The 'Pos' column gives the position of each character in the acsc string.\n"\
"The 'Sym' column is a symbolic representation of the character.\n"\
"acsc is used mainly to get the characters used to draw boxes.\n"\
"Options:\n"\
"-h: Print this help.\n"\
"-a: Print an extra 'Char' column with each alternate character printed with\n"\
"    the alternate character set turned on, so that they will show up as the\n"\
"    real graphic characters if the terminal interprets them correctly.\n"\
"-b: Draw a partitioned box using the alternate character set, with the\n"\
"    characters also shown as they appear in the standard character set,\n"\
"    followed the acsc tag characters.\n"\
"-i: Emit a channel map that maps some characters of the IBM graphic\n"\
"    character set into alternate character set sequences for the terminal\n"\
"    type that %s operates on.  The characters mapped are those that the\n"\
"    acsc capability defines.  If this map is installed with mapchan, an\n"\
"    application that uses those IBM graphic characters will be able to\n"\
"    display them on the terminal.  The mapchan facility does not have\n"\
"    enough room to store much output mapping, so only the box drawing\n"\
"    characters and a few others are mapped.\n"\
"-T<termtype>: Print the alternate characters for the given terminal type,\n"\
"    instead of the terminal type given by the environment variable TERM.\n"\
"-A<acsc>, -E<enacs>, -S<smacs>, -R<rmacs>: Use the given strings for the\n"\
"    named capabilities instead of extracting them from the terminfo database.\n"\
"-u: Do not report on unassigned characters from the alternate character set.\n"\
"-o: Print all non-printing characters in octal.  The default is to print\n"\
"    characters above ASCII value 127 in octal, and all other non-printing\n"\
"    characters in the symbolic form ^X.\n",
	Name,Usage,Name,Name,Name
	exit 0
    }
    Debug = "x" in Options
    if (ARGC > 1) {
	print Name ": invalid argument.  Use -h for help." > "/dev/stderr"
	exit 1
    }
    if ((Err = ExclusiveOptions("a,b,i,o",Options)) != "") {
	printf "Error: %s\n",Err > "/dev/stderr"
	Err = 1
	exit(1)
    }
    if ("T" in Options)
	term = Options["T"]
    else
	term = ENVIRON["TERM"]
    Octal = "o" in Options
    drawBox = "b" in Options
    AltChars = "a" in Options
    chanMap = "i" in Options
    list = !(drawBox || chanMap)
    Assign(CharNames,
    "l=upper left corner|"\
    "k=upper right corner|"\
    "m=lower left corner|"\
    "j=lower right corner|"\
    "t=left tee|"\
    "u=right tee|"\
    "w=top tee|"\
    "v=bottom tee|"\
    "n=plus|"\
    "q=horizontal line|"\
    "x=vertical line|"\
    "+=arrow pointing right|"\
    ",=arrow pointing left|"\
    "-=arrow pointing up|"\
    ".=arrow pointing down|"\
    "~=bullet|"\
    "I=lantern symbol|"\
    "`=diamond|"\
    "0=solid square block|"\
    "a=checker board|"\
    "f=degree symbol|"\
    "g=plus/minus|"\
    "h=board of squares|"\
    "o=scan line 1|"\
    "s=scan line 9",
    "|","=",cOrder)
    CopySet(CharNames,vtchars)

    if ("A" in Options) {
	if (Debug)
	    printf "pre-interpreted acsc capability: %s\n",Uncontrol(Options["A"]) > "/dev/stderr"
	tinfo["acsc"] = tiCapInterp(Options["A"])
    }
    if ("E" in Options)
	tinfo["enacs"] = tiCapInterp(Options["E"])
    if ("S" in Options)
	tinfo["smacs"] = tiCapInterp(Options["S"])
    if ("R" in Options)
	tinfo["rmacs"] = tiCapInterp(Options["R"])
    if (ret = altInit(tinfo,term,0,AltMap,num))
	exit ret
    if (Debug) {
	printf "interpreted acsc capability:\n" > "/dev/stderr"
	split(tinfo["acsc"],aelem,"")
	for (i = 1; i in aelem; i++)
	    printf "%s ",Uncontrol(aelem[i]) > "/dev/stderr"
	print "" > "/dev/stderr"
    }
    caplist = "enacs,smacs,rmacs"
    split(caplist,capnames,",")
    split("Enable,Start,End",capdesc,",")
    for (i = 1; i in capnames; i++) {
	capname = capnames[i]
	if (list && capname in tinfo)
	    printf "%s alternate character set sequence: %s\n",capdesc[i],
	    Uncontrol(tinfo[capname],Octal)
    }
    #acsc = tinfo["acsc"]
    # If we will be printing chars in alternate character set,
    # get start/end alt char set sequences and enable alternate character set.
    if (AltChars || drawBox || chanMap) {
	if ("smacs" in tinfo)
	    smacs = tinfo["smacs"]
	if ("rmacs" in tinfo)
	    rmacs = tinfo["rmacs"]
	if ("enacs" in tinfo)
	    printf "%s",tinfo["enacs"]
	if (AltChars)
	    printf "Char "
    }
    if (drawBox) {
	Format = "%-5s   %-5s   %s\n"
	AltMap[" "] = " "
	space = "   "
	printf Format,"Alt","Chars","Tags"
	split("lqwqk,x x x,tqnqu,x x x,mqvqj",elem,",")
	for (i = 1; i <= 5; i++) {
	    s = elem[i]
	    mapped = graphic = ""
	    for (j = 1; (c = substr(s,j,1)) != ""; j++) {
		a = AltMap[c]
		mapped = mapped a
		if (c == " ")
		    # Some terminals do not have space as space in alt charset
		    graphic = graphic rmacs " " smacs
		else
		    graphic = graphic a
	    }
	    printf Format,smacs graphic rmacs,mapped,s
	}
	exit 0
    }
    if (chanMap) {
	toMapChan(S)
	MakeMapchanTable()
	#ibmset = \
	"0\333a\261g\361h\262j\331k\277l\332m\300n\305q\304t\303u\264v\301w\302x\263+\032.\031-\030`\004~\011"
	#ibmset = "j\331k\277l\332m\300n\305q\304t\303u\264v\301w\302x\263"
	ibmset = \
	"j\331k\277l\332m\300n\305q\304t\303u\264v\301w\302x\263~\372a\260"

	len = length(ibmset)
	for (i = 1; i < len; i += 2)
	    ibmMap[substr(ibmset,i,1)] = substr(ibmset,i+1,1)
	print "input\n\noutput\n"
	for (c in AltMap)
	    if (c in ibmMap) {
		printf "# %s\n",CharNames[c]
		printf "%s %s\n",toMapChan(ibmMap[c]),
		toMapChan(smacs AltMap[c] rmacs)
	    }
	exit 0
    }
    CopySet(AltMap,unknown)
    Format = "%-3s %3s %-5s %s\n"
    printf Format,"Tag","Pos","Sym","Description"
    for (j = 1; j in cOrder; j++) {
	vtchar = cOrder[j]
	if (vtchar in AltMap) {
	    altchar = AltMap[vtchar]
	    if (AltChars)
		printf "%s",smacs altchar rmacs "    "
	    printf Format,vtchar,j,
	    Uncontrol(altchar,Octal),CharNames[vtchar]
	    delete unknown[vtchar]
	    delete vtchars[vtchar]
	}
    }
    if (!(IsEmpty(unknown))) {
	print \
	"Unknown line drawing character label(s) found in acsc capability:" \
	> "/dev/stderr"
	# Sort to make output easier to read and consistent from run to run
	nUnknown = qsortByArbIndex(unknown,k,0)
	for (i = 1; i <= nUnknown; i++)
	    printf "%s ",Uncontrol(k[i],Octal) > "/dev/stderr"
	print "" > "/dev/stderr"
    }
    if (!("u" in Options) && !(IsEmpty(vtchars))) {
	print "Unassigned characters from the alternate character set:" \
	> "/dev/stderr"
	for (char in vtchars)
	    printf "%s   %s\n",char,CharNames[char] > "/dev/stderr"
    }
}

function toMapChan(S,  i,len,Output) {
    len = length(S)
    Output = ""
    for (i = 1; i <= len; i++) {
	Output = Output " " mchar2octal[substr(S,i,1)]
    }
    return substr(Output,2)
}

function MakeMapchanTable(  i,c) {
    for (i = 1; i < 32; i++)
	mchar2octal[sprintf("%c",i)] = sprintf("%3d",i)
    for (i = 32; i < 127; i++)
	mchar2octal[sprintf("%c",i)]  = sprintf("'%c'",i)
    mchar2octal[sprintf("%c",127)] = 127
    for (i = 128; i < 256; i++)
	mchar2octal[sprintf("%c",i)] = sprintf("%3d",i)
}

### Begin-lib xControl
#
# The current version of this library can be found by searching
# http://www.armory.com/~ftp/
#
# @(#) xControl 1.3.1 2005-10-04
# 1992-11-09 john h. dubois iii (john@armory.com)
# 1996-05-29 Added octal-only conversion.
# 1998-12-09 Added ToControl
# 2004-04-27 1.3 Do not treat characters >159 as control chars.
#            Added Override to Uncontrol.

# Uncontrol(S): Convert control characters in S to symbolic form.
# Characters in S with values < 32 and with value 127 are converted to the form
# ^X.  Characters with value >= 128 are converted to the octal form \0nnn,
# where nnn is the octal value of the character.
# The resulting string is returned.
# If OctalOnly is true, octal numbers are used for all symbolic values instead
# of ^X.
# If any characters are indexes of Override[], the values assigned to those
# indexes are used.
# Global variables: _xControl_UncTable[] and _xControl_char2octal[].
function Uncontrol(S, OctalOnly, Override,
	i, len, Output, c) {
    len = length(S)
    Output = ""
    if (!("a" in _xControl_UncTable))
	MakeUncontrolTable()
    for (i = 1; i <= len; i++) {
	c = substr(S,i,1)
	Output = Output ((c in Override) ? Override[c] : \
		(OctalOnly ? _xControl_char2octal[c] : _xControl_UncTable[c]))
    }
    return Output
}

# MakeUncontrolTable: Make tables for use by Uncontrol().
# Global variables:
# _xControl_UncTable[] is made into a character -> symbolic character lookup table
# with characters with values < 32 and with value 127 converted to the form
# ^X, and characters with value >= 128 are converted to the octal form \0nnn.
# _xControl_char2octal[] is made into a similar table but with all non-printing chars
# in the form \0nnn.
function MakeUncontrolTable(\
	i, c) {
    for (i = 0; i < 32; i++) {
	_xControl_UncTable[c = sprintf("%c",i)] = "^" sprintf("%c",i + 64)
	_xControl_char2octal[c] = "\\" sprintf("%03o",i)
    }
    for (i = 32; i < 127; i++) {
	c = sprintf("%c",i)
	_xControl_char2octal[c]  = _xControl_UncTable[c] = sprintf("%c",i)
    }
    _xControl_UncTable[c = sprintf("%c",127)] = "^?"
    _xControl_char2octal[c] = "\\0177"
    for (i = 128; i < 160; i++) {
	_xControl_UncTable[c = sprintf("%c",i)] = "\\" sprintf("%03o",i)
	_xControl_char2octal[c] = "\\" sprintf("%03o",i)
    }
    for (i = 160; i <= 255; i++) {
	c = sprintf("%c",i)
	_xControl_char2octal[c]  = _xControl_UncTable[c] = sprintf("%c",i)
    }
}

function MakeToControlTable(\
	i) {
    _ToControl_Map["@"] = "\000"
    _ToControl_Map["["] = "\033"
    _ToControl_Map["\\"] = "\034"
    _ToControl_Map["]"] = "\035"
    _ToControl_Map["^"] = "\036"
    _ToControl_Map["_"] = "\037"
    _ToControl_Map["?"] = "\177"
    for (i = 1; i <= 26; i++) {
	_ToControl_Map[sprintf("%c",i+64)] = sprintf("%c",i)
	_ToControl_Map[sprintf("%c",i+96)] = sprintf("%c",i)
    }
}

# Convert character sequences in S of the form ^X to control character X
# and return the resulting string.
function ToControl(S,
	len, i, c0, c, newS) {
    len = length(S)
    if (!("@" in _ToControl_Map))
	MakeToControlTable()

    for (i = 1; i <= len; i++)
	if ((c0 = substr(S,i,1)) == "^" && \
	(c = substr(S,i+1,1)) in _ToControl_Map) {
	    newS = newS _ToControl_Map[c]
	    i += 1
	}
	else
	    newS = newS c0
    return newS
}

# Converts sequences of the form \n or \nn or \nnn (where n is a digit)
# to the character whose ASCII value is decimal n or nn or nnn
# If the character following \ is a nondigit, the character is taken literally
function UnEscape(S,
	out, len, i, c, esc, val, vallen) {
    len = length(S)
    out = ""
    for (i = 1; i <= len; i++) {
	c = substr(S,i,1)
	if (c == "\\") {
	    c = substr(S,++i,1)
	    if (c ~ "[0-9]") {
		val = substr(S,i)
		vallen = match(val,"[^0-9]") - 1
		if (vallen > 3)
		    vallen = 3
		else if (vallen == -1)
		    vallen = 3
		c = sprintf("%c",substr(val,1,vallen) + 0)
		i += vallen - 1
	    }
	}
	out = out c
    }
    return out
}
# cEsc 1.0 1998-08-02
# 1998-08-02 john h. dubois iii (john@armory.com)
# Performs these escape sequence conversions on S and returns the result:
# \\                backslash
# \a                alert or bell
# \b                backspace
# \f                formfeed
# \n                newline
# \r                carriage return
# \t                horizontal tab
# \v                vertical tab
# \d, \dd, \ddd     octal value of d, dd, or ddd
function cEsc(S,
	out, len, i, j, c, val, ind) {
    len = length(S)
    out = ""
    for (i = 1; i <= len; i++) {
	c = substr(S,i,1)
	if (c == "\\") {	# translate escape sequence
	    c = substr(S,++i,1)
	    if (c ~ "[0-7]") {
		val = c
		for (j = 1; j <= 2; j++) {
		    if ((c = substr(S,i+1,1)) ~ "[0-7]") {
			val = val * 8 + c
			i++
		    }
		    else
			break
		}
		c = sprintf("%c",val+0)
	    }
	    else if (ind = index("abfnrtv",c))
		c = substr("\a\b\f\n\r\t\v",ind,1)
	}
	out = out c
    }
    return out
}
### End-lib xControl
### Begin-lib set
# @(#) set 1.3 1997-01-26
# john h. dubois iii (john@armory.com)
# 1996-05-23 added return values 
# 1996-05-25 added set2list()
# 1997-01-26 Added AOnly(), Exclusive()

# Return value: the number of new elements added to Inter
function Intersection(A,B,Inter,  Elem,Count) {
    Count = 0
    for (Elem in A)
	if (Elem in B && !(Elem in Inter)) {
	    Inter[Elem]
	    Count++
	}
    return Count
}

# Any element that is in A or B but not both and which is not already in
# Excl is added to Excl.
# Return value: the number of new elements added to Excl
function Exclusive(A,B,Excl) {
    return AOnly(A,B,Excl) + AOnly(B,A,Excl)
}

# Any element that is in A and not in B or aOnly is added to aOnly.
# Return value: the number of new elements added to aOnly.
function AOnly(A,B,aOnly,  Elem,Count) {
    Count = 0
    for (Elem in A)
	if (!(Elem in B) && !(Elem in aOnly)) {
	    aOnly[Elem]
	    Count++
	}
    return Count
}

# Return value: the number of new elements added to Both
function Union(A,B,Both) {
    return CopySet(A,Both) + CopySet(B,Both)
}

# Deletes any elements that are in both Minuend and Subtrahend from Minuend.
# Return value: the number of elements deleted.
function SubtractSet(Minuend,Subtrahend,  Elem,nDel) {
    nDel = 0
    for (Elem in Subtrahend)
	if (Elem in Minuend) {
	    delete Minuend[Elem]
	    nDel++
	}
    return nDel
}

# Return value: the number of new elements added to To
function CopySet(From,To,  Elem,n) {
    n = 0
    for (Elem in From)
	if (!(Elem in To)) {
	    To[Elem]
	    n++
	}
    return n
}

# Returns 1 if Set is empty, 0 if not.
function IsEmpty(Set,  i) {
    for (i in Set)
	return 0
    return 1
}

# MakeSet: make a set from a list.
# An index with the name of each element of the list is created in the given
# array.
# Input variables:
# Elements is a string containing the list of elements.
# Sep is the character that separates the elements of the list.
# Output variables:
# Set is the array.
# Return value: the number of new elements added to the set.
function MakeSet(Set,Elements,Sep,  i,Num,Names,nFound,ind) {
    nFound = 0
    Num = split(Elements,Names,Sep)
    for (i = 1; i <= Num; i++) {
	ind = Names[i]
	if (!(ind in Set)) {
	    Set[ind]
	    nFound++
	}
    }
    return nFound
}

# Returns the number of elements in set Set
function NumElem(Set,  elem,Num) {
    for (elem in Set)
	Num++
    return Num
}

# Remove all elements from Set
function DeleteAll(Set,  i) {
    split("",Set,",")
}

# Returns a list of all of the elements in Set[], with each pair of elements
# separated by Sep.
function set2list(Set,Sep,  list,elem) {
    for (elem in Set)
	list = list Sep elem
    return substr(list,2)	# skip 1st separator
}
### End-lib set
### Begin-lib ProcArgs
#
# The current version of this library can be found by searching
# http://www.armory.com/~ftp/
#
# @(#) ProcArgs 1.26 2010-05-02
# 1992-02-29 john h. dubois iii (john@armory.com)
# 1993-07-18 Added "#" arg type
# 1993-09-26 Do not count h option against MinArgs
# 1994-01-01 Stop scanning at first non-option arg.  Added ">" option type.
#            Removed meaning of "+" or "-" by itself.
# 1994-03-08 Added & option and *()< option types.
# 1994-04-02 Added NoRCopt to Opts()
# 1994-06-11 Mark numeric variables as such.
# 1994-07-08 Opts(): Do not require any args if h option is given.
# 1995-01-22 Record options given more than once.  Record option num in argv.
# 1995-06-08 Added ExclusiveOptions().
# 1996-01-20 Let rcfiles be a colon-separated list of filenames.
#            Expand $VARNAME at the start of its filenames.
#            Let varname=0 and [-+]option- turn off an option.
# 1996-05-05 Changed meaning of 7th arg to Opts; now can specify exactly how
#            many of the vars should be searched for in the environment.
#            Check for duplicate rcfiles.
# 1996-05-13 Return more specific error values.  Added AllowUnrecOpt.
# 1996-05-23 Check type given for & option
# 1996-06-15 Re-port to awk
# 1996-10-01 Moved file-reading code into ReadConfigFile(), so that it can be
#            used by other functions.
# 1996-10-15 Added OptIntroChars
# 1996-11-01 Added exOpts arg to Opts()
# 1996-11-16 Added ; type
# 1996-12-08 Added Opt2Set() & Opt2Sets()
# 1997-02-22 Remove packed elements.
# 1997-02-28 Make sequence # for rcfiles & environ be "f" and "e".
#            Added OptsGiven().
# 1997-05-26 Added mangleHelp().
# 1997-08-20 Added end-of-line escape char processing to ReadConfigFile()
# 1997-12-21 Improved mangleHelp()
# 1998-04-19 1.2 Moved default file reading code into ReadLogicalLines[].
#            Added quote processing.
# 1999-02-01 1.2.1 Added Opt2Arr()
# 1999-03-25 1.2.2 Removed compress argument to ProcArgs.
#            Opts() now compresses ARGV.
# 1999-05-03 1.2.3 Declare Lines[] in InitOpts()
# 1999-05-05 1.2.4 Bugfix in option deletion
# 2000-01-19 1.2.5 If -x is given, always print value assignments.
# 2000-07-23 1.2.6 Fixed return value of Opt2Arr()
# 2000-10-15 1.2.7 Fix test for ) value
# 2001-04-05 1.2.8 Improved mangleHelp(). ProcArgs sets global _optIntroChar.
# 2001-06-05 1.3 Added Sep option to Opt2Arr().  Set (optname,1).
#            Added addPseudoOpt(), prioOpt(), elideOpts().
#            Made OptsGiven() return a number rather than just true/false
#            and added Results[] parameter.
#            Allow unrecognized options only if they are the first option
#            in an option string.
# 2001-06-13 1.3.1 Minor tweaks to reduce the number of complaints from
#            gawk --lint
# 2001-10-26 1.4 Separated recording of sequence number from recording of data
#            source.  Allow multiple instances of options to be set in a
#            config file.  Record file for each option instance.
#            Added "a" and "p" source types.
# 2002-02-26 1.4.1 Fixed return value of Opt2Set()
# 2002-06-11 1.4.2 Global var fix
# 2002-11-23 1.4.3 Convert \- to - in mangleHelp().
# 2003-04-05 1.4.4 Fixed some global vars to be local.
#            Fixed extra newline added by mangleHelp().
# 2003-05-13 1.5 Added Pat parameter to varValOpt()
# 2003-06-06 1.6 Changed the way multiple instance of Boolean options are dealt
#            with.
# 2003-09-30 1.7 Renamed ProcArgs to _procArgv and changed the way it processes
#            it option-list, as the first step towards a new
#            option-specification syntax.
# 2003-10-07 1.8 Added errVar parm to varValOpt()
# 2004-12-09 1.9 Added Prefix parm to ReadConfigFile()
# 2004-12-20 1.10 Preserve empty lines in quoted sections in ReadLogicalLine().
#            Improved performance of ReadLogicalLine().
# 2004-12-27 1.11 Added Order[] parameter to ReadConfigFile().
#            Added ReturnAll parameter to ReadLogicalLine(),
#            ReadLogicalLines(), and ReadConfigFile().
#            Added WriteConfigFile().
# 2005-06-23 1.12 Removed Lines[] from ReadConfigFile(); added line-num and
#            count info to Values[]
# 2005-10-06 1.12.2 In WriteConfigFile(), skip instances that have been removed
#            from Values[]
# 2005-12-23 1.13 Added DependentOptions()
# 2006-03-13 1.14 Correction to use of Prefix in ReadConfigFile()
# 2006-03-14 1.15 Added Opt2CompSets() and MatchOpt()
# 2006-05-18 1.16 Added OptSel2CompSets(), multiMatchOpt()
# 2006-06-02 1.17 Added Sep parm to Opt2Sets() and Opt2CompSets()
#            Made OptSel2CompSets() not require names in validVars[]
# 2006-08-16 1.18 Fixed & option.
# 2006-11-02 1.19 Added optOrder()
# 2007-11-13 1.19.1 Fixed error in naming of config file in which an error
#            occurred
# 2007-11-14 1.20 Separated expandPathPrefix() from InitOpts() & enhanced it.
# 2007-11-28 1.21 Avoid creating indexes in values[] in multiMatchOpt().
#            Added nullValOK, prefixPat, and varSepPat params to varValOpt().
#            Extended MatchOpt() and multiMatchOpt() to allow test for variable
#            existence.
# 2008-09-08 1.22 Added configFileOpt to Opts().
#            Let numeric values include exponent in the usual form.
# 2009-05-02 1.23 Added Pat param to OptSel2CompSets().
# 2009-07-06 1.23.1 Fixed bug in processing of return value from
#            ReadLogicalLines()
# 2009-11-14 1.24 Added patOrFixed to OptSel2CompSets(); enhanced MatchOpt() to
#            use the match operator type.
# 2010-02-14 1.24.1 Modified Opt2CompSets() to produce output compatible with
#            the enhanced MatchOpt()
# 2010-04-16 1.24.2 On read error, get value of ERRNO before closing file.
#            Corrected ReadConfigFile() to match its documentation:
#            store a null value in Value[] for flags.
# 2010-04-27 1.25 Make OptSel2CompSets() pass varSepPat to varValOpt().
# 2010-05-02 1.26 Replace nullValOK with multiple-meaning noAssignOp.
#            Added noAssignVar to OptSel2CompSets()
#            Let varValOpt(errVar) include a trailing separator string.

# todo: Let gnu-style options (--varname, --varname=value) be given, where
# todo: varname is the variable name as used by Opts().
# todo: Make --help equivalent to -h and implement --version as universal
# todo: option, for help2man.
# todo: Need some way of unsetting options that take values (not just setting
#       them to a null value), so cmd line opts can unset rcfile assignments.
#       Let a value of "-" unset numeric options, and a null string unset
#       strings that are not allowed to be 0 length.
#       For strings that are allowed to b 0 length, maybe +opt (but should be
#       compatible with gnu).
# todo: If -x is given, also print assignments to options that do not have
#       variables.  Maybe make option letter be default variable name.
# todo: Use exclusive-option info to prevent setting of options found in
#       lower-priority sources that are incompatible with options found in
#       higher-priority sources.
# todo: Ignore case in variable names.
# todo: New option/value-name syntax, e.g. "x>debug|r;reports|c=autocase"
#       (varname always required, = specifying a flag) - other flags to
#       indicate whether option should be allowed on
#	cmd-line/rcfile/environment/cgi-environment
# todo: Add some syntax for indicating that a single instance of an option may
#       include multiple values, and the pattern/chars that will separate them.
# todo: If no x option specified, use it to turn on debugging and set global
#       Debug flag.  If no n option, use it to prevent reading of rcfile.
# todo: Opts() should really just set ARGC directly.
# todo: Ability to extract named options from the environment as QUERY_varname
#       instead of just varname, to make use of awk programs directly as cgi
#       programs easier.
# todo: Let integer options take values in alternate bases.
# todo: Add a character type, understanding escape sequences, var. integer
#       value specs, a "path" type that expands leading ~ and $varname, etc.
# todo: Make -? a synonym for -h.

# _procArgv(): Process arguments given on the command line.
# This function retrieves options given as initial arguments on the command
# line.
#
# Strings in argv[] which begin with "-" or "+" are taken to be
# strings of options, except that a string which consists solely of "-"
# or "+" is taken to be a non-option string; like other non-option strings,
# it stops the scanning of argv and is left in argv[].
# An argument of "--" or "++" also stops the scanning of argv[] but is removed.
# If an option takes an argument, the argument may either immediately
# follow it or be given separately.
# "-" and "+" options are treated the same.  "+" is allowed because most awks
# take any -options to be arguments to themselves.  gawk 2.15 was enhanced to
# stop scanning when it encounters an unrecognized option, though until 2.15.5
# this feature had a flaw that caused problems in some cases.  See the
# OptIntroChars parameter to explicitly set the option-introduction characters.
# Note that POSIX 1003.1-2001 generally prohibits introducing options with "+".
#
# Option processing will stop with the first unrecognized option, just as
# though -- or ++ was given except that the unrecognized option will not be
# removed from ARGV[].  Normally an error value is returned in this case,
# but see the description of AllowUnrecOpt.

# Input variables:
# argv[] contains the arguments.
# argc is the number of elements in argv[].
#
# OptParms[] describes the legal options and their type.
# See _parseGetoptsOptList() for further description.
#
# If AllowUnrecOpt is true, it is not an error for an unrecognized option to
# be found as long as it is the first option in an option string; instead
# it simply causes option processing to stop without an error as though the
# argument that contained the unrecognized option did not begin with an option
# introduction character.
#
# If OptIntroChars is not a null string, it is the set of characters that
# indicate that an argument is an option string if the string begins with one
# of the characters.  The default is "-+".  A string consisting solely of two
# of the same option-introduction characters stops the scanning of argv[].

# Output variables:
# Options and their arguments are deleted from argv[].
# Note that this means that there may be gaps left in the indices of argv[].

# All option date is stored in Options[], as follows:
#
# The first time a particular option is given, Options[option-name] and
# Options[option-name,1] are set to the value of the argument given
# for it, and Options[option-name,"count"] is (initially) set to 1.
# If it is given more than once, for the second and later instances
# Options[option-name,"count"] is incremented and the value of the argument
# given for it is assigned to Options[option-name,instance] where instance is 2
# for the second occurrence of the option, etc.
# In other words, the first time an option with a value is encountered, the
# value is assigned both to an index consisting only of its name and to an
# index consisting of its name and instance number; for any further
# occurrences of the option, the value is assigned only to the index that
# includes the instance number.  All values given for an option are stored.
# If a program uses multiple instance of an option but should only pay
# attention to instances that occur in the first venue in which an option is
# found, they must do so explicitly.

# The value of a Boolean (flag) option is 1 if it is given normally, and 0 if
# it is turned off by being followed with a "-". In other words, if -x is
# given, the "x" option gets a value of 1; if -x- is given, the "x" option gets
# a value of 0.  Other than this, the only difference between Boolean options
# and value options is that Options[option-name] is left unset if the first
# instance of an option is one that is turned off.  This allows an option to be
# checked for with the test "if (option-name in Options)", while also allowing
# an option that is turned on in a config file to be turned off on the command
# line.  The values for Boolean options that include instance numbers,
# including that for instance 1, are given the 1 or 0 value.  To explicitly
# check for whether the first instance of an option was turned off (as opposed
# to the option not being given at all), check for instance 1 of it.  This can
# be useful for Boolean options that are turned on by default.

# Options[option-name,"source",instance] is set to the source of data for each
# instance of the option (the venue in which that instance of the option was
# encountered).  The possible values are "f" (config file), "e" (environment),
# "a" (argv[]), and "p" (pseudo-opt).
# If an option is set from a config file, Options[option-name,"file",instance]
# is set to the filename.

# The sequence number for each option is stored in
# Options[option-name,"num",instance], where instance is 1 for the first
# occurrence of the option, etc.  The sequence number tells the position in a
# given venue (source) in which the option occurred; it starts at 1 and is
# incremented for each option found, both those that have a value and those
# that do not.  It starts over at 1 when the next venue is processed.

# Return value:
# The number of arguments left in argv is returned (should always be at least
# 1).
# If an error occurs, the global string _procArgv_err is set to an error
# message and a negative value is returned.
#
# Globals:
# _procArgv_err (see above).
# The last option-introduction character processed is stored in the global
# _optIntroChar for use by error messages.
# Current error values:
# -1: option that required an argument did not get it.
# -2: argument of incorrect type supplied for an option.
# -3: unrecognized (invalid) option.
function _procArgv(argc, argv, OptParms, Options, AllowUnrecOpt, OptIntroChars,

	ArgNum, ArgsLeft, Arg, ArgLen, ArgInd, Option, NumOpt, Value, HadValue,
	NeedNextOpt, GotValue, OptionNum, c, OptTerm, OptIntroCharSet)
{
# ArgNum is the index of the argument being processed.
# ArgsLeft is the number of arguments left in argv.
# Arg is the argument being processed.
# ArgLen is the length of the argument being processed.
# ArgInd is the position of the character in Arg being processed.
# Option is the character in Arg being processed.
# NumOpt is true if a numeric option may be given.
# Value is the value given with an option.
    ArgsLeft = argc
    NumOpt = ("&", "type") in OptParms
    OptionNum = 0
    # Build option specifier sets
    if (OptIntroChars == "")
	OptIntroChars = "-+"
    while (OptIntroChars != "") {
	c = substr(OptIntroChars,1,1)
	OptIntroChars = substr(OptIntroChars,2)
	OptIntroCharSet[c]	# Option introduction character set
	OptTerm[c c]		# Option terminator string set
    }
    for (ArgNum = 1; ArgNum < argc; ArgNum++) {
	Arg = argv[ArgNum]
	if (length(Arg) < 2 || \
	!((_optIntroChar = substr(Arg,1,1)) in OptIntroCharSet))
	    break	# Not an option; quit
	if (Arg in OptTerm) {	# Option list explicitly terminated
	    delete argv[ArgNum]	# Discard Option List Terminator
	    ArgsLeft--
	    break
	}
	ArgLen = length(Arg)
	# For each character in this string after the option intro character...
	for (ArgInd = 2; ArgInd <= ArgLen; ArgInd++) {
	    Option = substr(Arg,ArgInd,1)
	    if (NumOpt && Option ~ /[-+.0-9]/) {
		# If this option is a numeric option, make its flag be &
		Option = "&"
		# Prefix Arg with a char so that ArgInd will point to the
		# first char of the numeric option.
		Arg = "&" Arg
		ArgLen++
	    }
	    # Get type of option.  Disallow & as literal flag.
	    else if (!((Option,"type") in OptParms) || Option == "&") {
		# Unrecognized options may be allowed, but only if they
		# occur at the start of an option string, because there is
		# no means to pass the offset of the problematic option back.
		if (AllowUnrecOpt && ArgInd == 2)
		    return ArgsLeft
		else {
		    _procArgv_err = "Invalid option: " _optIntroChar Option
		    return -3
		}
	    }

	    # Find what the value of the option will be if it takes one.
	    # NeedNextOpt is true if the option specifier is the last char of
	    # this arg, which means that if the option requires a value it is
	    # the following arg.
	    if (NeedNextOpt = (ArgInd >= ArgLen)) {
		# Value is the following arg
		if (GotValue = ((ArgNum + 1) < argc))
		    Value = argv[ArgNum+1]
	    }
	    else {	# Value is included with option
		Value = substr(Arg,ArgInd + 1)
		GotValue = 1
	    }

	    # _assignVal returns: negative value on error,
	    # 0 if option did not require an argument,
	    # 1 if it did & used the whole arg,
	    # 2 if it required just one char of the arg.
	    if (HadValue = _assignVal(Option, Value, Options, OptParms,
		    GotValue, "", ++OptionNum, "a", "", !NeedNextOpt,
		    _optIntroChar)) {
		if (HadValue < 0)	# error occurred
		    return HadValue
		if (HadValue == 2)
		    ArgInd++	# Account for the single-char value we used.
		else {
		    if (NeedNextOpt) {
			# Last option spec was the last char of its arg.
			# Since this option required a value,
			# it took the following arg as value.
			# Discard Option; code we break to will discard value
			delete argv[ArgNum++]
			ArgsLeft--
		    }
		    break	# This option has been used up
		}
	    }
	}
	# Do not delete arg until after processing of it, so that if it is not
	# recognized it can be left in ARGV[].
	delete argv[ArgNum]	# Discard Option or Option Value
	ArgsLeft--
    }
    return ArgsLeft
}

# _parseGetoptsOptList(): Parse a getopts-style option list.
# The option list is a string which contains all of the possible command line
# options.
# A character followed by certain characters indicates that the option takes
# an argument, with type as follows:
# :	String argument
# ;	Non-empty string argument
# *	Numeric argument (may include decimal point and fraction)
# (	Non-negative numeric argument
# )	Positive numeric argument
# #	Integer argument
# <	Non-negative integer argument
# >	Positive integer argument
# The only difference the type of argument makes is in the runtime argument
# error checking that is done.
#
# The & option is a special case used to get numeric options without the
# user having to give an option character.  It is shorthand for [-+.0-9].
# If & is included in optlist and an option string that begins with one of
# these characters is seen, the value given to "&" will include the first
# char of the option.  & must be followed by a type character other than ":"
# or ";".
# Note that if e.g. &> is given, an option of -.5 will produce an error.
# Also note that POSIX 1003.1-2001 generally prohibits options consisting of
# digit-strings.

# In addition to letters and numerals, @%_=,./ are reasonable characters to
# use as options.

# Input variables:
#
# OptList is the getopts-style option list.
#
# Output variables:
#
# For each option specified, the type of the option is stored in OptParms[] by
# assigning values to various indexes of the form OptParms[option-letter,parm]
# as follows:
#
#  Type  Indexes set
# -----  ----------------------------
#  flag  "type" = "flag"
#     :	 "type" = "string", "minlen" = 0
#     ;	 "type" = "string", "minlen" = 1
#     *	 "type" = "number"
#     (	 "type" = "number", "ge" = 0
#     )	 "type" = "number", "gt" = 0
#     #	 "type" = "integer"
#     <	 "type" = "integer", "ge" = 0
#     >	 "type" = "integer", "gt" = 0
#
# Return value:
# On success, a null string.
# On failure, an error description.
function _parseGetoptsOptList(OptList, OptParms,

	i, len, optChar, typeChar, type)
{
    len = length(OptList)
    for (i = 1; i <= len; i++) {
	optChar = substr(OptList, i, 1)
	if (index(":;*()#<>-+|", optChar))
	    return "Disallowed option character: " optChar
	else {
	    typeChar = substr(OptList, i+1, 1)
	    if (typeChar == "")	# end of string
		type = "flag"
	    else if (index(":;", typeChar)) {
		type = "string"
		if (typeChar == ":")
		    OptParms[optChar, "minlen"] = 0
		else
		    OptParms[optChar, "minlen"] = 1
	    }
	    else if (index("*()", typeChar))
		type = "number"
	    else if (index("#<>", typeChar))
		type = "integer"
	    else
		type = "flag"
	    if (optChar == "&" && type != "integer" && type != "number")
		return "Option & must have integer or number type"
	    if (index("(<", typeChar))
		OptParms[optChar, "ge"] = 0
	    else if (index(")>", typeChar))
		OptParms[optChar, "gt"] = 0
	    OptParms[optChar, "type"] = type
	    i += type != "flag"
	}
    }
    return ""
}

# _parseVarDesc(): Parse a variable description.
# Variable descriptions have this format:
# option-character,option-name,option-type[,extra-parameter-name=value,...]
# option-character is a single character that may be used to give the option
#     on the command line either in traditional POSIX syntax
#     (-option-letter[value]) or in GNU-style syntax (--option-letter[=value])
# option-name is a name that may be used to give the option in any venue:
#    on the command line as a GNU-style option, in a config file, or (if
#    allowed) in the environment.
# At least one of option-character and option-name must be given.
#     If a single-character option-name is given, it must not be the same as
#     the option-character for any other option.
# option-type is the type of the option.  It is required.  The types are:
#     string - any string
#     number - any number representable in a double
#     integer - any whole number representable in an int
# Any parameters given after the third have the form "name=value".
#     Only specific names are allowed, and some names are only allowed for
#     certain types.
#     The parameters that may be specified are:
#     ge: A value that a number/integer must be greater than or equal to
#     gt: A value that a number/integer must be greater than
#     minval: A mininum length for strings
#     sources: A string of characters represending the venues in which the
#         option-name may be given.  If not given, the option may be given
#         either in a config file (if any are specified) or on the command
#         line.  The characters are:
#         f: The option may be specified in a config file
#         a: The option may be given as an argument on the command line
#         e: The option may be given in the environment
#
# Input variables:
# varDesc is the variable description.
#
# Output variables:
# The option parameters are stored in OptParms[].

# For each option specified, the type of the option is stored in OptParms[] by
# assigning values to various indexes of the form OptParms[option-letter,parm]
# as follows:
#
# !!! Fill this in
#
# Return value:
# On success, a null string.
# On failure, a string describing the problem.
function _parseVarDesc(varDesc, OptParms,

	parms, parmFields, numFields, char, name, type, pos, parmName, val,
	source, i, len, optNum, fieldNum)
{
    numFields = split(varDesc, parmFields, ",")
    char = parmFields[1]
    name = parmFields[2] 
    type = parmFields[3]
    if (char == "" && name == "" || type == "")
	return "Invalid option description; "\
		"must include a type and a character or name"
    if (type != "string" && type != "number" && type != "integer")
	return "Invalid type (must be string, number, or integer): " type
    parms["type"] = type

    # Process parameters and check the values assigned to them.
    # The results are stored in parms[] and in the variable "source".
    for (fieldNum = 4; fieldNum <= numFields; fieldNum++) {

	# Split parameter into name and value
	parmName = parmFields[fieldNum]
	pos = index(parmName, "=")
	if (!pos)
	    return "No value assigned to parameter \"" parmName "\""
	val = substr(parmName, pos+1)
	parmName = substr(parmName, 1, pos-1)

	if (parmName == "ge" || parmName == "gt") {
	    if (type != "integer" && type != "number")
		return "Parameter \"" parmName \
			"\" cannot be applied to type " type
	    if (val !~ /^[-+]?([[:digit:]]+\.?|[[:digit:]]*\.[[:digit:]]+)([eE][-+][[:digit:]]+)?$/)
		return "Parameter \"" parmName "\" must have numeric value"
	    parms[parmName] = val+0
	}
	else if (parmName == "minlen") {
	    if (type != "string")
		return "Parameter \"" parmName \
			"\" cannot be applied to type " type
	    if (val !~ /^\+?[0-9]+$/)
		return "Parameter \"" parmName \
			"\" must have non-negative integer value"
	    parms[parmName] = val+0
	}
	else if (parmName == "sources") {
	    if (val !~ /^[fae]+$/)
		return "Parameter \"" parmName "\" must have a value "\
			"consisting of one or more of the letters: fae"
	    source = val
	}
	else
	    return "Unknown parameter name \"" parmName "\""
    }

    optNum = ++OptParms["numopts"]
    if (char != "") {
	if (index(":;*()#<>-+|", char))
	    return "Disallowed option character: " char
	OptParms[char,"arg"]
	_storeParms(char, parms, OptParms)
	OptParms["options", optNum, "char"] = char
    }
    if (name != "") {
	if (name !~ /^[[:alnum:]][-_[:alnum:]]*$/)
	    return "Invalid option name: " name
	# Named parameters may by default be given in a file or on the command
	# line.
	if (source == "")
	    source = "fa"
	len = length(source)
	for (i = 1; i <= len; i++)
	    OptParms[char,substr(source,i,1)]
	_storeParms(name, parms, OptParms)
	OptParms["options", optNum, "name"] = name
    }
    if (char != "" && name != "") {
	OptParms[char,"alt"] = name
	OptParms[name,"alt"] = char
    }
    return ""
}

function _storeParms(name, parms, out,

	parm)
{
    for (parm in parms)
	out[name, parm] = parms[parm]
}

# _assignVal(): Store an option.
# Assignment to values in Options[] occurs only in this function.
#
# Input variables:
# Option: Option specifier character.
# Value: Value to be assigned to option, if it takes a value.
# OptParms[]: Option descriptions.  See _parseGetoptsOptList().
# GotValue: Whether any value is available to be assigned to this option.
# Name: Name of option being processed.
# OptionNum: Sequence number of this option (starting with 1) for the source it
#     comes from.  For example, each option found on the command line should
#     get a successive integer, as should each option found in a given config
#     file.
# SingleOpt: true if the value (if any) that is available for this option was
#     given as part of the same command line arg as the option.  Used only for
#     options from the command line.
# specGiven is the option specifier character used, if any (e.g. - or +),
#     for use in error messages.
#
# Output variables:
# Options[]: Options array to return values in.
#
# Global variables:
# On failure, a description of the error is stored in _procArgv_err
#
# Return value:
# On success:
# 0 if option did not require an argument
# 1 if option did require an argument and used the entire argument
# 2 if option required just one character of the argument
# On failure: A negative value.
# Current error values:
# -1: Option that required an argument did not get it.
# -2: Value of incorrect type supplied for option.
# -3: Assertion failure
function _assignVal(Option, Value, Options, OptParms, GotValue, Name,
	OptionNum, Source, File, SingleOpt, specGiven,

	Instance, UsedValue, Err, numericType, type)
{
    if (!((Option,"type") in OptParms)) {
	# This should never happen
	_procArgv_err = "_assignVal(): No type for option \"" Option "\"!"
	return -3
    }
    type = OptParms[Option, "type"]
    numericType = type == "integer" || type == "number"
    # If argument is of any of the types that takes a value...
    if (type != "flag") {
	if (!GotValue) {
	    if (Name != "")
		_procArgv_err = "Variable requires a value -- " Name
	    else
		_procArgv_err = "option requires an argument -- " Option
	    return -1
	}
	if ((Err = _checkValue(OptParms,Value,Option,Name,specGiven)) != "") {
	    _procArgv_err = Err
	    return -2
	}
	# Mark this as a numeric variable; will be propagated to Options[] val.
	if (numericType)
	    Value += 0
	UsedValue = 1
    }
    else {	# Option is a flag
	if (Source != "a" && Value != "") {
	    # If this is an environ or rcfile assignment & it was given a value
	    # despite being a flag...
	    Value = !(Value == "0" || Value == "-")
	    UsedValue = 1
	}
	else if (OptionNum && SingleOpt && substr(Value,1,1) == "-") {
	    # If this is a command line flag and has a - following it in the
	    # same arg, the flag is being turned off.
	    Value = 0
	    UsedValue = 2
	}
	else {
	    # If this is a flag assignment w/o a value, it is being turned on.
	    Value = 1
	    UsedValue = 0
	}
    }
    if ((Instance = ++Options[Option,"count"]) == 1 &&
	    (type != "flag" || Value))
	Options[Option] = Value
    Options[Option,Instance] = Value

    Options[Option,"num",Instance] = OptionNum
    Options[Option,"source",Instance] = Source
    if (Source == "f")
	Options[Option,"file",Instance] = File
    return UsedValue
}

# _checkValue is used to check that an appropriate value is assigned to an
# option that takes a value.
# OptChar is the option letter
# Value is the value being assigned
# Name is the var name of the option, if any
# OptParms[] describes the options
# specGiven is the option specifier character use, if any (e.g. - or +),
#     for use in error messages.
# Return value:
# Null on success, error string on error
function _checkValue(OptParms, Value, OptChar, Name, specGiven,

	Err, ErrStr, V, type, minlen, ge, gt)
{
    type = OptParms[OptChar, "type"]
    if (type == "string") {
	if (length(Value) < (minlen = OptParms[OptChar,"minlen"]))
	    if (minlen == 1)
		Err = "must be a non-empty string"
	    else
		Err = "must be a string of length at least " minlen
    }
    else if (type != "integer" && type != "number")
	# This should never happen
	return "_checkValue(): Invalid type \"" type "\" for option \"" \
		OptChar "\"!"
    # All remaining types are numeric.
    # A number begins with optional + or -, and is followed by a string of
    # digits or a decimal with digits before it, after it, or both
    else if (Value !~ /^[-+]?([[:digit:]]+\.?|[[:digit:]]*\.[[:digit:]]+)([eE][-+][[:digit:]]+)?$/)
	Err = "must be a number"
    else if (type == "integer" && index(Value,"."))
	Err = "may not include a fraction"
    else {
	V = Value + 0
	if ((OptChar, "gt") in OptParms)
	    gt = OptParms[OptChar, "gt"]
	else if ((OptChar, "ge") in OptParms)
	    ge = OptParms[OptChar, "ge"]
	if (V < 0 && ge != "" && ge == 0)	# >= 0
	    Err = "may not be negative"
	else if (V <= 0 && gt != "" && gt == 0)	# > 0
	    Err = "must be a positive number"
	else if (ge != "" && V < ge)
	    Err = "must be a number >= " ge
	else if (gt != "" && V <= gt)
	    Err = "must be a number > " gt
    }
    if (Err != "") {
	ErrStr = "Bad value \"" Value "\".  Value assigned to "
	if (Name != "")
	    return ErrStr "variable " substr(Name,1,1) " " Err
	else {
	    if (OptChar == "&")
		OptChar = Value
	    return ErrStr "option " specGiven substr(OptChar,1,1) " " Err
	}
    }
    else
	return ""
}

# Note: only the above functions are needed by _procArgv.
# The rest of these functions call _procArgv() and also do other
# option-processing stuff.

# Opts: Process command line arguments.
# Opts processes command line arguments using _procArgv()
# and checks for errors.  If an error occurs, a message is printed
# and the program is exited.
#
# Input variables:
# Name is the name of the program, for error messages.
# Usage is a usage message, for error messages.
# OptList the option description string, as used by _procArgv().
# MinArgs is the minimum number of non-option arguments that this
# program should have, non including ARGV[0] and +h.
# If the program does not require any non-option arguments,
# MinArgs should be omitted or given as 0.
# rcFiles, if given, is a colon-seprated list of filenames to read for
# variable initialization.  If a filename begins with ~/, the ~ is replaced
# by the value of the environment variable HOME.  If a filename begins with
# $, the part from the character after the $ up until (but not including)
# the first nonalphanumeric character will be searched for in the
# environment; if found its value will be substituted, if not the filename will
# be discarded.
# rcfiles are read in the order given.
# Values given in them will not override values given on the command line,
# and values given in later files will not override those set in earlier
# files, because _assignVal() will store each with a different instance index.
# The first instance of each variable, either on the command line or in an
# rcfile, will be stored with no instance index, and this is the value
# normally used by programs that call this function.
# VarNames is a comma-separated list of variable names to map to options,
# in the same order as the options are given in OptList.
# If EnvSearch is given and nonzero, the first EnvSearch variables will also be
# searched for in the environment.  If set to -1, all values will be searched
# for in the environment.  Values given in the environment will override
# those given in the rcfiles but not those given on the command line.
# NoRCopt, if given, is an additional letter option that if given on the
# command line prevents the rcfiles and environment from being read.
# configFileOpt can be used to specify an option that sets the configuration
# file list.  If the option letter is preceded by a ":" and the option is
# given, the named configuration file is required to exist.
# See _procArgv() for a description of AllowUnRecOpt and optIntroChars, and
# ExclusiveOptions() for a description of exOpts.
# Special options:
# If x is made an option and is given, some debugging info is output.
# h is assumed to be the help option.

# Global variables:
# The command line arguments are taken from ARGV[].
# The arguments that are option specifiers and values are removed from
# ARGV[], leaving only ARGV[0] and the non-option arguments, with the
# non-option arguments moved down so that they start at index 1.
# The number of elements in ARGV[] should be in ARGC.
# After processing, ARGC is set to the number of elements left in ARGV[].
# The option values are put in Options[].
# On error, Err is set to a positive integer value so it can be checked for in
# an END block.
# _procArgv_err may be set by this function, and is also used by it when it is
# set by other functions (InitOpts()).
# Return value: The number of elements left in ARGV is returned.
# todo: Maybe make variable names case-independent?
function Opts(Name, Usage, OptList, MinArgs, rcFiles, VarNames, EnvSearch,
	NoRCopt, AllowUnrecOpt, optIntroChars, exOpts, configFileOpt,

	Var, Var2Char, VarInfo, ArgsLeft, e, Debug, OptParms, errStr,
	configFileMustExist)
{
    if (MinArgs == "")
	MinArgs = 0
    if (substr(configFileOpt, 1, 1) == ":") {
	configFileMustExist = 1
	configFileOpt = substr(configFileOpt, 2)
    }
    if ((errStr = _parseGetoptsOptList(OptList NoRCopt configFileOpt (configFileOpt == "" ? "" : ";"), OptParms)) != "") {
	printf "%s: Option list specification error: %s.\n",
		Name, errStr > "/dev/stderr"
	Err = 1
	exit 1
    }
    # Process command line arguments
    ArgsLeft = _procArgv(ARGC, ARGV, OptParms, Options, AllowUnrecOpt,
			optIntroChars)
    if ("x" in Options) {
	Debug = Options["x"]
	if (Debug == "")
	    Debug = 1
    }
    else
	Debug = 0
    if (ArgsLeft < (MinArgs+1) && !("h" in Options)) {
	if (ArgsLeft >= 0) {
	    _procArgv_err = "Not enough arguments"
	    Err = 4
	}
	else
	    Err = -ArgsLeft
	print mangleHelp(sprintf("%s: %s.\nUse -h for help.\n%s",
	Name,_procArgv_err,Usage)," \t\n[") > "/dev/stderr"
	exit 2
    }
    if (ArgsLeft > 1)
	paPackArr(ARGV,ArgsLeft-1,1)

    split("",Var2Char);	# Let awk know this is an array
    split("",VarInfo);	# Let awk know this is an array
    mkVarMap(OptList,VarNames,EnvSearch,Var2Char,VarInfo)

    # Process environment & rcfiles
    if (configFileOpt in Options)
	rcFiles = Options[configFileOpt]
    if (rcFiles != "" && (NoRCopt == "" || !(NoRCopt in Options)) &&
    (e = InitOpts(rcFiles,Options,Var2Char,OptParms,VarInfo,Debug,
	    configFileMustExist)) < 0) {
	print Name ": " _procArgv_err ".\nUse -h for help." > "/dev/stderr"
	Err = -e
	exit 2
    }
    if (Debug)
	for (Var in Var2Char)
	    if (Var2Char[Var] in Options)
		printf "(%s) %s=%s\n",
		Var2Char[Var],Var,Options[Var2Char[Var]] > "/dev/stderr"
	    else
		printf "(%s) %s not set\n",Var2Char[Var],Var > "/dev/stderr"
    if ((exOpts != "") &&
	    ((_procArgv_err = ExclusiveOptions(exOpts,Options)) != ""))
    {
	printf "%s: Error: %s\n",Name,_procArgv_err > "/dev/stderr"
	Err = 1
	exit 2
    }
    return ArgsLeft
}

# Packs Arr[], which should have integer indices starting at or above n,
# to contiguous integer indices starting with n.
# If n is not given it defaults to 0.
# Num should be the number of elements in Arr.
function paPackArr(Arr, Num, n,

	NewInd, OldInd)
{
    NewInd = OldInd = n+0
    for (; Num; Num--) {
	while (!(OldInd in Arr))
	    OldInd++
	if (NewInd != OldInd) {
	    Arr[NewInd] = Arr[OldInd]
	    delete Arr[OldInd]
	}
	OldInd++
	NewInd++
    }
}

# mangleHelp(): Convert a help message so that options are displayed with
# the appropriate option introduction character.
# If the last option given was introduced with "+" or this is awk and no
# options were given, convert -x options in a help message to +x.
# If whitespace is non-null, it is the set of characters that may precede an
# option indicator to indicate that it is such.
# The default is newline, space, or tab.
# -x options may be escaped so that they are not acted on by preceding them
# with "\".  All instances of \- are converted to -.
# The output will *not* have a trailing newline, even if the input did.
function mangleHelp(message, whitespace,

	i, wChar, elem, j, n)
{
    if (_optIntroChar == "+" || _optIntroChar == "" && ARGV[0] == "awk") {
	if (whitespace == "")
	    whitespace = " \t\n"
	# For each possible whitespace character...
	for (i = 1; (wChar = substr(whitespace,i,1)) != ""; i++) {
	    n = split(message,elem,"\\" wChar "-")
	    message = elem[1]
	    # Replace all -x except -- with +x
	    for (j = 2; j <= n; j++)
		if (substr(elem[j],1,1) == "-")
		    message = message wChar "-" elem[j]
		else
		    message = message wChar "+" elem[j]
	}
    }
    # The \-x -> -x conversion needs to be done regardless of whether the
    # option introduction characters are being converted.
    # gsub is done line at a time rather than on the whole message at once
    # because some awks die when trying to do a gsub on a very long string.
    # Yuck!
    n = split(message,elem,"\n")
    if (elem[n] == "")
	n--
    message = ""
    for (i = 1; i <= n; i++) {
	gsub(/\\-/,"-",elem[i])
	message = message elem[i]
	if (i < n)
	    message = message "\n"
    }
    return message
}

# Remove all of the options in optList from a "Usage:" (not help) message.
function elideOpts(optList, usageMessage,

	i, c, len)
{
    len = length(optList)
    for (i = 1; i <= len; i++) {
	c = substr(optList,i,1)
	# Remove character from flags list
	usageMessage = \
		gensub("(\\[[^<>]*)" c "([^<>]*\\])","\\1\\2",1,usageMessage)
	# Remove option + value description, e.g. [-optname<option-desc>]
	sub("\\[-" c "[^]]*\\] *","",usageMessage)
    }
    # Remove empty flags lists
    gsub(/-?\[-?\] */,"",usageMessage)
    # Remove now-empty lines
    gsub(/\n[ \t]+\n/,"\n",usageMessage)
    return usageMessage
}

# ReadConfigFile(): Read a file containing var/value assignments, in the form
# <variable-name><assignment-char><value>.
# Whitespace (spaces and tabs) around a variable (leading whitespace on the
# line and whitespace between the variable name and the assignment character)
# is stripped.  Lines that do not contain an assignment operator or which
# contain a null variable name are ignored, other than possibly being noted in
# the return value.
# Input variables:
# File is the file to read.
# AssignOp is the assignment string.  The first instance of AssignOp on a line
#     separates the variable name from its value.
# If StripWhite is true, whitespace around the value (whitespace between the
#     assignment char and the value, and whitespace at the end of the logical
#     line) is stripped.
# VarPat is a pattern that variable names must match.
#     Example: "^[[:alpha:]][[:alnum:]]+$"
#     It should ensure that variable names cannot include SUBSEP.
# If FlagsOK is true, variables are allowed to be "set" by being put alone on
#     a line; no assignment operator is needed.  These variables are set in
#     the output array with a null value.  Lines containing nothing but
#     whitespace are still ignored.
# If Debug is true, debugging information is printed.
# Prefix can be used to set a common index prefix for all information stored
#     in the output arrays (see the description of Values[]).
# Comment, Escape, Quote: See ReadLogicalLine().
# ReturnAll: See ReadLogicalLine().  If ReturnAll is used, empty lines are
#     treated as null assignments to the null variable name and comments are
#     treated as assignments to a variable whose name is the comment character,
#     with the value being the entire comment including the comment character
#     (but without any leading space that occurred before the comment
#     character).
# Output variables:
# None of these arrays is initially cleared, so ReadConfigFile() can be used to
# process multiple files in succession as though they were a single file.
# Values[] contains the assignments.  The first time an assignment to a given
#     variable name is encountered, it is stored under two indexes,
#     <variable-name> and <variable-name>,1.  Any further assignments to a
#     given variable are stored under <variable-name>,<instance-number>.
#     Values[<variable-name>,"num"] is set to the number of times a given
#     variable was encountered (the highest index used).
#     Values[<variable-name>,"lnum"] and
#     Values[<variable-name>,<instance-number>,"lnum"] are set to the line
#     number that a given variable assignment occurred on.  A flag set is
#     recorded by giving it an "lnum"-style index only. 
#     All indexes are prefixed with Prefix.
# Counts[<variable-name>] is set to the number of times a given variable was
#     encountered.  Its indexes form the set of all variable names encountered.
#     All indexes are prefixed with Prefix.
# Order[] records the order in which variables are seen.  For each variable
#     name seen, Order[n] is set to that variable name (prefixed with Prefix),
#     where n is an integer progressing from 1 and gives the order in which the
#     variable was first seen relative to other variable names.
#     For each assignment seen, Order["instance",m] is set to
#     [varname SUBSEP instance] (prefixed with Prefix), where m is as for n but
#     counted separately, and instance is the instance number for varname.  The
#     total number of assignments (the last value of m used) is stored in
#     Order["num"]
# Return value:
# If any errors occur, a string consisting of descriptions of the errors
# separated by newlines is returned, with each string preceded by a numeric
# value and a colon.  The following strings may change and new values may be
# added but the currently assigned numeric values will not:
# -1:IO error reading from file
# -2:Bad variable name
# -3:Bad assignment
# -4:Last line of file ended with line escape char or within quoted section
# If no errors occur, the number of physical lines read is returned.
function ReadConfigFile(Values, Counts, File, Comment, AssignOp, Escape, Quote,
	StripWhite, VarPat, FlagsOK, Debug, Prefix, ReturnAll, Order,

	Line, Errs, AssignLen, LineNum, Var, Val, inLines, lineNums, num, Pos,
	instance, i, varNum, instanceNum)
{
    split("",inLines)	# let awk know this is an array
    split("",lineNums)	# let awk know this is an array
    Errs = ""
    AssignLen = length(AssignOp)
    if (VarPat == "")
	VarPat = "."	# null varname not allowed
    num = ReadLogicalLines(File, Comment, Escape, Quote, inLines, lineNums,
	    Debug, ReturnAll)
    if ((num+0) < 0)
	return num
    if (Debug)
	printf "Processing %d lines from configuration file %s\n", num, File > "/dev/stderr"
    for (i = 1; i <= num; i++) {
	Line = inLines[i]
	if (ReturnAll && substr(Line,1,1) == Comment) {
	    Var = "#"
	    Val = Line
	    Pos = 1
	}
	else {
	    Pos = index(Line,AssignOp)
	    if (Pos) {
		Var = substr(Line,1,Pos-1)
		Val = substr(Line,Pos+AssignLen)
		if (StripWhite) {
		    sub("^[ \t]+","",Val)
		    sub("[ \t]+$","",Val)
		}
	    }
	    else {
		Var = Line	# If no value, var is entire line
		Val = ""
	    }
	}
	LineNum = lineNums[i]
	if (!FlagsOK && Val == "") {
	    Errs = Errs \
		    sprintf("\n-3:Bad assignment on line %d of file %s: %s",
		    LineNum,File,Line)
	    continue
	}
	sub("[ \t\n]+$","",Var)	# Remove trailing whitespace from varname
	if (Var !~ VarPat && !(ReturnAll && (Var == "" || Var == Comment))) {
	    Errs = \
	    Errs sprintf("\n-2:Bad variable name on line %d of file %s: %s",
	    LineNum,File,Var)
	    continue
	}
	if ((instance = Counts[Prefix Var] = ++Values[Prefix Var,"num"]) == 1) {
	    Values[Prefix Var,"lnum"] = LineNum
	    Values[Prefix Var] = Val
	    Order[++varNum] = Prefix Var
	}
	Values[Prefix Var,instance,"lnum"] = LineNum
	Order["instance",++instanceNum] = Prefix Var SUBSEP instance
	Values[Prefix Var,instance] = Val
    }
    if (instanceNum)
	Order["num"] = instanceNum
    return (Errs == "") ? LineNum : substr(Errs,2)	# Skip first newline
}

# Write out the contents of a config file as read by ReadConfigFile().
# If ReadConfigFile() was not given a true value for ReturnAll, blank lines
# and comment lines will not be available for writing.
# The effect of reading a file with ReadConfigFile() and then writing it out
# with WriteConfigFile() will be a file that will give the same results when
# read again by ReadConfigFile().
# The raw file contents will reflect various canonicalizations, including:
#     Blank lines will have no contents
#     Comment lines will have no leading whitespace
#     If a quote character is given, quoting will be used instead of escaping
#         for all quoting purposes other than quoting the quote character.
#	  By default, values are quoted if they contain the escape character,
#         the quote character, or newlines.  Use noQuotePattern to expand this
#         to include other whitespace, etc.
# The specific instance number of each variable given in Values is used (that
#     is, the indexes of the form varname,instance-number).  Instances that
#     have been removed from Values[] (but are still listed in Order[]) are
#     not written.
# Input variables:
# Values[] and Order[] are as returned by ReadConfigFile().
# Comment, AssignOp, Escape, and Quote are as passed to ReadConfigFile().
# File is the name of the file to write to.
# If noQuotePattern is given, any value that does not match noQuotePattern will
# be quoted.
# Example:
# WriteConfigFile(Values, filename, "#", "=", "\\", "\"", Order,
#         "^[-[:alnum:]!@%_+=:,.]*$")
# In this example, values do not require quoting if they consist entirely of
# alphanums or characters from: !@%_+=:,. (safe for ksh evaluation)
function WriteConfigFile(Values, File, Comment, AssignOp, Escape, Quote, Order,
	noQuotePattern,

	i, ind, var, value)
{
    for (i = 1; ("instance",i) in Order; i++) {
	ind = Order["instance",i]
	if (ind in Values) {
	    var = substr(ind,1,index(ind,SUBSEP)-1)
	    value = Values[ind]
	    if (var != "" && var != Comment) {
		if (Quote != "" && Escape != "") {
		    if (index(value, Escape) || index(value, Quote) ||
			    index(value, "\n") ||
			    noQuotePattern != "" && value !~ noQuotePattern) {
			gsub(Quote, Escape Quote, value)
			value = Quote value Quote
		    }
		}
		else if (Escape != "") {
		    gsub(Escape, Escape Escape, value)
		    gsub("\n", Escape "\n", value)
		}
		value = var "=" value
	    }
	    print value > File
	}
    }
    return close(File)
}

# ReadLogicalLine: Read a logical line of input from File.  In the simplest
# case, the next physical line is read and returned.  Leading whitespace is
# removed.  Blank lines (lines that are empty or contain nothing but
# whitespace) are skipped.  Reading of a logical line is further modified by
# the following variables:
#
# Comment is the line-comment character.  If it is found as the first non-
# whitespace character on a line, the line is ignored.
#
# Escape is the escape character.  In general, the escape character removes the
# special meaning of the character that follows it; the escape character itself
# is removed.  Currently, there are three characters with special meanings:
# newlines, quotes, and the escape character itself.  If an escape character is
# followed by a newline, the line is joined to the following line and the
# escape character and newline are removed.  An escape character at the end of
# a comment line does NOT extend the comment line.  A comment character at the
# start of a physical line that is being joined to a previous line does not
# cause the line to be ignored.  If an escape character is followed by another
# escape character, they are replaced by one escape character.  See below for a
# description of escaping a quote character.  If an escape character is
# followed by any other character, the escape character is simply removed.
#
# Quote is the quote character.  From one instance of the quote character to
# the next, newlines are preserved.  If a physical line ends with quoting in
# effect, the next line is joined to it, with a newline embedded between them.
# This is different from escaping a newline; in both cases, the lines are
# joined, but in quotes the newline is preserved while an escaped newline is
# deleted.  Empty lines within quoted sections are not discarded; they result
# in a series of newlines in the returned value.  A quote character may be
# escaped by the escape character either inside or outside of a quoted section;
# an escaped quote character is taken literally, so it neither starts nor ends
# a quoted section.  Within a quoted section, this is the only special meaning
# of the escape character; if the escape character is followed by any other
# character, it is treated as a literal character and included in the returned
# value.
#
# Comment, Escape, and Quote behave roughly like the #, \, and " characters in
# the Bourne shell.  If any of them are null, the associated functionality does
# not exist.
#
# If ReturnAll is true, blank and comment lines will be returned.  Blank lines
# will be returned represented as single newlines regardless of whether or not
# they contained other whitespace.  Comment lines will be returned as lines
# that begin with the comment character, even if it was preceded by whitespace.
#
# Global variables: _rll_start is set to the physical line number that the
# returned logical line started on.  _rll_lnum[] is used to track the current
# line number.
#
# Return value: The logical line read.  At EOF, a null string is returned.  On
# error, a space followed by an error message is returned.  The error message
# begins with a numeric designation, separated from the rest of the message by
# a colon.

function ReadLogicalLine(File, Comment, Escape, Quote, Debug, ReturnAll,

	line, status, out, inQuote, inEsc, c, cPos, quotePos, escPos, lnum,
	errno)
{
    lnum = _rll_lnum[File]
    # Get first line
    while ((status = (getline line < File)) == 1) {
	lnum++
	sub("^[ \t]+","",line)	# discard leading whitespace
	# Skip blank & comment lines (break loop only for content lines)
	if (line != "" && substr(line,1,1) != Comment)
	    break
	else if (ReturnAll) {
	    _rll_lnum[File] = _rll_start = lnum
	    return line == "" ? "\n" : line
	}
	else
	    # Make sure we do not exit with line set to a comment if a comment
	    # is the last line in the file.
	    line = ""
    }
    if (status <= 0) {
	if (Debug > 8)
	    printf "Closing %s (read status %d)\n",File,status > "/dev/stderr"
	errno = ERRNO	# save this because it may be changed by close()
	close(File)
	lnum = _rll_lnum[File] = 0
    }
    if (status < 0)
	return " 1:Error reading from file " File ": " errno
    _rll_start = lnum
    if ((Escape == "" || index(line, Escape) == 0) &&
	    (Quote == "" || index(line, Quote) == 0)) {
	_rll_lnum[File] = lnum
	return line
    }
    inEsc = inQuote = 0
    out = ""
    while (line != "") {
	if (inEsc) {
	    out = out substr(line,1,1)
	    line = substr(line,2)
	    inEsc = 0
	}
	else {
	    if (Quote != "")
		quotePos = index(line, Quote)
	    if (Escape != "")
		escPos = index(line, Escape)
	    cPos = (quotePos > 0 && (escPos == 0 || quotePos < escPos)) ? \
		    quotePos : escPos
	    if (cPos > 0) {
		out = out substr(line,1,cPos-1)
		c = substr(line,cPos,1)
		line = substr(line,cPos+1)
		if (c == Quote)
		    inQuote = !inQuote
		else if (!inQuote || substr(line,1,1) == Quote)
		    inEsc = 1
		else
		    out = out c
	    }
	    else {
		out = out line
		line = ""
	    }
	}
	if (line == "" && (inEsc || inQuote)) {
	    if (inQuote)
		out = out "\n"
            while ((status = (getline line < File)) == 1 && inQuote && \
		    index(line, Quote) == 0) {
		out = out line "\n"
                lnum++
	    }
            if (status == 1)
                lnum++
	    else {
		errno = ERRNO	# save this because it may be changed by close()
		close(File)
		lnum = _rll_lnum[File] = 0
	    }
	    if (status < 0)
		return " -1:Error reading from file " File ":" ERRNO
	    if (!status) {
		if (inEsc)
		    return \
		    " -2:Error in file " File ": Escape character at EOF"
		else
		    return \
		    " -2:Error in file " File ": EOF within quoted section"
	    }
	    inEsc = 0
	}
    }
    _rll_lnum[File] = lnum
    return out
}

# ReadLogicalLines: Read a file and return its contents in Lines[] with one
# logical line per integer index starting at 1.  See ReadLogicalLine()
# for a description of the other parameters.
# The physical line number that each logical line started on is returned in
# LineNums[].
# Return value: On success, the number of logical lines read (the highest
# index in Lines[]).  On failure, a string describing the error, starting with
# a negative number.
function ReadLogicalLines(File, Comment, Escape, Quote, Lines, LineNums, Debug,
	ReturnAll,

	num, line)
{
    num = 0
    while ((line = ReadLogicalLine(File, Comment, Escape, Quote, Debug,
	    ReturnAll)) != "") {
	if (Debug > 9)
	    printf "Got config line: %s\n",line > "/dev/stderr"
	if (substr(line,1,1) == " ")
	    return "-" substr(line,2)
	Lines[++num] = line
	LineNums[num] = _rll_start
    }
    return num
}

# mkVarMap: Make a lookup table to map option variable names to option letters.
#
# Input variables:
#
# OptList, VarNames, and EnvSearch are as described for Opts().
#
# Output variables:
# 
# Var2Char[]: For each variable name in VarNames, an element is stored in
# Var2Char[] that maps that variable name to the corresponding option letter.
#
# VarInfo[]: If OptList specifies a (getopts-style) type character for the
# option, that character is stored in VarInfo[] under the same variable-name
# index.  For variables that should be searched for in the environment (per
# EnvSearch), the index VarInfo[variable-name,"e"] is also created, with no
# value.
#
# Globals, return value: None.

function mkVarMap(OptList, VarNames, EnvSearch, Var2Char, VarInfo,

	NumVars, i, optListInd, Vars, Type, Var)
{
    NumVars = split(VarNames,Vars,",")
    optListInd = 1
    if (EnvSearch == -1)
	EnvSearch = NumVars
    for (i = 1; i <= NumVars; i++) {
	Var = Vars[i]
	Var2Char[Var] = substr(OptList,optListInd++,1)	# Get option letter
	Type = substr(OptList,optListInd,1)		# Get option type
	if (Type ~ "^[:;*()#<>&]$") {
	    VarInfo[Var] = Type
	    optListInd++
	}
	if (i <= EnvSearch)
	    VarInfo[Var,"e"]
    }
}

# Given a path, performs a substitution for certain leading first-component
# values, where the leading component is the part of the path up through the
# first /, or the entire path if the path contains no /
# The substitutions are:
# ~ is replaced with the value of the HOME environment variable.
# $varname is replaced with the value of the varname environment variable,
#     if varname is a legal environment variable name.  If a leading $ is
#     followed by a string that is not a legal environment variable name,
#     no substitution is performed and no error is indicated.
# Input variables:
# path is the path to perform substitutions on.
# If unsetOK is true, it is not an error for a referenced environment variable
#     to not be set.  In this case, its value is taken to be the null value.
# Return value:
# On success, the path with substition (if one is performed) is returned.
# On error, the returned value consists of a null character followed by a
# message describing the error.
# The errors that can occur (if unsetOK is not true) are:
# ~ is used but the HOME environment variable is not set
# A varname is used but the corresponding environment variable is not set
function expandPathPrefix(path, unsetOK,

	firstComponent, envVar, varVal)
{
    firstComponent = path
    sub("/.*", "", firstComponent)
    if (firstComponent == "~")
	envVar = "HOME"
    else if (match(firstComponent, /^\$[_[:alpha:]][_[:alnum:]]*$/))
	envVar = substr(firstComponent, 2)
    if (envVar != "") {
	if (envVar in ENVIRON)
	    varVal = ENVIRON[envVar]
	else if (!unsetOK)
	    return "\0Referenced environment variable not set: $" envVar
	path = varVal substr(path, length(firstComponent) + 1)
    }
    return path
}

# Get variable assignments from environment and rcfiles.
#
# Input variables:
#
# rcFiles is as described for Opts().
#
# Var2Char[] maps variable names to option characters.
#
# OptParms[]: Option parameter information (option type and bounds), as
# generated by _parseGetoptsOptList()/_parseVarDesc() and used by _assignVal().
#
# VarInfo[] maps variable names to type characters, and also indicates whether
# each variable should be searched for in the environment (see mkVarMap()).
#
# Typically, mkVarMap() will be used to convert an option-list and
# variable-name-list into the Var2Char[] and VarInfo[] datasets required by
# this function.
#
# If Debug is true, debugging information is printed to stderr.
#
# If cfMustExist is true, it is an error for a config file to not exist.
#
# Output variables:
#
# Data is stored in Options[].
#
# Global variables:
#
# Sets _procArgv_err.  Uses ENVIRON[].
#
# If anything is read from any of the rcfiles, sets global READ_RCFILE to 1.
#
# Return value: An integer.
#
# On failure, one of the negative values returned by _assignVal(), or -1 for
# other failures.
#
# On success, 0.

function InitOpts(rcFiles, Options, Var2Char, OptParms, VarInfo, Debug,
	cfMustExist,

	Line, Var, Pos, Type, Ret, i, rcFile, fNames, numrcFiles, filesRead,
	Err, Assignments, retStr, variableCounts, OptNum, instance,
	numVarInstances)
{
    split("",filesRead,"")	# make awk know this is an array
    Ret = 0

    # Process environment first, since values assigned there should take
    # priority
    OptNum = 0
    for (Var in Var2Char) {
	if ((Var,"e") in VarInfo && Var in ENVIRON &&
	(Err = _assignVal(Var2Char[Var],ENVIRON[Var],Options,OptParms,1,Var,
		++OptNum,"e")) < 0)
	    return Err
    }

    numrcFiles = split(rcFiles,fNames,":")
    for (i = 1; i <= numrcFiles; i++) {
	rcFile = expandPathPrefix(fNames[i])
	if (substr(rcFile, 1, 1) == "\0") {
	    if (Debug > 0)
		printf "Skipping configuration file %s: %s\n", fNames[i], substr(rcFile, 2) > "/dev/stderr"
	    continue
	}

	# rcfiles are liable to be given more than once, e.g. UHOME and HOME
	# may be the same
	if (rcFile in filesRead)
	    continue
	filesRead[rcFile]

	split("", Assignments)
	split("", variableCounts)
	retStr = ReadConfigFile(Assignments, variableCounts, rcFile, "#", "=", "\\", "\"",
		0, "", 1, Debug)
	if (Debug > 3)
	    printf "Done processing configuration file %s\n", rcFile > "/dev/stderr"
	if ((retStr+0) > 0) {
	    READ_RCFILE = 1
	    READ_RCFILE += 0	# so awklint will not complain about single use
	}
	else if (retStr+0 < (cfMustExist ? 0 : -1)) { # If any failure other than cannot read file
	    sub(/^[^:]*:/,"",retStr)
	    _procArgv_err = retStr
	    Ret = -1
	}
	OptNum = 0
	for (Var in variableCounts)
	    if (Var in Var2Char) {
		numVarInstances = variableCounts[Var]
		for (instance = 1; instance <= numVarInstances; instance++)
		    if ((Err = _assignVal(Var2Char[Var],
			    Var in Assignments ? Assignments[Var,instance] : "",
			    Options, OptParms, Var in Assignments, Var,
			    ++OptNum, "f", rcFile)) < 0)
			return Err
	    }
	    else {
		_procArgv_err = sprintf(\
			"Unknown var \"%s\" assigned to on line %d\n"\
			"of file %s", Var, Assignments[Var,"lnum"],rcFile)
		Ret = -1
	    }
    }
    return Ret
}

# OptSets is a semicolon-separated list of sets of option sets.
# Within a list of option sets, the option sets are separated by commas.  For
# each set of sets, if any option in one of the sets is in Options[] AND any
# option in one of the other sets is in Options[], an error string is returned.
# If no conflicts are found, nothing is returned.
# Example: if OptSets = "ab,def,g;i,j", an error will be returned due to
# the exclusions presented by the first set of sets (ab,def,g) if:
# (a or b is in Options[]) AND (d, e, or f is in Options[]) OR
# (a or b is in Options[]) AND (g is in Options) OR
# (d, e, or f is in Options[]) AND (g is in Options)
# An error will be returned due to the exclusions presented by the second set
# of sets (i,j) if: (i is in Options[]) AND (j is in Options[]).
# todo: make options given on command line unset options given in config file
# todo: that they conflict with.
# todo: Let a null string given for a ; option unset the option.
function ExclusiveOptions(OptSets, Options,

	Sets, SetSet, NumSets, Pos1, Pos2, Len, s1, s2, c1, c2, ErrStr, L1, L2,
	SetSets, NumSetSets, SetNum, OSetNum)
{
    NumSetSets = split(OptSets,SetSets,";")
    # For each set of sets...
    for (SetSet = 1; SetSet <= NumSetSets; SetSet++) {
	# NumSets is the number of sets in this set of sets.
	NumSets = split(SetSets[SetSet],Sets,",")
	# For each set in a set of sets except the last...
	for (SetNum = 1; SetNum < NumSets; SetNum++) {
	    s1 = Sets[SetNum]
	    L1 = length(s1)
	    for (Pos1 = 1; Pos1 <= L1; Pos1++)
		# If any of the options in this set was given, check whether
		# any of the options in the other sets was given.  Only check
		# later sets since earlier sets will have already been checked
		# against this set.
		if ((c1 = substr(s1,Pos1,1)) in Options)
		    for (OSetNum = SetNum+1; OSetNum <= NumSets; OSetNum++) {
			s2 = Sets[OSetNum]
			L2 = length(s2)
			for (Pos2 = 1; Pos2 <= L2; Pos2++)
			    if ((c2 = substr(s2,Pos2,1)) in Options)
				ErrStr = ErrStr "\n"\
				sprintf("Cannot give both %s and %s options.",
				c1,c2)
		    }
	}
    }
    if (ErrStr != "")
	return substr(ErrStr,2)
    return ""
}

# OptSets is a semicolon-separated list of pairs of option sets.
# The sets of each pair are separated by a comma.
# For each pair, if any option in the first element of the pair is in
# Options[], at least one of the options in the second element of the pair must
# be in Options.  If it is not, an error string is returned.
# If any failed dependencies are found, nothing is returned.
# Example: if OptSets = "ab,def;i,j", an error will be returned due to
# a failed dependency if either a or b is given and none of d, e, and f are
# given, or if i is given and j is not given.
# todo: combine this with ExclusiveOptions in some sensible way.
function DependentOptions(OptSets, Options,

	Sets, SetPair, Pos1, Pos2, s1, s2, c1, ErrStr, L1, L2, SetPairs,
	NumSetPairs)
{
    NumSetPairs = split(OptSets,SetPairs,";")
    # For each pair of sets...
    for (SetPair = 1; SetPair <= NumSetPairs; SetPair++) {
	if (split(SetPairs[SetPair],Sets,",") != 2)
	    return "Bad dependent option list given - wrong number of sets in " SetPairs[SetPair] "; should be 2"
	s1 = Sets[1]
	s2 = Sets[2]
	L1 = length(s1)
	L2 = length(s2)
	for (Pos1 = 1; Pos1 <= L1; Pos1++)
	    # If any of the options in the first set was given, check whether
	    # any of the options in the second set was given.
	    if ((c1 = substr(s1,Pos1,1)) in Options) {
		for (Pos2 = 1; Pos2 <= L2; Pos2++)
		    if (substr(s2,Pos2,1) in Options)
			break
		if (Pos2 > L2)
		    ErrStr = ErrStr "\n"\
		    ( (L2 == 1) ? \
			    sprintf("Cannot give %s option unless %s option is given", c1, s2) : \
			    sprintf("Cannot give %s option unless one of these options is given: %s", c1, s2))
	    }
    }
    return substr(ErrStr,2)
}

# The value of each instance of option Opt that occurs in Options[] is made an
# index of Set[].
# If Sep is given, the value of each instance is split on this pattern,
# and each resulting string is treated as a separate value.
# The return value is the number of unique values added to Set[].
function Opt2Set(Options, Opt, Set, Sep,

	OptVals, i, n, tot, val)
{
    n = Opt2Arr(Options, Opt, OptVals, Sep)
    tot = 0
    for (i = 1; i <= n; i++) {
	val = OptVals[i]
	if (!(val in Set)) {
	    Set[val]
	    tot++
	}
    }
    return tot
}

# The value of each instance of option Opt that occurs in Options[] that
# begins with "!" is made an index of nSet[] (with the ! stripped from it).
# Other values are made indexes of Set[].
# If Sep is given, the value of each instance is split on this pattern,
# and each resulting string is treated as a separate value.  In this case,
# a leading ! affects only the value that it immediately precedes.
# The return value is the number of unique values stored.
function Opt2Sets(Options, Opt, Set, nSet, Sep,

	value, aSet, ret)
{
    ret = Opt2Set(Options, Opt, aSet, Sep)
    for (value in aSet)
	if (substr(value,1,1) == "!")
	    nSet[substr(value,2)]
	else
	    Set[value]
    return ret
}

# The value of each instance of option Opt that occurs in Options[] that
# begins with "!" is stored in optData[] under the index "e",n where n
# is an integer starting with 1 ("e" as in "exclusive").
# Other values are stored similarly under the major index "i" (as in
# "inclusive").
# The total number of instances that begin with "!" are stored in optData["e"],
# and the total number that do not are stored in optData["i"].
#
# The return value is the number of instances of Opt in Options.
# optData[] is suitable for passing to MatchOpt().
# If lowcase is true, all values are pushed to lower case.
# If fixed is true, the operation record is a fixed string matching.
#    If not, it is a regular expression matching.
function Opt2CompSets(Options, Opt, optData, lowcase, fixed,

	value, numOpt, OptVals, includerCount, excluderCount, varname)
{
    includerCount = excluderCount = 0
    numOpt = Opt2Arr(Options, Opt, OptVals)
    for (i = 1; i <= numOpt; i++) {
	value = OptVals[i]
	if (lowcase)
	    value = tolower(value)
	if (substr(value,1,1) == "!") {
	    optData["ev", ++excluderCount] = substr(value,2)
	    optData["ep", excluderCount] = !fixed
	}
	else {
	    optData["iv", ++includerCount] = value
	    optData["ip", includerCount] = !fixed
	}
    }
    optData["i"] = includerCount
    optData["e"] = excluderCount
    return includerCount + excluderCount
}

# Generate a set of complementary sets.
# The values assigned to option Opt in Options should be of the form
# varname=value or varname!=value.  If patOrFixed is given (see below),
# varname~value and varname!~value are also allowed.  If noAssignOp is
# 1, the forms varname and !varname are also allowed.
# Data is stored in optData[] as described for Opt2CompSets, but with all
# values prefixed by the variable name followed by SUBSEP.
# Also, optData[1..n] are set to the names of the variables seen.
# varNames[], if passed, is made the set of variable names seen.
# optData[] is suitable for passing to multiMatchOpt().
# If lowcase is true, all values are pushed to lower case.
# If Pat is given, all variable names are required to match it (after
#     being pushed to lower case, if Lower is true).
# If validVars[] contains any elements, then only variables whose names are
#     indexes of validVars[] are considered legitimate.
# If patOrFixed is given, the comparison operator can be either [!]~ or [!]= to
#     specify regular expression or fixed string matching respectively.
#     The indicated operation is recorded in optData.  If patOrFixed is not
#     given, the operator must be [!]=, but is treated as [!]~; that is, the
#     operation recorded is regular expression matching rather than fixed
#     string matching.
# If varSepPat is given, it is treated as a pattern to split varname on.  The
#     result is as though each resulting varname had been given separately.
# If noAssignVar is given and noAssignOp is zero, assignments that do not
#     include an assignment operator are treated as values prefixed by
#     noAssignVar, which should be a variable name followed by an assignment
#     operator.
# On success, a null string is returned.
# On error, an error message is returned.
# To test whether any instances of Opt were passed, use (1 in optData)
function OptSel2CompSets(Options, Opt, optData, lowcase, Pat, validVars,
	varNames, noAssignOp, patOrFixed, varSepPat, noAssignVar,

	varVals, allVarVals, varname, i, numInstance, varNamesGiven, junk,
	value, varNum)
{
    if (varValOpt(Options, Opt, varVals, allVarVals,
	    patOrFixed ? "!?[~=]" : "!?=", lowcase, Pat, noAssignVar,
	    noAssignVar != "" ? 3 : noAssignOp, "!", varSepPat) == -1)
	return _varValOpt_err
    for (junk in validVars) {
	varNamesGiven = 1
	break
    }
    for (varname in varVals) {
	if (varNamesGiven && !(varname in validVars))
	    return "Invalid variable name: " varname
	optData[++varNum] = varname
	varNames[varname]
	numInstance = allVarVals[varname, "count"]
	for (i = 1; i <= numInstance; i++) {
	    value = allVarVals[varname, i]
	    sep = allVarVals[varname, i, "sep"]
	    if (!patOrFixed)
		sub("=", "~", sep)
	    if (sep == "")
		optData[varname, "E"] = allVarVals[varname, i, "prefix"] != "!"
	    else {
		incex = index(sep, "!") ? "e" : "i"
		optData[varname, incex "v", ++optData[varname, incex]] = value
		optData[varname, incex "p", optData[varname, incex ]] = index(sep, "~") != 0
	    }
	}
    }
    return
}

# Match value against the patterns in optData[], which are stored as in
# Opt2CompSets().  The patterns are treated as either fixed strings or standard
# regular expressions, depending on the comparison operator used in the setup.
# If prefix is given, the indexes in optData[] are prefixed with it.
# In order for the return value to be true, value must not match any of the
# exclusive patterns and must match all of the inclusive patterns.  If an
# existence check is given, varGiven must be passed to tell whether the
# variable was seen.  A failed existence check (whether the requirement is that
# the variable does or does not exist) is sufficient to cause a match failure.
# A successful must-exist check is not sufficient to cause a match success;
# this allows a specification that a variable must exist and must have a null
# value, since a null-value pattern by itself will also match a variable that
# is not given.
# Return value:
# 1 for a match, 0 for no match.
function MatchOpt(optData, value, prefix, varGiven,

	includerCount, excluderCount, i)
{
    if ((prefix "E" in optData))
	if (varGiven != optData[prefix "E"])
	    return 0
    excluderCount = optData[prefix "e"]
    for (i = 1; i <= excluderCount; i++)
	if (optData[prefix "ep", i] ? value ~ optData[prefix "ev", i] : value == optData[prefix "ev", i])
	    return 0
    includerCount = optData[prefix "i"]
    for (i = 1; i <= includerCount; i++)
	if (optData[prefix "ip", i] ? value !~ optData[prefix "iv", i] : value != optData[prefix "iv", i])
	    return 0
    return 1
}

# Match values against the patterns in optData[], which are stored as in
# OptSel2CompSets().  The patterns are treated as standard regular expressions.
# values[] should contain strings to match against the patterns, indexed by the
# same variable names that are used as the first index of optData[].
# In order for the return value to be true, value must not match any of the
# exclusive patterns and must match all of the inclusive patterns.
function multiMatchOpt(optData, values,

	varnum, var)
{
    for (varnum = 1; varnum in optData; varnum++) {
	var = optData[varnum]
	if (!MatchOpt(optData, var in values ? values[var] : "", var SUBSEP, var in values))
	    return 0
    }
    return 1
}

# The value of each instance of option Opt that occurs in Options[] is made an
# element of OptVals[], with indexes starting with 1.
# The return value is the number of instances of Opt in Options.
# If Sep is given, the value of each instance is split on this pattern,
# and each resulting string is treated as a separate value.
# Return value: The number of values stored in OptVals[].
function Opt2Arr(Options, Opt, OptVals, Sep,

	numInst, instance, i, nVals, elem, valNum)
{
    if (!(Opt in Options))
	return 0
    i = 0
    numInst = Options[Opt,"count"]
    for (instance = 1; instance <= numInst; instance++)
	if (Sep) {
	    nVals = split(Options[Opt,instance],elem,Sep)
	    for (valNum = 1; valNum <= nVals; valNum++)
		OptVals[++i] = elem[valNum]
	}
	else
	    OptVals[++i] = Options[Opt,instance]
    return i
}

# Returns a list of the options in the string OptList that were given,
# as indicated by the data in Options[].
# If any of Arg, Env, or File are true, the given opts are only considered to
# have been set if they were set in the command line arguments, environment,
# or in a configuration file, respectively.
# The first instance of each option that was set is set in Results[], with the
# values (if any) assigned to it.
# The list of options found is also returned in Results["list"].
function OptsGiven(Options, OptList, Arg, Env, File, Results,

	numOpt, i, Opt, instance, Source, count)
{
    if (!Arg && !Env && !File)
	Arg = Env = File = 1
    numOpt = length(OptList)
    count = 0
    for (i = 1; i <= numOpt; i++) {
	Opt = substr(OptList,i,1)
	for (instance = 1; (Opt,"num",instance) in Options; instance++) {
	    Source = Options[Opt,"source",instance]
	    if (Arg && Source == "a" || File && Source == "f" ||
		    Env && Source == "e") {
		Results[Opt] = Options[Opt,instance]
		Results["list"] = Results["list"] Opt
		count++
		break
	    }
	}
    }
    return Results["list"]
}

# Determine the order in which the options in OptList were given.
# Source specifies the source to examine.  It should consist of one of
# a, e, and f, indicating the argument list, environment, and config files.
# For each option in OptList that was given in the specified source, Order[num]
# is set to the relative position of the first instance of that option, with
#     num starting with 1.
# The number of options found is returned.
# This requires some gawk features.
function optOrder(Options, OptList, Source, Order,

	i, checkOpts, Elem, sInd)
{
    split(OptList, checkOpts, "")
    for (i = 1; i in checkOpts; i++)
	if (checkOpts[i] in Options)
	    Elem[Options[checkOpts[i], "num", 1]] = checkOpts[i]
    asorti(Elem, sInd)
    for (i = 1; i in sInd; i++)
	Order[i] = Elem[sInd[i]]
    return i - 1
}

# A list of options is passed in the string OptList.
# These options are searched for first in the options set on the command
# line; if no such were given, then in the options set in the environment;
# and if no such were given, then in the options set in the configuration
# files.  The resulting options are set in the array Results[], with their
# values (if any) assigned to them.  Only the first instances of options are
# copied to Results[].
# In other words, when a source is found that has any of the options set in it,
# any options set in that source are copied to Results[] and searching ceases.
# Results["list"] is set to the list of options found.
# Return value: Same as Results["list"]
function prioOpt(Options, OptList, Results,

	list)
{
    if ((list = OptsGiven(Options,OptList,1,0,0,Results)) != "")
	return list
    else if ((list = OptsGiven(Options,OptList,0,1,0,Results)) != "")
	return list
    else if ((list = OptsGiven(Options,OptList,0,0,1,Results)) != "")
	return list
    return ""
}

# addPseudoOpt(): Add a pseudo-option.
# Input variables:
# optDesc is the option description.
# Value is the value to assign to it.
# Output variables:
# The option value is stored in Options[]
# Return value:
# On success, a null string.
# On failure, a string describing the error.
function addPseudoOpt(varDesc, Value, Options,

	optParms, err)
{
    if ((err = _parseVarDesc(varDesc, optParms)) != "")
	return "Error in pseudo-option description \"" varDesc "\":\n" err
    if (_assignVal(optParms["options", 1, "char"], Value, Options, optParms, 1,
	    optParms["options", 1, "name"], 0, "p") < 0)
	return _procArgv_err "."
    return ""
}

# varValOpt: Process all instances of an option that takes an option-value of
# the form var=value.
# Input variables:
# Options[] is the option data.
# Opt is the option to process.
# If assignOp is given, it is used as the assignment operator, which separates
#     the variable name from the value.  It defaults to "=", and is treated as
#     a regular expression.
# If Lower is given, all variable names are pushed to lower case.
# If prefixPat is given, any prefix of the varible name that matches it is
#     removed from the variable name.
# If Pat is given, all variable names are required to match it (after
#     being pushed to lower case, if Lower is true).
# If noAssignOp is nonzero, option instances that do not include the assigment
#     operator are allowed.  If noAssign is 1, they are taken to consist
#     entirely of a variable name, with an implicit null value.  If noAssignOp
#     is 2, they are taken to consist entirely of values, with an implicit null
#     variable name.  These cases can be distinguished from instances that do
#     contain an assignment operator with a a null variable name or value by
#     checking the "sep" element described below.  If noAssignOp is 3, these
#     instances are processed as described for errVar, with the difference that
#     errVar will only apply to instances lacking an assignment operator;
#     instances with a bad variable name will result in an abort & error
#     return.
# If errVar is non-null, this function will not abort and return an error if a
#     bad variable name is given or if noAssignOp is zero and an option
#     instance does not include an assignment operator.  Instead, the entire
#     value of the option instance is assigned to the pseudo-variable name
#     given by errVar.  If errVar ends with text that matches assignOp, it
#     specifies the value stored for the "sep" data.  If not, no sep data is
#     stored.
# If varSepPat is given, the part of the option value before the assignment
#     operator is taken to be a list of varnames instead of a single varname,
#     separated by varSepPat.  The value on the righthand side of the
#     assignment operator is assigned to each of the variables named in the
#     list.
# Output variables:
# The results are stored in varVals[] and allVarVals[].
# allVarVals[varname,n] is set to the value given for the nth instance of
#     varname that is encountered.
# allVarVals[varname, n, "sep"] is set to the text that matched the assignment
#     operator pattern.
# If a prefix pattern is given and matched, allVarVals[varname, n, "prefix"] is
#     set to the value matched.
# allVarVals[varname,"count"] is set to the number of instances of varname that
#     are given.
# varVals[varname] is set identically to allVarVals[varname,1].
# For each option processed, allVarVals[,m,n] are set, with m being the option
#     instance number, n being the variable number, and the value being index
#     in allVarVals of the data stored for that variable.  For example, if
#     varSepPat is"," and two instances of Opt were given with values
#     foo,bar=baz and bar=baz, these values would be stored under the given
#     indexes:
#     [,1,1] = "foo" SUBSEP 1
#     [,1,2] = "bar" SUBSEP 1
#     [,2,1] = "bar" SUBSEP 2
# Return value:
# On success, the number of instances of Opt that were encountered.
# On failure, -1.  In this case, the global variable _varValOpt_err is set to a
#     string describing the problem.
# If errVar is passed, no failure return will occur.
function varValOpt(Options, Opt, varVals, allVarVals, assignOp, Lower, Pat,
	errVar, noAssignOp, prefixPat, varSepPat,

	assignment, OptVals, numOpt, optNum, varname, value, prefix, instance,
	vars, varNum, defSep)
{
    if (assignOp == "")
	assignOp = "="
    numOpt = Opt2Arr(Options,Opt,OptVals)
    if (prefixPat != "")
	prefixPat = "^(" prefixPat ")"
    if (match(errVar, assignOp "$")) {
	defSep = substr(errVar, RSTART)
	errVar = substr(errVar, 1, RSTART-1)
    }
    for (optNum = 1; optNum <= numOpt; optNum++) {
	assignment = OptVals[optNum]
	if (prefixPat != "" && match(assignment, prefixPat)) {
	    prefix = substr(assignment, RSTART, RLENGTH)
	    assignment = substr(assignment, RSTART+RLENGTH)
	}
	else
	    prefix = ""
	if (!(match(assignment,assignOp))) {
	    if (noAssignOp == 1) {
		RSTART = length(assignment) + 1
		RLENGTH = 0
	    }
	    else if (noAssignOp == 2) {
		RSTART = 1
		RLENGTH = 0
	    }
	    else if (errVar == "") {
		_varValOpt_err = "No instance of the separator \"" assignOp \
			"\" in this assignment: " assignment
		return -1
	    }
	}
	split("", vars)
	if (RSTART > 0) {
	    varname = substr(assignment,1,RSTART-1)
	    if (Lower)
		varname = tolower(varname)
	    if (varSepPat != "")
		split(varname, vars, varSepPat)
	    else
		vars[1] = varname
	    value = substr(assignment,RSTART+RLENGTH)
	}
	else {
	    vars[1] = errVar
	    value = assignment
	}
	for (varNum = 1; varNum in vars; varNum++) {
	    varname = vars[varNum]
	    if (RSTART > 0 && Pat != "" && varname !~ Pat) {
		if (errVar != "" && noAssignOp != 3)
		    varname = errVar
		else {
		    _varValOpt_err = \
			    "Invalid variable name in this assignment: " \
			    assignment
		    return -1
		}
	    }
	    instance = ++allVarVals[varname, "count"]
	    allVarVals[varname, instance] = value
	    allVarVals["", optNum, varNum] = varname SUBSEP instance
	    if (prefix != "")
		allVarVals[varname, instance, "prefix"] = prefix
	    if (RSTART > 0)
		allVarVals[varname, instance, "sep"] = \
			substr(assignment, RSTART, RLENGTH)
	    else if (defSep != "")
		allVarVals[varname, instance, "sep"] = defSep
	    if (instance == 1)
		varVals[varname] = value
	}
    }
    return numOpt
}
### End-lib ProcArgs
### Begin-lib array
#
# The current version of this library can be found by searching
# http://www.armory.com/~ftp/
#
# Assorted array functions
#
# @(#) array 1.5 2004-10-13
# 1990-1997 john h. dubois iii (john@armory.com)
# 1997-01-26 Added Order parameter to Assign()
# 1997-08-27 Fixed Assign() to work properly with >1char assign-op
# 1999-12-24 Added NoValOK to Assign()
# 2002-01-26 Added getSlice()
# 2002-01-29 1.3 Added VSep parm to Assign()
# 2002-09-28 1.4 Added qsplit(), and Quote parm to Assign()
# 2004-10-13 1.5 Added nv2arr(), parms2arr()

# InitArr(): Initialize an array with values.
# This function takes a list of indices and a list of values and stores each
# value in an array under the index that has a corresponding position.
# Input variables:
# Ind is the list of indices.
# Vals is the list of values.
# Sep is the pattern that separates the indices in Ind and the values in Vals.
# Output variables:
# The array Arr[] is populated with the results.
# Global variables: none.
# Return value: none.
# Example:
# InitArr(Arr, "foo,bar,baz", "val1, val2, val3", ",")
# Result: Arr["foo"] = "val1",  Arr["bar"] = "val2",  Arr["baz"] = "val3"
function InitArr(Arr,Ind,Vals,sep,
	numind,indnames,values) {
    split(Ind,indnames,sep)
    split(Vals,values,sep)
    for (numind in indnames)
	Arr[indnames[numind]] = values[numind]
}

# CopyArr(): Copy an array.
# Input variables:
# From[] is the array to copy.
# Output variables:
# To[] is the array to copy to.  All of the element in From[] are copied to
# To[].  Elements of To[] may be replaced, but no elements in To[] that have
# indexes that do not exist in From[] are touched.
function CopyArr(From,To,
	Elem) {
    for (Elem in From)
	To[Elem] = From[Elem]
}

# SubtractArr(): Subtract the values all of the elements of one array from the
# values having the same indexes in another array.
# Input variables:
# Minuend[] containes the values that will be subtracted from.  Only the
#     elements with indexes that also appear in Subtrahend[] will be
#     referenced.
# Subtrahend[] contains the values that will be subtracted.
# Output variables:
# The subtraction results for each pair of values with a given index are stored
# in Minuend[] under the same index.
# Subtract the values in Subtrahend from those in Minuend
function SubtractArr(Minuend,Subtrahend,
	Elem) {
    for (Elem in Subtrahend)
	Minuend[Elem] -= Subtrahend[Elem]
}

# Invert(): Invert an array: create a new array with indexes equal to the
# values of a source array and values for those indexes equal to the
# corresponding indexes of the source array.
# If multiple input elements have the same value, only one of the indexes of
# those values will appear in the output.
# Input variables:
# src[] is the source array.
# Output variables:
# The results are stored in dest[].
# Return value:
# The number of elements stored in dest.
function Invert(src,dest,
	i, count) {
    for (i in src)
	if (!(src[i] in dest)) {
	    dest[src[i]] = i
	    count++
	}
    return count
}

# PackArr(): Compact an array that has integer indexes so that the indexes are
# contiguous integers.
# Input variables:
# Arr[] is the array to compact.
# Num gives the number of elements in Arr[] to compact.
# Start is the index to begin compacting at.  Compacting proceeds by searching
# upwards from this value.  If Start is not passed, it defaults to 0.
# Output variables:
# Arr[] is returned with integer indexes [Start..Start+Num-1], containing the
# values of the elements of Arr[] that had integer indexes >= Start, in their
# original order.
# Note: If Num is larger than the number of such elements in Arr[], this
# function will not return.
function PackArr(Arr,Num,Start,
	NewInd,OldInd) {
    if (Num < 0)
	return 0
    NewInd = OldInd = Start+0
    for (; Num; Num--) {
	while (!(OldInd in Arr))
	    OldInd++
	if (NewInd != OldInd) {
	    Arr[NewInd] = Arr[OldInd]
	    delete Arr[OldInd]
	}
	OldInd++
	NewInd++
    }
    return 1
}

# getSlice(): Get a slice of an array.
# Given a multidimensional array, get an array that has one less dimension by
# taking a slice through the array where one of the dimensions is set to a
# fixed value.  In the case of a 2-dimensional array, this would return a row;
# in the case of a 3-dimensional array it would return a plane, etc.
# Input variables:
# inArray[] is the source array.
# indNum selects the dimension that will have a fixed value.  Dimensions are
#     numbered from 1 starting at the left.  E.g. in the index [a,b,c], a is
#     dimension 1, b is dimension 2, and c is dimension 3.
# ind gives the value of the fixed dimension.
# sep is the string that separates indexes in inArray[] and outArray[] to
#     create a multidimensional array.  Use SUBSEP to get the default
#     separator.
# Output variables:
# outArray[] is the destination array.  The dimension indexes in it occur in
# the same order that they did in inArray[], with the fixed dimension removed.
function getSlice(inArray,ind,indNum,sep,outArray,
	i,elem,num,j) {
    split("",outArray)
    for (i in inArray) {
	num = split(i,elem,sep)
	if (elem[indNum] == ind) {
	    outInd = ""
	    for (j = 1; j <= num; j++)
		if (j != indNum) {
		    if (outInd != "")
			outInd = outInd sep
		    outInd = outInd elem[j]
		}
	    outArray[outInd] = inArray[i]
	}
    }
}

# Split a string into elements with quoting.
# This is similar to split(), except that inside of a quoted section, quotes
# are not acted on.  Quote characters are not included in the returned values.
#
# Input variables:
#   s is the string to split.
#   sep is the pattern to split on.
#   quote is the quoting character.
#
# Output variables:
#   The elements are returned in elem[1-n].
#   If info[] is passed, information regarding the split is returned in it.
# The current defined elements are:
# info["unterm"]: True if the string ended in the middle of a quoted section.
#
# Return value:
# The number of strings stored in elem.
function qsplit(s, elem, sep, quote, info,
	len, i, c, inquote, e, j, curelem, quoted, unquoted) {
    # Scan s.  Each time a quoted section begins, split the part leads up to it
    # and store it in elem.  When the quoted section ends, attach that to the
    # last element produced by the previous split.
    split("", info)
    split("", elem)
    curelem = 1
    if (sep == " ") {
	gsub(/^[ \t\n]+|[ \t\n]+$/,"",s)
	sep = "[ \t\n]+"
    }
    # Add 1 for end-of-input-string processing
    if ((len = length(s)+1) == 1)
	return 0
    for (i = 1; i <= len; i++) {
	c = substr(s, i, 1)
	if (c == quote || i == len) {
	    if (inquote) {	# End of a quoted section
		elem[curelem] = elem[curelem] quoted
		quoted = ""
	    }
	    else {		# Start of a quoted section
		if (split(unquoted, e, sep)) {
		    curelem--
		    for (j = 1; j in e; j++) {
			curelem++
			elem[curelem] = elem[curelem] e[j]
		    }
		}
		unquoted = ""
	    }
	    inquote = !inquote
	}
	else if (inquote)
	    quoted = quoted c
	else
	    unquoted = unquoted c
    }
    # inquote is toggled at the end
    info["unterm"] = !inquote
    return curelem
}

# Assign: make an array from a list of assignments.
# An index with the name of each variable in the list is created in the array.
# Its value is set to the value given for it.
# Input variables:
# Elements is a string containing the list of variable-value pairs.
# Sep is the string that separates the pairs in the list.
# AssignOp is the string that separates variables from values.
# The first instance of AssignOp is used; if more than one occurs, the 2nd and
# later instances become part of the value.
# If NoValOK is true, elements produced by splitting on Sep that have no
# instance of AssignOp are stored with a null value, using the entire element
# as the variable name.
# If VSep is non-null, variables are split on this pattern, and each name that
# results is assigned the given value.  For example, if Sep is "=" and VSep is
# ",", the string foo,bar=baz will result in Arr["foo"] = Arr["bar"] = "baz"
# If Quote is non-null, it is a quoting character.  Instances of Sep that occur
# in quoted sections are taken literally.
# Output variables:
# Arr is the array.  It is *not* cleared of its previous contents.
# Order[1..n] are set to the variable names in the order they are given.
#   It is cleared of its previous contents.
# Return value:
# The number of elements stored in the array, or -1 on error.
# The only possible error is an element with no AssignOp and NoValOK not true.
# Example:
# Assign(Arr,"foo=blot bar=blat baz=blit"," ","=")
function Assign(Arr, Elements, Sep, AssignOp, Order, NoValOK, VSep, Quote,
	Num, Names, Elem, Assignments, Assignment, i, Var, aLen, Value, Vars,
	nvar, varNum, varName) {
    split("",Order)
    if (Quote == "")
	Num = split(Elements,Assignments,Sep)
    else
	Num = qsplit(Elements,Assignments,Sep,Quote)
    aLen = length(AssignOp)
    varNum = 0
    if (VSep == "")
	# AssignOp is guaranteed not to appear in varnames, so this ensures
	# that each var is treated as a single name
	VSep = AssignOp
    for (i = 1; i <= Num; i++) {
	Assignment = Assignments[i]
	if (Ind = index(Assignment,AssignOp)) {
	    Var = substr(Assignment,1,Ind - 1)
	    Value = substr(Assignment,Ind + aLen)
	}
	else if (NoValOK) {
	    Var = Assignment	# Make var name consist of entire value
	    Value = ""
	}
	else
	    return -1
	nvar = split(Var,Vars,VSep)
	for (; nvar; nvar--) {
	    varName = Vars[nvar]
	    Arr[varName] = Value
	    Order[++varNum] = varName
	}
    }
    return varNum
}

# parms2arr(): Convert a set of parameters into an ordered set of elements in
#     an array.
# Input variables:
# p<n> are the parameter strings.
# If elideEmpty is true, empty parameters are elided.
# Output variables:
# The parameters are stored in arr[], as follows:
# For each parameter, arr[parameter-number] is set to the parameter.
#     parameter-number starts with 1 and is incremented for each parameter.
# Return value: The number of parameters stored.
function parms2arr(elideEmpty, arr, p1, p2, p3, p4, p5, p6, p7, p8,
	src, dest) {
    split("", arr)
    # Convert parms list into array mapping parm values to names
    arr[1] = p1
    arr[2] = p2
    arr[3] = p3
    arr[4] = p4
    arr[5] = p5
    arr[6] = p6
    arr[7] = p7
    arr[8] = p8
    dest = 1
    for (src = 1; src in arr; src++) {
	if (arr[src] != "") {
	    if (src != dest) {
		arr[dest] = arr[src]
		delete arr[src]
	    }
	    dest++
	}
	else {
	    delete arr[src]
	    if (!elideEmpty)
		dest++
	}
    }
    return dest-1
}

# nv2arr(): Convert a set of name=value parameters into an ordered set of
# elements in an array.
# Input variables:
# p<n> are the parameter strings.  They have the format name=value.
#     The names should be unique.
# Null parameter strings are always elided.  If elideEmpty is true,
#     parameters with empty values are also elided.
# Output variables:
# The parameters are stored in arr[], as follows:
#     For each non-empty parameter, arr[name] is set to its value.
#     The parameter names are store indexed by arr["order",parameter-number],
#         where parameter-number starts with 1 and in incremented for each
#         non-empty parameter.
# Example: If called with nv2arr(arr, "foo=bar", "", "biz=baz"),
#     arr will be contain: 
#     arr["foo"] = "bar"
#     arr["biz"] = "baz"
#     arr["order",1] = "foo"
#     arr["order",2] = "biz"
# Return value: The number of parameters stored.
function nv2arr(arr, elideEmpty, p1, p2, p3, p4, p5, p6, p7, p8,
	parms, i, parm, pos, varname, value, num) {
    parms2arr(1, parms, p1, p2, p3, p4, p5, p6, p7, p8)
    for (i = 1; i in parms; i++) {
	parm = parms[i]
	pos = index(parm, "=")
	value = substr(parm,pos+1)
	if (elideEmpty && value == "")
	    continue
	varname = substr(parm,1,pos-1)
	arr[varname] = value
	arr["order", ++num] = varname
    }
    return num
}

### End-lib array
### Begin-lib tinfo
#
# The current version of this library can be found by searching
# http://www.armory.com/~ftp/
#
# @(#) tinfo 1.2.1 2005-10-04
# 1996-11-30 John H. DuBois III (john@armory.com)
# 1998-12-09 1.1 Added :437 magic, non-overwrite of values passed in tinfo[],
#            and tiCapInterp().
# 2002-11-24 1.1.1 Make tiget work reliably in old-awk.
# 2003-07-04 1.2 Started work on tparm()

# tinfo: Some routines for extracting & using capabilities from the terminfo
# database.
#
# tparm() requires gawk for bitwise operations.

# todo: test if-then-else; everything else is at least minimally tested.

# altInit(): Get alternate character set terminfo capabilities.
# term, noerror: see tiget(), except that if the magic termtype ":437" is
# given, instead of querying the terminfo database a built-in alternate
# character set description for the IBM 437 (as used by the PC console, many
# printers, terminals in PC Character Set mode, the Wyse 60, etc.) is used.
# tinfo[] is returned containing the acsc capability, and any of the enacs,
# smacs, and rmacs capabilities that are defined for the terminal.  Each is
# indexed by its capability name.
# acsc is the mapping of vt100 alternate character codes to those appropriate
# for the given terminal.
# enacs is used to enable the alternate character set.
# smacs starts it and rmacs ends it.
# If tinfo[] is passed already containing any of these capabilities, the
# passed strings are used instead of querying the terminfo database for them.
# AltMap is the acsc string broken down with each alternate character indexed
# by its vt100 equivalent.  num is an ordered list of the vt100 characters
# indexed starting with 1, for applications that need to know what order they
# were given in.
# The global _macs[] is set up with _macs[0] = rmacs & _macs[1] = smacs, for
# use by altPrint().
# The alternate characters and their indexes (vt100 equivalents) are:
# 0  solid square block		a  checker board	f  degree symbol
# g  plus/minus			h  board of squares	j  lower right corner
# k  upper right corner		l  upper left corner	m  lower left corner
# n  plus			q  horizontal line	t  left tee
# u  right tee			v  bottom tee		w  top tee
# x  vertical line		+  arrow pointing right	.  arrow pointing down
# -  arrow pointing up		,  arrow pointing left	`  diamond
# ~  bullet			I  lantern symbol	o  scan line 1
# s  scan line 9
function altInit(tinfo, term, noerror, AltMap, num,
	ret, caplist, acsc, len, j, i) {
    if (term == ":437") {
	if (!("acsc" in tinfo))
	    # We avoid the use of the characters in the range 0-31 because many
	    # terminals interpret them as control sequences.  Instead, up and
	    # down arrow and diamond are skipped here, and the double < and
	    # double > symbols are used for left and right arrow.
	    tinfo["acsc"] = "0\333a\261g\361h\262j\331k\277l\332m\300n\305q"\
		    "\304t\303u\264v\301w\302x\263I\350~\372f\370,\256+\257"
    }
    else {
	if (ret = tiget("acsc",tinfo,term,0,1)) {
	    # All other types of errors cause tput to print an informative
	    # message to stderr, which is not redirected.
	    if (!noerror && ret == 1)
		print "Terminal has no acsc capability." > "/dev/stderr"
	    return ret
	}
	caplist = "enacs,smacs,rmacs"
	tiget(caplist,tinfo,term,0,1)
    }
    acsc = tinfo["acsc"]
    len = length(acsc)
    j = 0
    for (i = 1; i < len; i += 2)
	AltMap[num[++j] = substr(acsc,i,1)] = substr(acsc,i+1,1)
    if ("rmacs" in tinfo)
	_macs[0] = tinfo["rmacs"]
    if ("smacs" in tinfo)
	_macs[1] = tinfo["smacs"]
    return 0
}

# altPrint: Print characters in either the alternate or standard character set.
# string is the string to print.
# alt should be 1 if string is in the alternate character set; 0 if in the
# standard character set.
# tinfo contains the smacs and rmacs strings, if needed.
# altPrint keeps track of whether the terminal is in the standard or alternate
# character set, and issues smacs and rmacs as needed.
# It should always be called with alt false at the end of program execution to
# ensure that the terminal is left in the standard character set.
# Globals: The character set is tracked in _altPrintSet
function altPrint(string, alt, tinfo) {
    if (alt != _altPrintSet) {
	printf "%s%s",_macs[alt],string
	_altPrintSet = alt
    }
    else
	printf "%s",string
}

# tiget: get terminfo capabilities.
# capnames is a comma-separated list of terminfo capabilities to get.
# Each capability is put in tinfo[], indexed by capability name.
# If term is passed, it is the terminal type to get the capabilities for.
# If not, the value of the environment variable TERM is used.
# If noerror is true, error messages are suppressed.
# If nooverwrite is true and tinfo[] already has an index for a given
#     capability, the value is not overwriten.
# Return value: the exit status of the last tput, or -1 if term is not passed
# and there is no TERM environment variable.
function tiget(capnames, tinfo, term, noerror, nooverwrite,
	cmd, ret, names, capname, i, oRS, cap) {
    if (term == "")
	if ("TERM" in ENVIRON)
	    term = ENVIRON["TERM"]
	else
	    return -1
    split(capnames,names,",")
    oRS = RS
    RS = "\n\t\n"	# hopefully not found in terminfo capabilities
    ret = 0
    tinfo[""]	# mark this as an array, for lame awks
    delete tinfo[""]
    for (i = 1; i in names; i++) {
	capname = names[i]
	if (!nooverwrite || !(capname in tinfo ||
		(capname ".failed") in tinfo)) {
	    cmd = "exec tput -T " term " " capname
	    if (noerror)
		cmd = cmd " 2>/dev/null"
	    # If there is no such capability, tput will exit 1.
	    # But old-awk does not return the exit status in close,
	    # so also check for read success & null string.
	    if ((ret = (cmd | getline cap)) == 1 && !(ret = close(cmd)) &&
		    cap != "")
		tinfo[capname] = cap
	    else
		tinfo[capname ".failed"]
	}
    }
    RS = oRS
    return ret
}

# Caches capabilities in _tinfo_capabilities[]
function tiget1(capname, term, noerror,
	capnames, tinfo) {
    if (term == "")
	if ("TERM" in ENVIRON)
	    term = ENVIRON["TERM"]
	else
	    return -1
    if ((term,capname) in _tinfo_capabilities)
	return _tinfo_capabilities[term,capname]
    else {
	tiget(capname,tinfo,term,noerror)
	# Cache result, whether successful or not (null)
	return _tinfo_capabilities[term,capname] = tinfo[capname]
    }
}

# Stuff a capability into the cache, for debugging
function _tinfo_stuff_cap(capname, capability, term) {
    if (term == "")
	if ("TERM" in ENVIRON)
	    term = ENVIRON["TERM"]
	else
	    return -1
    _tinfo_capabilities[term,capname] = capability
}

# tiCapInterp: Interpret raw terminfo strings the same way tic does.
# \b backspace
# \f formfeed
# \n newline
# \r return
# \t tab
# \l linefeed (newline)
# \s space
# \^ caret
# \\ backslash
# \, comma
# \: colon
# \0 null (actually \200)
# \E escape
# \e escape
# \bbb Octal character bbb
# \any-other-char, including \bb and \b (other than \0), are interpreted
#     literally (the \ is included in the resulting string).
# ^x control-x, for any of the usual values of x
# ^any-other-char is interpreted literally
function tiCapInterp(S,
	out, len, i, c, ind) {
    len = length(S)
    out = ""
    if (!("@" in _ToControl_Map))
	MakeToControlTable()
    for (i = 1; i <= len; i++) {
	c = substr(S,i,1)
	if (c == "\\") {	# translate escape sequence
	    c = substr(S,++i,1)
	    if (substr(S,i,3) ~ "[0-7][0-7][0-7]") {
		c = sprintf("%c",c*64 + substr(S,i+1,1)*8 + substr(S,i+2,1))
		i+=2
	    }
	    else if (ind = index("bfnrtls^\\,:0eE",c))
		c = substr("\b\f\n\r\t\n ^\\,:\200\033\033",ind,1)
	    else
		c = "\\" c
	}
	else if (c == "^") {
	    c = substr(S,++i,1)
	    if (c in _ToControl_Map)
		c = _ToControl_Map[c]
	    else
		c = "^" c
	}
	out = out c
    }
    return out
}

# The remaining code (parameterized capability interpretation) is UNFINISHED.

# Configure error-printing behavior for tparm().
# The default is to print error messages.
# If this is called with noerror true, error messages may be printed to the
# standard error stream.
function tinfo_seterr(noerror) {
    _tinfo_noerror = noerror
}

function _tinfo_printerr(message) {
    if (!_tinfo_noerror)
	print message > "/dev/stderr"
}

# Set the terminal type that will be used by tparm().
# If this is never called (or sets a null value), TERM is used.
function setterm(termtype) {
    _tinfo_term = termtype
}

# Used by tparm to push a value on the parameter interpretation stack.
function _tparm_push(value) {
    _tparm_stack[++_tparm_stack_ptr] = value
    if (_tparm_debug)
	printf "\rPushing <%s>\n", value > "/dev/stderr"
}

# Used by tparm to pop a value from the parameter interpretation stack.
# If getstring is true, the value is returned unmodified.
# If not (or not passed), the value is coerced to integer.
function _tparm_pop(getstring,
	parm) {
    if (_tparm_stack_ptr > 0) {
	parm = _tparm_stack[_tparm_stack_ptr--]
	if (!getstring) {
	    if (parm == "")
		_tinfo_printerr("empty parm used for integer")
	    parm += 0
	}
	if (_tparm_debug)
	    printf "\rPopped <%s>\n", parm > "/dev/stderr"
	return parm
    }
    _tinfo_printerr("terminfo parameter underflow")
    return ""
}

function _tparm_binop(op,
	p1, p2, result) {
    p2 = _tparm_pop()
    p1 = _tparm_pop()
    if (op == "+")
	result = p1 + p2
    else if (op == "-")
	result = p1 - p2
    else if (op == "*")
	result = p1 * p2
    else if (op == "/" || op == "m")
	if (p2 == 0)
	    _tinfo_printerr("Attempted division by zero")
	else
	    result = op == "/" ? int(p1 / p2) : p1 % p2
    else if (op == "&")
	result = and(p1, p2)
    else if (op == "|")
	result = or(p1, p2)
    else if (op == "^")
	result = xor(p1, p2)
    else if (op == "=")
	result = p1 == p2
    else if (op == ">")
	result = p1 > p2
    else if (op == "<")
	result = p1 < p2
    else if (op == "A")
	result = p1 && p2
    else if (op == "O")
	result = p1 || p2
    else
	_tinfo_printerr("Unknown binary operator " op)
    if (_tparm_debug)
	printf "\r%s %s %s = %s\n", p1, op, p2, result > "/dev/stderr"
    _tparm_push(result)
}

# Parameters are treated as integer values (numbers/booleans/chars) by all ops
# except %l and %s.  The only capabilities that should actually use these are
# [pfkey pfloc pfx pln pfxl], but we don't enforce that.

# tparm: Get and interpret a parameterized capability.
function tparm(capname, p1, p2, p3, p4, p5, p6, p7, p8, p9,
	len, cap, capCharNum, c, out, p, result, vars, varname, i,
	skipto_depth, skipto_char) {
    p[1] = p1; p[2] = p2; p[3] = p3; p[4] = p4; p[5] = p5
    p[6] = p6; p[7] = p7; p[8] = p8; p[9] = p9
    _tparm_stack_ptr = 0
    len = length(cap = tiget1(capname, _tinfo_term, _tinfo_noerror))
    for (capCharNum = 1; capCharNum <= len; capCharNum++) {
	c = substr(cap, capCharNum, 1)
	if (c == "%") {
	    c = substr(cap, ++capCharNum, 1)
	    if (skipto_char != "") {
		if (skipto_depth > 0)
		    if (c == "?")
			skipto_depth++
		    else if (c == ";")
			skipto_depth--
		else if (c == skipto_char || c == ";")
		    skipto_char = ""
		continue
	    }
	    result = ""
	    if (c == "%")	# %% -> %
		result = "%"
	    else if (c == "p") {	# %p[0-9]: Push parm
		if ((c = substr(cap, ++capCharNum, 1)+0) == 0)
		    _tinfo_printerr("%p not followed by digit")
		_tparm_push(p[c])
	    }
	    else if (index("# :doxXs0123456789.", c)) {    # printf-style fmt string
		# Format: %[:][flags][width[.precision]][doxXs] (flags are -+#)
		# : is a noop flag; this is how %[+-]fmt is distinguished from
		# the %+ and %- ops
		if (c == ":")	
		    capCharNum++
		match(substr(cap, capCharNum), /^[-+#]*([0-9]+(.[0-9]+)?)?[doxXs]/)
		if (RSTART == 0)
		    _tinfo_printerr("%" c " not followed by formatter ending in [doxXs]")
		else {
		    result = sprintf("%" substr(cap, capCharNum, RLENGTH),
			_tparm_pop(substr(cap, capCharNum+RLENGTH-1, 1) == "s"))
		    capCharNum += RLENGTH-1
		}
	    }
	    else if (c == "c")	# chr(pop())
		result = sprintf("%c", _tparm_pop())
	    else if (c == "P" || c == "g") {
		if ((varname = substr(cap, ++capCharNum, 1)) == "" || varname !~ /[[:alpha:]]/)
		    _tinfo_printerr("%" c " not followed by letter")
		# a through z are dynamic vars; they exist only for the
		# duration of this call
		# A through Z are static vars; they persist between calls
		if (c == "P")	# %P<alpha> Pop into variable <alpha>
		    if (varname ~ /[[:lower:]]/)
			vars[varname] = _tparm_pop()
		    else
			_tparm_vars[varname] = _tparm_pop()
		else	# %g<alpha> Push variable <alpha>
		    _tparm_push(varname ~ /[[:lower:]]/ ? vars[varname] : _tparm_vars[varname])
	    }
	    else if (c == "'") {	# %'c' push(asc(c))
		if ((c = substr(cap, ++capCharNum, 1)) == "" || substr(cap, ++capCharNum, 1) != "'")
		    _tinfo_printerr("%' not followed by c'")
		if (!(1 in _tparm_asc_Table))
		    for (i = 0; i <= 255; i++)
			_tparm_asc_Table[sprintf("%c", i)] = i
		_tparm_push(_tparm_asc_Table[c])
	    }
	    else if (c == "{") {	# %{n} push decimal value n
		match(substr(cap, capCharNum+1), "^[-+]?[0-9]+}")
		if (RSTART == 0)
		    _tinfo_printerr("%{ not followed by number}")
		else {
		    _tparm_push(substr(cap, capCharNum+1, RLENGTH-1))
		    capCharNum += RLENGTH
		}
	    }
	    else if (c == "l")	# %l String length
		_tparm_push(length(_tparm_pop(1)))
	    else if (index("+-*/m&|^=><AO", c))	# binary operations
		_tparm_binop(c)
	    else if (c == "!")	# push(!pop())
		_tparm_push(!_tparm_pop())
	    else if (c == "~")	# push(~pop())
		_tparm_push(compl(_tparm_pop()))
	    else if (c == "i") {	# Increment first 2 parms
		p[1]++
		p[2]++
	    }
	    else if (c == "?" || c == ";")	# if, endif
		# %? <expr> %t <then> %e <else> %;
		# %? <if-expr> %t <then> %e <elseif-expr> %t <elseif-then> %e <else> %;
		# <expr> consists of code that leaves a boolean value on the
		# top of the stack.
		# <then> is code to execute if <expr> is true.
		# <else> is code to execute if <expr> is false.
		# <else>s can be chained by following them with <expr>%t.
		# In practice, we just skip over %? (unless we encounter it
		# while skipping a branch), and at %t look at the top of the
		# stack.  If true, we continue on.  If false, we skip to
		# the next %e or %;, whichever comes first, and continue.
		# If we hit a %e that we didn't skip over, it's the end of the
		# true-branch, so we skip to %;.
		# If we hit a %; that we didn't skip over, it's because we're
		# executing an else; ignore it.
		# <then> and <else> may be empty, but each %t must be preceded
		# by code that leaves a boolean on the stack.
		# Whenever we skip, we count intermediate %?/%; to ensure that
		# we skip over nested if-then-elses.
		# In theory we could keep track of state so that we could warn
		# about an incorrect sequence of operators, but having to deal
		# with nested conditionals is annoying enough that we don't
		# bother.
		;
	    else if (c == "t") {	# then
		if (!_tparm_pop())
		    skipto_char = "e"
	    }
	    else if (c == "e") 	# else
		skipto_char = ";"
	    else	# undefined
		_tinfo_printerr("Undefined % operator: %" c)
	}
	else
	    result = c
	if (skipto_char == "")
	    out = out result
    }
    return out
}
### End-lib tinfo
### Begin-lib qsort
#
# The current version of this library can be found by searching
# http://www.armory.com/~ftp/
#
# @(#) qsort 1.2.1 2005-10-21
# 1990 john h. dubois iii (john@armory.com)
# 2001-05-21 1.2 Handle 0-1 element cases explicitly in qsortSegment to avoid
#            referencing nonexistent elements.
# 2005-10-21 1.2.1 Apply numeric conversion in qsortByArbIndex() only to values
#            that have a numeric part.

# qsortArbIndByValue(): Sort an array according to the values of its elements.
# Input variables:
# Arr[] is an array of values with arbitrary indices.
# Output variables:
# k[] is returned with numeric indices 1..n.  The values assigned to these
#     indices are the indices of Arr[], ordered so that if Arr[] is stepped
#    through in the order Arr[k[1]] .. Arr[k[n]], it will be stepped through in
#    order of the values of its elements.
# Return value: The number of elements in the arrays (n).
function qsortArbIndByValue(Arr, k,
	ArrInd, ElNum) {
    ElNum = 0
    for (ArrInd in Arr)
	k[++ElNum] = ArrInd
    qsortSegment(Arr,k,1,ElNum)
    return ElNum
}

# qsortSegment(): Sort a segment of an array.
# Input variables:
# Arr[] contains data with arbitrary indices.
# k[] has indices 1..nelem, with the indices of Arr[] as values.
# Output variables:
# k[] is modified by this function.  The elements of Arr[] that are pointed to
#     by k[start..end] are sorted, with the values of elements of k[] swapped
#     so that when this function returns, Arr[k[start..end]] will be in order.
# Return value: None.
function qsortSegment(Arr, k, start, end,
	left, right, sepval, tmp, tmpe, tmps) {
    if ((end - start) < 1)	# 0 or 1 elements
	return
    # handle two-element case explicitly for a tiny speedup
    if ((end - start) == 1) {
	if (Arr[tmps = k[start]] > Arr[tmpe = k[end]]) {
	    k[start] = tmpe
	    k[end] = tmps
	}
	return
    }
    # Make sure comparisons act on these as numbers
    left = start+0
    right = end+0
    sepval = Arr[k[int((left + right) / 2)]]
    # Make every element <= sepval be to the left of every element > sepval
    while (left < right) {
	while (Arr[k[left]] < sepval)
	    left++
	while (Arr[k[right]] > sepval)
	    right--
	if (left < right) {
	    tmp = k[left]
	    k[left++] = k[right]
	    k[right--] = tmp
	}
    }
    if (left == right)
	if (Arr[k[left]] < sepval)
	    left++
	else
	    right--
    if (start < right)
	qsortSegment(Arr,k,start,right)
    if (left < end)
	qsortSegment(Arr,k,left,end)
}

# qsortByArbIndex(): Sort an array according to the values of its indices.
# Input variables:
# Arr[] is an array of values with arbitrary indices.
# Numeric indicates whether the indices of Arr[] should be compared as numbers.
#     Values that are exclusively numeric or that begin with a numeric part are
#     converted to simple numbers.  Values that do not are not modified.
# Output variables:
# k[] is returned with numeric indices 1..n.  The values in k[] are the indices
#     of Arr[], ordered so that if Arr[] is stepped through in the order
#     Arr[k[1]] .. Arr[k[n]], it will be stepped through in order of the values
#     of its indices.  If Numeric is true, indices will be compared as numbers.
#     Numeric indices do not have to be contiguous.
# Return value: The number of elements in the arrays (n).
function qsortByArbIndex(Arr, k, Numeric,
	ArrInd, ElNum) {
    ElNum = 0
    if (Numeric)
	for (ArrInd in Arr) {
	    # Indexes do not preserve numeric type, so must be forced
	    if ((ArrInd+0) > 0 || ArrInd ~ /^[[:space:]]-?\.?0/)
		ArrInd += 0
	    k[++ElNum] = ArrInd
	}
    else
	for (ArrInd in Arr)
	    k[++ElNum] = ArrInd
    qsortNumIndByValue(k,1,ElNum)
    return ElNum
}

# qsortNumIndByValue(): Sort an array with contiguous numeric indices according
# to the values of its elements.
# Input variables:
# Arr[] is an array of elements with contiguous numeric indexes.
# start and end are the starting and ending indices of the range to be sorted.
# Output variables:
# Arr[] is returned with the same indices, but with the values assigned to them
# swapped in order to accomplish the sorting described above.
function qsortNumIndByValue(Arr, start, end,
	left, right, sepval, tmp, tmpe, tmps) {
    # handle two-element case explicitly for a tiny speedup
    if ((start - end) == 1) {
	if ((tmps = Arr[start]) > (tmpe = Arr[end])) {
	    Arr[start] = tmpe
	    Arr[end] = tmps
	}
	return
    }
    left = start+0
    right = end+0
    sepval = Arr[int((left + right) / 2)]
    while (left < right) {
	while (Arr[left] < sepval)
	    left++
	while (Arr[right] > sepval)
	    right--
	if (left <= right) {
	    tmp = Arr[left]
	    Arr[left++] = Arr[right]
	    Arr[right--] = tmp
	}
    }
    if (start < right)
	qsortNumIndByValue(Arr,start,right)
    if (left < end)
	qsortNumIndByValue(Arr,left,end)
}
### End-lib qsort
