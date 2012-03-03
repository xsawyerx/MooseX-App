# -*- perl -*-

# t/02_meta.t - MOP tests

use Test::Most tests => 16+1;
use Test::NoWarnings;
use Test::Output;

use lib 't/testlib';

use Test01;

my $meta = Test01->meta;

is($meta->app_namespace,'Test01','Command namespace ok');
is($meta->app_base,'02_meta.t','Command base ok');
is($meta->app_messageclass,'MooseX::App::Message::Block','Message class');

ok(Test01->can('new_with_command'),'Role applied to base class');
ok(Test01->can('initialize_command'),'Role applied to base class');

my %commands = $meta->commands;

is(scalar keys %commands,2,'Found two commands');
is($commands{command_a},'Test01::CommandA','Command A found');
is($meta->matching_commands('COMMAND_a'),'command_a','Command A matched');
is(join(',',$meta->matching_commands('COMMAND')),'command_a,command_b','Command A and B matched');

cmp_deeply([ $meta->command_usage_attributes_raw ],
[
  [
    '--config',
    'Path to command config file'
  ],
  [
    '--global',
    'test [Required; Integer; Important!]'
  ],
  [
    '--help --usage -?',
    'Prints this usage information. [Flag]'
  ]
]
,'Command A and B matched');

my $meta_attribute = $meta->find_attribute_by_name('global');
is(join(',',$meta->command_usage_attribute_tags($meta_attribute)),'Required,Integer,Important!','Tags ok');
$meta_attribute->command_tags(['Use with care']);
is(join(',',$meta->command_usage_attribute_tags($meta_attribute)),'Required,Integer,Use with care','Changed tags ok');

require Test01::CommandA;
my $description = $meta->command_usage_description('Test01::CommandA');

isa_ok($description,'MooseX::App::Message::Block');
like($description->body,qr/varius nec iaculis vitae/,'Description body ok');

require Test01::CommandB;
is(Test01::CommandB->meta->command_short_description,'Test class command B for test 01','Pod short description parsed ok');
is(Test01::CommandB->meta->command_long_description,'Some description of *command B*
 some code
 some code
some more desc
* item 1
* item 2
  * item 2.1
  * item 2.2
hase ist super','Pod long description parsed ok');
