#!/usr/bin/awk -f
################################################################################
# special_parser.awk - parsing script for awkiawki
# $Id: special_parser.awk,v 1.5 2003/07/07 11:22:55 olt Exp $
################################################################################
# Copyright (c) 2002 Oliver Tonnhofer (olt@bogosoft.com)
# See the file `COPYING' for copyright notice.
################################################################################

BEGIN {
	scriptname = ENVIRON["SCRIPT_NAME"]
	if (special_changes)
		print "<table>"
	if (special_history) {
		# use the power of awk to split the information of rlog
		RS = "----------------------------\n"
		FS = "\n"
		print "<table>\n<tr><th>version</th><th>date</th><th>ip</th><th>comment</th>"
		print "<th>view version</th><th>edit version</th><th>diff to current</th></tr>" 
	}
	if (special_diff)
		print "<pre>"
} 

special_changes && $9 ~ /^[A-Z][a-z]+[A-Z][A-Za-z]*$/ {
	filenr++
	print "<tr><td>" generate_link($9) "</td><td>"$7" "$6" "$8"</td></tr>"
	if (filenr == special_changes)
		exit
}

special_index && /^[A-Z][a-z]+[A-Z][A-Za-z]*$/ {
	print generate_link($0) "<br>"
}

special_search && /[A-Z][a-z]+[A-Z][A-Za-z]*$/ {
	sub(/^.*[^\/]\//, "")
	print generate_link($0) "<br>"
}

special_history && NR > 1 {
	#pick revision number
	match($1, /[1-9]\.[0-9]+/)
	revision = substr($1, RSTART, RLENGTH)
	
	#split the double-semicolon seperated information line
	split($3, sp_array, ";;")
	ip_address = sp_array[1]
	date = sp_array[2]
	comment = sp_array[3]
	
	if (NR == 2) 
		revision = "current"
	
	print "<tr align=center><td>"revision"</td><td>"date"</td><td>"ip_address"</td><td>"comment"</td>"
	print "<td><a href=\""scriptname"/"special_history
	if (NR > 2)
		print "?revision="revision
	print "\">view</a></td>"
	print "<td><a href=\""scriptname"/?edit=true&amp;"
	if (NR >2)
		print "revision="revision"&amp;"
	print "page="special_history"\">edit</a></td>"
	if (NR >2)
		print "<td><a href=\""scriptname"/?diff=true&amp;page="special_history"&amp;revision="revision"\">diff</a></td>"
	print "</tr>"

}

special_diff && (NR >2) {
	if (/^\+/)
		print "<span class=\"new\">"$0"</span>"
	else if (/^\-/)
		print "<span class=\"old\">"$0"</span>"
	else
		print $0

}

END {
	if (special_changes || special_history)
		print "</table>"
	if (special_diff)
		print "</pre>"
}

function generate_link(string) {
	sub(/[A-Z][a-z]+[A-Z][A-Za-z]*/, "<a href=\""scriptname"/&\">&</a>", string)
	return(string)
}
