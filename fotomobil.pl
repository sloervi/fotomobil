#!/usr/bin/perl
# fotomobil.pl
# sloervi McMurphy 15.03.2015
# Change the size of photos to e.g. 1200 Pixel width
# useful for a copy of your photos on your smartphone

use strict;
use warnings;
use File::Basename;
use Getopt::Long;
use Image::ExifTool;
use utf8;
use File::Basename;

my      $dirname = ".";
my      $file;
my      @files;
my      $smartphone_width=1200;
my      $suffix = '\..*';
my      $muster_voll='_'.$smartphone_width.$suffix;
my      $ACTIONLIST_FULL="/usr/local/bin/fotomobil/fotomobil.phatch";   # On Dockerhost
my      $ACTIONLIST_ROTATE90="/usr/local/bin/fotomobil/rotate90.phatch";          # Within the container
my      $ACTIONLIST_ROTATE270="/usr/local/bin/fotomobil/rotate270.phatch";       # Within the container
my      $verbose=1;
my      $verbose_schalter="--verbose";
my      $help = 0;
my      $do_upload = 0;
my      $do_phatch = 1;
my      $do_nexus;
                                # Kann ich das auch hinterher ausblenden?

# Check if your Actionlist is present
open(PHATCH, $ACTIONLIST_FULL) or die "Can't open $ACTIONLIST_FULL!";
close(PHATCH);


my      $zaehler = 0;
opendir(DIR, $dirname) or die "Can't open Directory $dirname: $!";
@files = grep { /\.JPG$|\.jpg$|\.png|\.jpeg/ } readdir(DIR);
foreach $file ( @files)
{
        print "\nfile: $file\n" unless !$verbose_schalter;
        my ($basevoll, $dirvoll, $extvoll) = fileparse($file, $muster_voll);
        # Schon geaenderte Dateien ausklammern
        if (!($extvoll =~$muster_voll))
        {
                print "\n\nNew file: $file\n" unless !$verbose_schalter;
                if($do_phatch)
                {
                        my $exifTool = new Image::ExifTool;
                        $exifTool->Options(Unknown => 1);
                        my $info = $exifTool->ImageInfo($file);
                        my $group = '';
                        my $tag;
                        my $gedreht = 0;
                        my $width = 0;
                        my $height = 0;
                       foreach $tag ($exifTool->GetFoundTags('Group0')) {
                           my $val = $info->{$tag};
                                if($exifTool->GetDescription($tag) eq 'Orientation')
                                {
                                        $gedreht = $val;
                                }
                                elsif($exifTool->GetDescription($tag) eq 'Image Width')
                                {
                                        $width = $val;
                                }
                                elsif($exifTool->GetDescription($tag) eq 'Image Height')
                                {
                                        $height = $val;
                                }
                       }
                        my $al = 0;     # Action List fuer das Drehen
                        if($gedreht =~ '^Rotate')
                        {
                                if($width > $height)
                                {
                                        my ($dummy, $grad) = split(/ /, $gedreht);
                                        if($grad eq 90)
                                        {
                                                $al = $ACTIONLIST_ROTATE90;
                                        }
                                        elsif($grad eq 270)
                                        {
                                                $al = $ACTIONLIST_ROTATE270;
                                        }
                                        else
                                        {
                                                print "Rotation unknown: ";
                                        }
                                        ($verbose_schalter eq '-v') && print "\n$file rotated ($gedreht) ($width, $height)\n";
                                }
                        }
                        elsif($verbose_schalter eq '-v')
                        {
                                print "$file is not rotated";
                                if($width < $height)
                                {
                                        print " - saved as rotated!?";
                                }
                                print "\n";
                        }
                        ($verbose_schalter eq '-v') && print "\nACTION LIST: $ACTIONLIST_FULL\n";
                        system("phatch $verbose_schalter -c -k $ACTIONLIST_FULL '$file'");

                        # If I have to rotate: Use the copies
                        my $kopie = $basevoll."_".$smartphone_width.$extvoll;
                        $al && ($verbose_schalter eq '-v') && print "ACTION LIST: $al ($kopie)\n";
                        $al && system("phatch $verbose_schalter -c -k $al $kopie");

                }
                #### Ende dieses Fotos

        }
        $zaehler ++;
}

closedir(DIR);

__END__
