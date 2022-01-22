use Test::Simple tests => 6;

my $GCPLOG = 't/fixtures/cloudsql.log.gz';
my $SYSLOG1 = 't/fixtures/pg-syslog.1.bz2';
my $SYSLOG2 = 't/fixtures/pg-syslog.1.bz2';
my $JSON = 't/out.json';
my $TEXT = 't/out.txt';

`rm *.html 2>/dev/null`;
my $ret = `perl pgbadger -q --exclude-db=pgbench --explode $SYSLOG1 && ls *.html`;
chomp($ret);
ok( $? == 0 && ($ret eq "out.html"), "Test --exclude-db + --explode");

$ret = `perl pgbadger -q --dbname=pgbench --explode $SYSLOG1 && ls *.html`;
chomp($ret);
ok( $? == 0 && ($ret eq "pgbench_out.html"), "Test --dbname + --explode");

`rm *.html`;

my $incr_outdir = "/tmp/pgbadger_data_tmp";
mkdir($incr_outdir);

$ret = `perl pgbadger -q --explode -I -O $incr_outdir $SYSLOG1 $SYSLOG2 && ls $incr_outdir | wc -l`;
chomp($ret);
ok( $? == 0 && ($ret == 4), "Test incremental mode with --explode");

`rm -rf $incr_outdir/*`;

$ret = `perl pgbadger -q --dbname=pgbench --explode -I -O $incr_outdir $SYSLOG1 $SYSLOG2 && ls $incr_outdir | grep ">12,474 queries" $incr_outdir/pgbench/2021/week-07/index.html`;
chomp($ret);
ok( $? == 0 && ($ret ne ''), "Test incremental mode with --explode and --dbname");

$ret = `perl pgbadger -q --exclude-db cloudsqladmin --explode $GCPLOG && ls *.html | wc -l`;
chomp($ret);
ok( $? == 0 && ($ret == 2), "Test database exclusion with jsonlog");

$ret = `perl pgbadger --disable-type --disable-session --disable-connection --disable-lock --disable-checkpoint --disable-autovacuum --disable-query -o out.txt t/fixtures/tempfile_only.log.gz -q`;
$ret = `grep "Example.*SELECT" out.txt | wc -l`;
chomp($ret);
ok( $? == 0 && ($ret == 9), "Test log_temp_files only");

# Remove files generated during the tests
`rm -f *.html`;
`rm -f out.txt`;
`rm -rf $incr_outdir`;

