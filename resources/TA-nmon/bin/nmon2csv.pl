#!/usr/bin/perl
# Program name: nmon2csv.pl
# Purpose - convert nmon.csv file(s) into csv file
# Author - Guilhem Marchand with code partially based on Bruce Spencer's perl mysql convert script
# Disclaimer:  this provided "as is".  
# Date - May 2014
# Modified by Barak Griffis 05/06/2014
#
$nmon2csv_ver="1.0.5 May 2014";

use Time::Local;


#################################################
## 	Your Customizations Go Here            ##
#################################################

# Default Environment Variable SPLUNK_HOME, this shall be automatically defined if as the script shall be launched by Splunk
my $SPLUNK_HOME=$ENV{SPLUNK_HOME};

my $APP="";

if ( $SPLUNK_HOME =~ /.*splunkforwarder.*/) {
	$APP="$SPLUNK_HOME/etc/apps/TA-nmon";	
}elsif (-d "/opt/splunk/etc/slave-apps/_cluster" ){
	$APP="$SPLUNK_HOME/etc/slave-apps/PA-nmon";
}else{
	$APP="$SPLUNK_HOME/etc/apps/nmon";
}

if ( ! -d "$APP/var" ) { mkdir "$APP/var"; }

# Spool directory for NMON files processing
my $SPOOL_DIR="$APP/var/spool";
if ( ! -d "$SPOOL_DIR" ) { print("Making $SPOOL_DIR");mkdir "$SPOOL_DIR"; }

#  Output directory of csv files to be consummated by Splunk
my $OUTPUT_DIR="$APP/var/csv_repository";
if ( ! -d "$OUTPUT_DIR" ) { mkdir "$OUTPUT_DIR"; }

my $OUTPUTCONF_DIR="$APP/var/config_repository";
if ( ! -d "$OUTPUTCONF_DIR" ) { mkdir "$OUTPUTCONF_DIR"; } 

# sha1sum file referencing known NMON file
my $CKSUM_REF="$APP/var/cksum_reference.txt";

####################################################################
#############		Main Program 			############
####################################################################

# Verify SPLUNK_HOME definition
if(not $SPLUNK_HOME) {
	print ("\nERROR: SPLUNK_HOME environment variable is not defined !\n");
	die;
}

# Verify existence of OUTPUT_DIR
if ( ! -d "$SPOOL_DIR" ) {
	print ("\nERROR: Spool Directory $SPOOL_DIR does not exist !\n");
	die;
}

# Verify existence of OUTPUT_DIR
if ( ! -d "$OUTPUT_DIR" ) {
	print ("\nERROR: Directory for csv output $OUTPUT_DIR does not exist !\n");
	die;
}

# Initialize common variables
&initialize;

# Read nmon file from stdin (eg. cat <my nmon file> | nmon2csv)
my $file = "$SPOOL_DIR/nmon2csv.$$.nmon";
open my $fh, '>', $file or die $!;

while (<STDIN>) {
    last if /^$/;
    print $fh $_;
}
close $fh;

###################################################################################################################################
# CKSUM

# Compute CKSUM of file to avoid Splunk duplicating data by relaunching multiple times this script

# Open temp nmon
open FILE, $file or die "can't open file!";

# Compute cksum

my $cksum_hash = `cat $file | cksum | awk '{print \$1}'`;

print "NMON file cksum: $cksum_hash";

# Open CKSUM_REF file
open(CKSUM,$CKSUM_REF);

# If cksum is found in CKSUM_REF, no need to go, else continue and save cksum

if (grep{/$cksum_hash/} <CKSUM>){

   print "Process done.\n";
   
   # Delete temp nmon file
	unlink $file;
	exit;

}else{
   print "cksum unknown, let's convert data.\n";

	# Savecksum
	
	# Open for writing
		unless (open(CKSUM, ">>$CKSUM_REF")) { 
		die("Can not open $$CKSUM_REF\n"); 
		}
	
		print (CKSUM $cksum_hash."\n");
		close CKSUM;   
}

close CKSUM;

###################################################################################################################################




# Process nmon file provided in argument
@nmon_files="$SPOOL_DIR/nmon2csv.$$.nmon";

@nmon_files=sort(@nmon_files);
chomp(@nmon_files);

