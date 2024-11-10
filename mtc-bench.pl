#!/usr/bin/env perl

# PODNAME: mtc-bench
#
# ABSTRACT: Benchmark commands using `hyperfine` and `psrecord`. Look into CPU, memory and time.
BEGIN { $ENV{PERL_TEXT_CSV}='Text::CSV_PP'; }

use strict;
use warnings;
use Pod::Usage;
use feature 'say';
use Text::CSV qw/csv/;
use Data::Dump qw/dd pp/;
use Getopt::Long qw(GetOptionsFromArray);
use File::Path qw(make_path);
use POSIX qw(strftime);
use File::Temp qw/ tempdir /;


################################
# Parse command line arguments
################################

# Define default values for variables

my $bench_cmds = [];
my $args = [];
my $help = 0;
my $show_output = 0;
my $verbose = 0;
my $cmd_file = "";
my $global_prep = "";
my $labels = [];
my $psrec_cmds = [];
my $print_only = 0;
my $quiet = 0;


Getopt::Long::Configure("pass_through");
GetOptions(
    'help|h' => \$help,
    'show-output|s' => \$show_output,
    'verbose|v' => \$verbose,
    'file|f=s' => \$cmd_file,
    'print|p' => \$print_only,
    'quiet|q' => \$quiet,
) or pod2usage(2);
Getopt::Long::Configure("no_pass_through");

my $prep_count = 0;
for my $arg (@ARGV) {
    $prep_count++ if $arg eq "--prepare";
}

if ($prep_count == 1){
    GetOptions( 'prepare|p=s' => \$global_prep) or pod2usage(2);
    $bench_cmds = [];
    for my $arg (@ARGV) {
        push @$bench_cmds, { cmd => $arg };
    }
} else {
    my $i=1;
    while (my $arg = shift @ARGV) {
        if ($arg eq "--prepare"){
           push @$bench_cmds, {
               prepare => shift @ARGV,
               cmd => shift @ARGV,
               label => $i
           };
        } else {
            push @$bench_cmds, {
                cmd => $arg,
               label => $i
            }
        }
    }
}

###########################################################
# Validate and process arguments
###########################################################

if ($help) {
    say STDERR "Usage: $0 [options]";
    say STDERR "Options:";
    say STDERR "  -h, --help            Print this help message";
    say STDERR "  -v, --verbose         Print verbose output";
    say STDERR "  -s, --show-output     Show output of commands";
    say STDERR "  -f, --file            Read commands from file";
    say STDERR "  -p, --prepare         Prepare commands to run before benchmarking";
    exit 0;
}

if ($quiet) {
    $verbose = 0;
}

# Check for conflicting options
if ($cmd_file and scalar @$bench_cmds > 0) {
    say STDERR "Error: Cannot specify both --file ($cmd_file) and commands (@$bench_cmds)";
    exit 1;
}

# Check for missing options
if (not $cmd_file and scalar @$bench_cmds == 0) {
    say STDERR "Error: Must specify either --file or commands";
    exit 1;
}

# Check for file existence
if ($cmd_file and not -e $cmd_file) {
    say STDERR "Error: File not found: $cmd_file";
    exit 1;
}

###########################################################
# Read commands
###########################################################

if ($cmd_file) {
    say STDERR "Reading commands from file: $cmd_file" if $verbose;
    my $csv = csv(in => $cmd_file, headers => 'auto', quote_char => '\\', allow_whitespace => 1);

    my $i=1;
    for my $row (@$csv) {
        push @$bench_cmds, {
            prepare => $row->{prepare},
            cmd => $row->{command},
            label => $row->{label} || $i,
        };
        $i++;
    }
} else {
    say STDERR "Commands read from command line" if $verbose;
}

###########################################################
# Print benchmark information
###########################################################

my $RESULTS_BASE_DIR = 'mtc-results';
my $TS = strftime("%Y%m%d-%H%M%S", localtime);
my $RES_DIR = $ENV{RES_DIR} || "$RESULTS_BASE_DIR/$TS";
my $WARMUP = $ENV{WARMUP} || 1;
my $RUNS = $ENV{RUNS} || 3;
my $TMP_RES_DIR = tempdir( CLEANUP => 1 );


if (not -d $RES_DIR) {
    make_path($RES_DIR);
}
say STDERR "Running benchmark with $RUNS repetitions and $WARMUP warm up rounds on these commands:" if ! $quiet;
for (my $i = 0; $i < scalar @$bench_cmds; $i++) {
    my $cmd = $bench_cmds->[$i];
    my $l = $cmd->{label} || $i;
    say STDERR "  [$l]: $cmd->{cmd}" if ! $quiet;
}

###########################################################
# Cleanup function
###########################################################

my $cleanup_fn_name = "mtc_cleanup_files";
my $cleanup_fn = <<"CLEANUP";
function $cleanup_fn_name() {
    if [[ "$verbose" == true ]]; then
        >&2 echo "Cleaning up..."
    fi

    file=\$(find "$TMP_RES_DIR" -maxdepth 1 -name "*.log" | head -n 1)
    if [[ -z "\$file" ]]; then
        >&2 echo "  no log file found for cleanup"
        return
    fi

    label="\${file##*/}"
    label="\${label%.*}"
    if [[ -z "\$label" ]]; then
        >&2 echo "Error: Could not determine label for cleanup"
    fi
    counter=1
    for ext in log png; do
        while [[ -f "$RES_DIR/\$label-\$counter.\$ext" ]]; do
            counter=\$((counter + 1))
        done
        if [[ "$verbose" == true ]]; then
            >&2 echo "  moving $TMP_RES_DIR/\$label.\$ext to $RES_DIR/\$label-\$counter.\$ext"
        fi
        mv "$TMP_RES_DIR/\$label.\$ext" "$RES_DIR/\$label-\$counter.\$ext"
    done
}
CLEANUP


###########################################################
# hyperfine options
###########################################################

my $hf_flags = "";
if ($show_output) {
    $hf_flags .= "--show-output";
}
$hf_flags .= " --shell=bash --runs $RUNS --warmup $WARMUP";
$hf_flags .= " --export-json $RES_DIR/hyperfine.json";
$hf_flags .= " --export-csv $RES_DIR/hyperfine.csv";
$hf_flags .= " --export-markdown $RES_DIR/hyperfine.md";
$hf_flags .= " --export-asciidoc $RES_DIR/hyperfine.txt";

if ($verbose) {
    say STDERR "hyperfine flags:\n\t". $hf_flags;
}

###########################################################
# Run hyperfine
###########################################################

my $interval = 0.1;

my $hf_cmds = [];
for my $cmd (@$bench_cmds) {
    my $psr_cmd = "psrecord --interval $interval  ";
    $psr_cmd .= "--plot $TMP_RES_DIR/$cmd->{label}.png ";
    $psr_cmd .= "--log $TMP_RES_DIR/$cmd->{label}.log ";
    $psr_cmd .= "--include-children ";
    $psr_cmd .= "\"$cmd->{cmd}\"";

    $cmd->{psrec_cmd} = $psr_cmd;

    if ($cmd->{prepare}) {
        push @$hf_cmds, " --prepare '$cleanup_fn_name && $cmd->{prepare}'  '$psr_cmd'";
    } else {
        push @$hf_cmds, " '$cmd->{cmd}'";
    }
}

my $hf_cmd = "$cleanup_fn\n";
$hf_cmd .= "export -f $cleanup_fn_name\n";
$hf_cmd .= "hyperfine $hf_flags ".join(" ",  @$hf_cmds);
$hf_cmd .= "\n$cleanup_fn_name\n";

exec $hf_cmd;




__END__
 
=head1 NAME
 