foreach $FILENAME ( @nmon_files ) {

  $start=time();
  @now=localtime($start);
  $now=join(":",@now[2,1,0]);
  
  $curr_date=`date`;  
  
  print ("$curr_date: Begin processing file = $FILENAME\n");
  
  # Parse nmon file, skip if unsuccessful
  if (( &get_nmon_data ) gt 0 ) { next; }
  $now=time();
  $now=$now-$start;
  print ("\t$now: Finished get_nmon_data\n");


####################################################################################################
#############		NMON config Section						############
####################################################################################################

# Extract config elements from NMON files, section AAA, section BBB

  # CONFIG Section
  @config_vars=("CONFIG");

  foreach $key (@config_vars) {


     @cols= split(/\//,$FILENAME);
     $BASEFILENAME= $cols[@cols-1];

     unless (open(INSERT, ">$OUTPUTCONF_DIR/$BASEFILENAME.$key.csv")) { 
	  die("Can not open /$OUTPUTCONF_DIR/$BASEFILENAME.$key.csv\n"); 
     }


# Initialize variables
my $section = "CONFIG";
my $time = "";
my $date = "";
my $hostnameT = "Unknown";
my $SerialNumber="Unknown";

# Get nmon/server settings (search string, return column, delimiter)
$AIXVER		=&get_setting("AIX",2,",");
$HOSTNAME	=&get_setting("host",2,",");
$DATE	=&get_setting("AAA,date",2,",");
$TIME	=&get_setting("AAA,time",2,",");


if ($AIXVER eq "-1") {
	$SN=$HOSTNAME; 	# Probably a Linux host
} else {
	$SN	=&get_setting("systemid",4,",");
	$SN 	=(split(/\s+/,$SN))[0]; # "systemid IBM,SN ..."
}


# write event header
   
my $write = $section.",".$DATE.":".$TIME.",".$SN.",".$HOSTNAME;
print ( INSERT "$write\n");


# Open NMON file for reading
if( ! open(FIC,$file) ) {
  erreur("Error while trying to open NMON Source file '".$file."'")
}


while( defined( my $l = <FIC> ) ) {
  chomp $l;  

   # CONFIG Section"

	
	if ($l =~ /^AAA/) {

	my $x = $l;
	
	# Manage some fields we statically set
	$x =~ s/CONFIG,//g;
	$x =~ s/Time,//g;
	

	my $write = $x;

	print ( INSERT "$write\n");

	}

	if ($l =~ /^BBB/) {

	my $x = $l;
	
	# Manage some fields we statically set
	$x =~ s/CONFIG,//g;
	$x =~ s/Time,//g;
	

	my $write = $x;

	print ( INSERT "$write\n");

	}


}

     print ("\t$now: Finished $key\n");
  } # end foreach

###################################################""



####################################################################################################
#############		NMON Sections with static fields (eg. no devices)		############
####################################################################################################

  
  # Static variables (number of fields always the same)
  @static_vars=("LPAR","CPU_ALL","FILE","MEM","PAGE","MEMNEW","MEMUSE","PROC","PROCSOL","VM");

  foreach $key (@static_vars) {


     @cols= split(/\//,$FILENAME);
     $BASEFILENAME= $cols[@cols-1];

     unless (open(INSERT, ">$OUTPUT_DIR/$BASEFILENAME.$key.csv")) { 
	  die("Can not open /$OUTPUT_DIR/$BASEFILENAME.$key.csv\n"); 
     }

     &static_sections_insert($key);;
     $now=time();
     $now=$now-$start;
     print ("\t: Finished $key\n");
  } # end foreach


####################################################################################################
#############		NMON TOP Section						############
####################################################################################################

  # TOP Section (specific)
  @top_vars=("TOP");

  foreach $key (@top_vars) {


     @cols= split(/\//,$FILENAME);
     $BASEFILENAME= $cols[@cols-1];

     unless (open(INSERT, ">$OUTPUT_DIR/$BASEFILENAME.$key.csv")) { 
	  die("Can not open /$OUTPUT_DIR/$BASEFILENAME.$key.csv\n"); 
     }


# Initialize variables
my $section = "";
my $timestamp = "";
my $hostnameT = "Unknown";
my $SerialNumber="Unknown";
my $logical_cpus = "Unknown";
my $virtual_cpus = "Unknown";

# Get nmon/server settings (search string, return column, delimiter)
$AIXVER		=&get_setting("AIX",2,",");
$HOSTNAME	=&get_setting("host",2,",");

if ($AIXVER eq "-1") {
	$SN=$HOSTNAME; 	# Probably a Linux host
} else {
	$SN	=&get_setting("systemid",4,",");
	$SN 	=(split(/\s+/,$SN))[0]; # "systemid IBM,SN ..."
}


# Open NMON file for reading
if( ! open(FIC,$file) ) {
  erreur("Error while trying to open NMON Source file '".$file."'")
}

while( defined( my $l = <FIC> ) ) {
  chomp $l;
  
 
  # Get Logical CPUs value"
  if ((rindex $l,"AAA,cpus,") > -1) { 
	  (my $t1, my $t2, $logical_cpus) = split(",",$l);
  }
  
  # Get Virtual CPUs value
  if ((rindex $l,"Online Virtual CPUs") > -1) { 
	  (my $t1, $virtual_cpus) = split(": ",$l);
	  $virtual_cpus =~ s/\"//g;
  }
  
  # Get timestamp"
  if ((rindex $l,"ZZZZ,") > -1) { 
	  (my $t1, my $t2, my $timestamptmp1, my $timestamptmp2) = split(",",$l);
	  $timestamp = $timestamptmp2." ".$timestamptmp1;
  }


   # TOP Section"

   # Get and write csv header
	
	if ($l =~ /^TOP,.PID/) {

	my $x = $l;

	# convert unwanted characters
	$x =~ s/\%/pct_/g;
	# $x =~ s/\W*//g;
	$x =~ s/\/s/ps/g;   	# /s  - ps
	$x =~ s/\//s/g;		# / - s
	$x =~ s/\(/_/g;
	$x =~ s/\)/_/g;
	$x =~ s/ /_/g;
	$x =~ s/-/_/g;
	$x =~ s/_KBps//g;
	$x =~ s/_tps//g;
	$x =~ s/[:,]*\s*$//;	

	$x =~ s/\+//g;
	$x =~ s/\=0//g;
	
	# Manage some fields we statically set
	$x =~ s/TOP,//g;
	$x =~ s/Time,//g;
	

	my $write = type.",".serialnum.",".hostname.",".timestamp.",".logical_cpus.",".virtual_cpus.",".$x;

	print ( INSERT "$write\n");

	}

	
	# Get and write NMON section
	if (((rindex $l,"TOP,") > -1) && (length($timestamp) > 0)) {

 
	(my @line) = split(",",$l);
	my $section = "TOP";
	my $write = $section.",".$SN.",".$HOSTNAME.",".$timestamp.",".$logical_cpus.",".$virtual_cpus.",".$line[1];
	my $i = 3;###########################################################################



	while ($i <= $#line) {
      $write = $write.','.$line[$i];
	  $i = $i + 1;
	}

 	print (INSERT $write."\n"); 

  }

}

     print ("\t$now: Finished $key\n");
  } # end foreach

###################################################""


####################################################################################################
#############		NMON Sections with variable fields (eg. with devices)		############
####################################################################################################

  ###################################################	

  # Dynamic variables (variable number of fields)
  # DISK* Sections

  @dynamic_vars=("DISKBSIZE","DISKBUSY","DISKREAD","DISKWRITE","DISKXFER");

  foreach $key (@dynamic_vars) {

     @cols= split(/\//,$FILENAME);
     $BASEFILENAME= $cols[@cols-1];

     unless (open(INSERT, ">$OUTPUT_DIR/$BASEFILENAME.$key.csv")) { 
	  die("Can not open /$OUTPUT_DIR/$BASEFILENAME.$key.csv\n"); 
     }

    &variable_sections_insert($key);;
    $now=time();
    $now=$now-$start;
    print ("\t$now: Finished $key\n");
  }

  ###################################################

  # Dynamic variables (variable number of fields)
  # ESS* Sections  
  
  @dynamic_vars=("ESSREAD","ESSWRITE","ESSXFER");

  foreach $key (@dynamic_vars) {

     @cols= split(/\//,$FILENAME);
     $BASEFILENAME= $cols[@cols-1];

     unless (open(INSERT, ">$OUTPUT_DIR/$BASEFILENAME.$key.csv")) { 
	  die("Can not open /$OUTPUT_DIR/$BASEFILENAME.$key.csv\n"); 
     }

    &variable_sections_insert($key);;
    $now=time();
    $now=$now-$start;
    print ("\t$now: Finished $key\n");
  }

  ###################################################

  # Dynamic variables (variable number of fields)
  # Various Sections  

  @dynamic_vars=("IOADAPT","NETERROR","NET","NETPACKET","JFSFILE","JFSINODE");

  foreach $key (@dynamic_vars) {

     @cols= split(/\//,$FILENAME);
     $BASEFILENAME= $cols[@cols-1];

     unless (open(INSERT, ">$OUTPUT_DIR/$BASEFILENAME.$key.csv")) { 
	  die("Can not open /$OUTPUT_DIR/$BASEFILENAME.$key.csv\n"); 
     }

    &variable_sections_insert($key);;
    $now=time();
    $now=$now-$start;
    print ("\t$now: Finished $key\n");
  }

  ###################################################


#############################################
#############  Main Program End 	############
#############################################


 # Close Temp NMON File
 close(INSERT);


 # Delete temp nmon file
 unlink("$FILENAME");

}
exit(0);
  
############################################
#############  Subroutines 	############
############################################

##################################################################
## Extract data for Static fields
##################################################################

sub static_sections_insert {

my($nmon_var)=@_; 
my $table=lc($nmon_var);

my @rawdata;
my $x;
my @cols;
my $comma;
my $TS;
my $n;
 

  @rawdata=grep(/^$nmon_var,/, @nmon);

  if (@rawdata < 1) { return(1); }

  @rawdata=sort(@rawdata);

  @cols=split(/,/,$rawdata[0]);
  $x=join(",",@cols[2..@cols-1]);
  $x=~ s/\%/_PCT/g;
  $x=~ s/\(MB\)/_MB/g;
  $x=~ s/-/_/g;
  $x=~ s/ /_/g;
  $x=~ s/__/_/g;
  $x=~ s/,_/,/g;
  $x=~ s/_,/,/g;
  $x=~ s/^_//;
  $x=~ s/_$//;

  print INSERT (qq|type,serialnum,hostname,mode,nmonver,time,ZZZZ,$x\n| );

  $comma="";
  $n=@cols;
  $n=$n-1; # number of columns -1 

  for($i=1;$i<@rawdata;$i++){ 

    $TS=$UTC_START + $INTERVAL*($i);

    @cols=split(/,/,$rawdata[$i]);
    $x=join(",",@cols[2..$n]);
    $x=~ s/,,/,-1,/g; # replace missing data ",," with a ",-1,"

    print INSERT (qq|$comma"$key","$SN","$HOSTNAME","$MODE","$NMONVER",$TS,"$DATETIME{@cols[1]}",$x| );

    $comma="\n";
  }
  print INSERT (qq||);
    
} # End Insert


##################################################################
## Extract data for Variable fields
##################################################################

sub variable_sections_insert {

my($nmon_var)=@_; 
my $table=lc($nmon_var);

my @rawdata;
my $x;
my $j;
my @cols;
my $comma;
my $TS;
my $n;
my @devices;
 

  @rawdata=grep(/^$nmon_var,/, @nmon);

  if ( @rawdata < 1) { return; }

  @rawdata=sort(@rawdata);

  $rawdata[0]=~ s/\%/_PCT/g;
  $rawdata[0]=~ s/\(/_/g;
  $rawdata[0]=~ s/\)/_/g;
  $rawdata[0]=~ s/ /_/g;
  $rawdata[0]=~ s/__/_/g;
  $rawdata[0]=~ s/,_/,/g;

  @devices=split(/,/,$rawdata[0]);

  print INSERT (qq|type,serialnum,hostname,time,ZZZZ,device,value| );

  $n=@rawdata;
  $n--; 
  for($i=1;$i<@rawdata;$i++){ 

    $TS=$UTC_START + $INTERVAL*($i);
    $rawdata[$i]=~ s/,$//;
    @cols=split(/,/,$rawdata[$i]);

      print INSERT (qq|\n"$key","$SN","$HOSTNAME",$TS,"$DATETIME{$cols[1]}","$devices[2]",$cols[2]| );
    for($j=3;$j<@cols;$j++){
      print INSERT (qq|\n"$key","$SN","$HOSTNAME",$TS,"$DATETIME{$cols[1]}","$devices[$j]",$cols[$j]| );
    }
    if ($i < $n) { print INSERT (""); } 
  }
  print INSERT (qq||);
    
} # End Insert

########################################################
###	Get an nmon setting from csv file            ###
###	finds first occurance of $search             ###
###	Return the selected column...$return_col     ###
###	Syntax:                                      ###
###     get_setting($search,$col_to_return,$separator)##
########################################################

sub get_setting {

my $i;
my $value="-1";
my ($search,$col,$separator)= @_;    # search text, $col, $separator

for ($i=0; $i<@nmon; $i++){

  if ($nmon[$i] =~ /$search/ ) {
	$value=(split(/$separator/,$nmon[$i]))[$col];
	$value =~ s/["']*//g;  #remove non alphanum characters
	return($value);
	} # end if

  } # end for

return($value);

} # end get_setting

#####################
##  Clean up       ##
#####################
sub clean_up_line {

	# remove characters not compatible with nmon variable
	# Max rrdtool variable length is 19 chars
	# Variable can not contain special characters (% - () )
	my ($x)=@_;	

	# print ("clean_up, before: $i\t$nmon[$i]\n");
	$x =~ s/\%/Pct/g;
	# $x =~ s/\W*//g;
	$x =~ s/\/s/ps/g;   	# /s  - ps
	$x =~ s/\//s/g;		# / - s
	$x =~ s/\(/_/g;
	$x =~ s/\)/_/g;
	$x =~ s/ /_/g;
	$x =~ s/-/_/g;
	$x =~ s/_KBps//g;
	$x =~ s/_tps//g;
	$x =~ s/[:,]*\s*$//;
	$retval=$x; 

} # end clean up
	

##########################################
##  Extract headings from nmon csv file ##
##########################################
sub initialize {

%MONTH2NUMBER =  ("jan", 1, "feb",2, "mar",3, "apr",4, "may",5, "jun",6, "jul",7, "aug",8, "sep",9, "oct",10, "nov",11, "dec",12 );

@MONTH2ALPHA =  (	"junk","jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec" );

} # end initialize

# Get data from nmon file, extract specific data fields (hostname, date, ...)
sub get_nmon_data {

my $key;
my $x;
my $category;
my %toc;
my @cols;

# Read nmon file
unless (open(FILE, $FILENAME)) { return(1); }
@nmon=<FILE>;  # input entire file
close(FILE);
chomp(@nmon);

# Cleanup nmon data remove trainig commas and colons
for($i=0; $i<@nmon;$i++ ) {
    $nmon[$i] =~ s/[:,]*\s*$//;
}

# Get nmon/server settings (search string, return column, delimiter)
$AIXVER		=&get_setting("AIX",2,",");
$DATE		=&get_setting("date",2,",");
$HOSTNAME	=&get_setting("host",2,",");
$INTERVAL	=&get_setting("interval",2,","); # nmon sampling interval

$MEMORY		=&get_setting(qq|lsconf,"Good Memory Size:|,1,":");
$MODEL		=&get_setting("modelname",3,'\s+');
$NMONVER	=&get_setting("version",2,",");

$SNAPSHOTS	=&get_setting("snapshots",2,",");  # number of readings

$STARTTIME	=&get_setting("AAA,time",2,",");
($HR, $MIN)=split(/\:/,$STARTTIME);


if ($AIXVER eq "-1") {
	$SN=$HOSTNAME; 	# Probably a Linux host
} else {
	$SN	=&get_setting("systemid",4,",");
	$SN 	=(split(/\s+/,$SN))[0]; # "systemid IBM,SN ..."
}

$TYPE		=&get_setting("^BBBP.*Type",3,",");
if ( $TYPE =~ /Shared/ ) { $TYPE="SPLPAR"; } else { $TYPE="Dedicated"; }

$MODE		=&get_setting("^BBBP.*Mode",3,",");
$MODE		=(split(/: /, $MODE))[1];
# $MODE		=~s/\"//g;


# Calculate UTC time (seconds since 1970)
# NMON V9  dd/mm/yy
# NMON V10+ dd-MMM-yyyy

if ( $DATE =~ /[a-zA-Z]/ ) {   # Alpha = assume dd-MMM-yyyy date format
	($DAY, $MMM, $YR)=split(/\-/,$DATE);
	$MMM=lc($MMM);
	$MON=$MONTH2NUMBER{$MMM};
} else {
	($DAY, $MON, $YR)=split(/\//,$DATE);
	$YR=$YR + 2000;
	$MMM=$MONTH2ALPHA[$MON];
} # end if

## Calculate UTC time (seconds since 1970).  Required format for the rrdtool.

##  timelocal format
##    day=1-31
##    month=0-11
##    year = x -1900  (time since 1900) (seems to work with either 2006 or 106)

$m=$MON - 1;  # jan=0, feb=2, ...

$UTC_START=timelocal(0,$MIN,$HR,$DAY,$m,$YR); 
$UTC_END=$UTC_START + $INTERVAL * $SNAPSHOTS;

@ZZZZ=grep(/^ZZZZ,/,@nmon);
for ($i=0;$i<@ZZZZ;$i++){

	@cols=split(/,/,$ZZZZ[$i]);
	($DAY,$MON,$YR)=split(/-/,$cols[3]);
	$MON=lc($MON);
	$MON="00" . $MONTH2NUMBER{$MON};
	$MON=substr($MON,-2,2);
	$ZZZZ[$i]="$YR-$MON-$DAY $cols[2]";
	$DATETIME{$cols[1]}="$YR-$MON-$DAY $cols[2]";


} # end ZZZZ

return(0);
} # end get_nmon_data
