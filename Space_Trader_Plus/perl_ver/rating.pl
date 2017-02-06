#!/usr/bin/perl
#use warnings;
use strict;
use Switch;
use feature "switch";
use Term::ReadKey;
use List::Util 'shuffle';
use Tk;
require "Sticky.pm";
require Tk::WorldCanvas;

####read in data
#my @datafile = load_file("data.txt");
my @planetfile = load_file("planets.txt");
chomp(@planetfile);
my %planets;
my %planet_prices;
my @crewfile = load_file("crew.txt");
my %crew_store;
my @traderfile = load_file("traders.txt");
chomp(@traderfile);
my %trader_store;

my $wood_price;
my $span_price;
my $snake_price;

my $wood_buy = 0;
my $wood_sell; 
my $span_buy = 0;
my $span_sell;
my $snake_buy = 0;
my $snake_sell;
#my $wood_have;
#my $span_have;
#my $snake_have;

####LOAD PRODUCTS
my $woodbines = 6;
my $spandex = 21;
my $snakeoil = 102;


###LOAD Ship
#my $hull = 100;
my $shields = 200;
my $shields_max = 200;
my $laser_power = 2;
my $laser_speed = 2;
my $laser_up = 0;
my $missiles = 10;
my $missile_power = 15;
my $shield_up = 0;
my $missile_up = 0;
my $crew_quarters = 2;
my $my_crew=1;
my $fuel = 20;
my $fuel_max = 20;
my $engines = 1;


####LOAD LOCAL
my $my_location = "earth";
my $t_location = "";
my %fly_planets;
$planets{$my_location} = [int(rand(50)+1),int(rand(50)+1),int(rand(50)+1),int(rand(50)+1)];

foreach (@planetfile) {
	$planets{$_}=[int(rand(250)+1),int(rand(250)+1),int(rand(250)+1),int(rand(250)+1)];
}

foreach (@crewfile) {
	my $random_planet = $planetfile[rand @planetfile];
	my $random_level = rand (80) + 1;
	my $c_charisma=int(rand(20)+1+$random_level);
	my $c_engineer=int(rand(20)+1+$random_level);
	my $c_fighter=int(rand(20)+1+$random_level);
	my $c_pilot=int(rand(20)+1+$random_level);
	my $c_cost = int(($c_charisma*$c_engineer*$c_fighter*$c_pilot)/100+rand(42));
	my $c_d_cost = int($c_cost/100 + rand(5));
	$crew_store{$_}= [
			$random_planet,
			$random_level,
			$c_charisma,
			$c_engineer,
			$c_fighter,
			$c_pilot,
			$c_cost,
			$c_d_cost
	];
}

$crew_store{"Fred"}=[$my_location,20,20,20,20,20,100,10];
$crew_store{"Barny"}=[$my_location,20,20,20,20,20,250,10];

foreach (@traderfile) {
	my $t_planet = $planetfile[rand @planetfile];
	my $t_wealth = int(rand(200) +1);
	my $t_connections = int(rand(20) +1);
	my $t_dodgy = int(rand(20));
#	my @missions;
		
	$trader_store{$_}= [
		$t_planet,
		$t_wealth,
		$t_connections,
		$t_dodgy,
	];
	for (my $i = 0;$i <int(rand 3);$i++) {
		push(@{$trader_store{$_}},create_trade_mission($_));
	}
	
} 


my @hash_keys    = keys %trader_store;
my $random_value = $hash_keys[rand @hash_keys];


$trader_store{"$random_value"}[0]=$my_location;


my %holder=player_stats(60);

sub player_stats {
	my %h = (
		k1 => 0,
		k2 => 0,
		k3 => 0,
		k4 => 0
	);	
	my $s_p = $_[0];
	while ($s_p>0) {
		foreach my $key (shuffle  keys %h) {
			if (int(rand(2))>=1) {
				$h{$key}++;
				$s_p--;
			}
		}

	}
	return %h;
}


#####Captain details
my $captain = "Bob";
my $cash = 2000;
my $freespace = 10;
my $charisma=$holder{"k1"};
my $engineer=$holder{"k2"};
my $fighter=$holder{"k3"};
my $pilot=$holder{"k4"};
my $experience = 0;
my $reputation = 20;
my $rep_name = "Harmless";
my $charisma_max = $charisma;
my $engineer_max = $engineer;
my $fighter_max = $fighter;
my $pilot_max = $pilot;
my $my_heat = 0;
my %my_trade_missions;
my %my_special_missions;


set_prices();
start_up();

sub start_up {
	my $mw = MainWindow->new;

	set_stats($mw);
	begin($mw);
}

sub begin {

	my ($mw) = @_;
	my $option = "x";
	complete_trade_mission();

	my $frm_body = $mw->Frame(-padx=>"4m", -pady=>"4m");
	my $frm_buttons = $mw->Frame();

	$frm_buttons->grid(-row=>1,-column=>2);
	$frm_body->grid(-row=>1,-column=>3,-sticky=>"n");

	$frm_buttons->Button(-text => "Trade", -command => sub{$frm_body->destroy; $frm_buttons->destroy;trade($mw)}, -width => 10)->grid(-row=>1,-column=>1,,-sticky=>"w");
	$frm_buttons->Button(-text => "Shipyard", -command => sub{$frm_body->destroy; $frm_buttons->destroy;shipyard($mw)}, -width => 10)->grid(-row=>2,-column=>1,,-sticky=>"w");
	$frm_buttons->Button(-text => "Fly", -command => sub{$frm_body->destroy; $frm_buttons->destroy;fly($mw)}, -width => 10)->grid(-row=>3,-column=>1,,-sticky=>"w");
	$frm_buttons->Button(-text => "Message Board", -command => sub{$frm_body->destroy; $frm_buttons->destroy;bulletin($mw)}, -width => 10)->grid(-row=>4,-column=>1,,-sticky=>"w");
	$frm_buttons->Button(-text => "Galactic Map", -command => sub{$mw->destroy;$option="c"}, -width => 10)->grid(-row=>5,-column=>1,,-sticky=>"w");
	$frm_buttons->Button(-text => "Quit", -command => sub{exit}, -width => 10)->grid(-row=>6,-column=>1,,-sticky=>"w");
	
	$frm_body->Label(-text=>"Welcome to $my_location captain $captain")->grid(-row=>1,-column=>1,,-sticky=>"w");
	$frm_body->Label(-text=>"We have a full range of services here on $my_location")->grid(-row=>3,-column=>1,-sticky=>"w");
	
	MainLoop;

	if ($cash <0) {
		print "\nYou are in the red, watch out the banks are nasty here!\n";
	}
	if ($cash <= (-500)) {
		system $^O eq 'MSWin32' ? 'cls' : 'clear';
		print "Letter from bank:\n
		 Dear Captain $captain,\n\nWe are sorry to inform you that due to your failure to payoff, and infact to increase your unarranged borrowing with us we have been forced to...\n 
We have sent one of our inforces to recover your body for sale to medical science to help your family pay off the debt.
		 \n\nRegards, ect. etc.\n\n";
		exit;
	}

	given ($option) {
	  when (/c/){status()}
	}
}

sub set_stats {

	my ($mw) = @_;
	my $frm_player = $mw->Frame();
	$frm_player->grid(-row=>1,-column=>1);
	
	$frm_player->Label(-text =>"Captain $captain\n")->grid(-row=>1,-column=>1,,-sticky=>"w");
	$frm_player->Label(-text =>"Status")->grid(-row=>2,-column=>1,-sticky=>"ew");
	$frm_player->Label(-text =>"Pilot" )->grid(-row=>3,-column=>1,,-sticky=>"w");
	$frm_player->Label(-text =>"Fighter")->grid(-row=>4,-column=>1,,-sticky=>"w");
	$frm_player->Label(-text =>"Engineer")->grid(-row=>5,-column=>1,,-sticky=>"w");
	$frm_player->Label(-text =>"Charisma")->grid(-row=>6,-column=>1,,-sticky=>"w");
	$frm_player->Label(-text =>"$pilot_max")->grid(-row=>3,-column=>2);
	$frm_player->Label(-text =>"$fighter_max")->grid(-row=>4,-column=>2);
	$frm_player->Label(-text =>"$engineer_max")->grid(-row=>5,-column=>2);
	$frm_player->Label(-text =>"$charisma_max")->grid(-row=>6,-column=>2);
	$frm_player->Label(-text =>"\nCash \$$cash")->grid(-row=>8,-column=>1,-sticky=>"w");
	$frm_player->Label(-text =>"$rep_name")->grid(-row=>9,-column=>1,-sticky=>"w");
	$frm_player->Label(-text =>"  ")->grid(-row=>1,-column=>3);
}

sub trade {
	my $option = "x";
	my ($mw) = @_;
	my $frm_body = $mw->Frame(-padx=>"4m", -pady=>"4m");
	my $frm_buttons = $mw->Frame();
	$frm_buttons->grid(-row=>1,-column=>2);
	$frm_body->grid(-row=>1,-column=>3,-sticky=>"n");
	
	$frm_buttons->Button(-text => "Buy", -command => sub{$frm_body->destroy; $frm_buttons->destroy;buy($mw)}, -width => 10)->grid(-row=>1,-column=>1,,-sticky=>"w");
	$frm_buttons->Button(-text => "Sell", -command => sub{$frm_body->destroy; $frm_buttons->destroy;sell($mw)}, -width => 10)->grid(-row=>2,-column=>1,,-sticky=>"w");
	$frm_buttons->Button(-text => "Back", -command => sub{$frm_body->destroy; $frm_buttons->destroy;begin($mw)}, -width => 10)->grid(-row=>4,-column=>1,,-sticky=>"w");
	
	$frm_body->Label(-text=>"You venture into the trading room")->grid(-row=>1,-column=>1,,-sticky=>"w");
	$frm_body->Label(-text=>"What's your business captain today?")->grid(-row=>3,-column=>1,-sticky=>"w");
	
}

sub buy {
	my ($mw) = @_;
	my $frm_body = $mw->Frame(-padx=>"4m", -pady=>"4m");
	my $frm_buttons = $mw->Frame();
	$frm_buttons->grid(-row=>1,-column=>2);
	$frm_body->grid(-row=>1,-column=>3,-sticky=>"n");

	$frm_buttons->Label(-text => "Woodbines at \$$wood_price")->grid(-row=>1,-column=>1,,-sticky=>"w");
	$frm_buttons->Label(-text => "Spandex at \$$span_price")->grid(-row=>2,-column=>1,,-sticky=>"w");
	$frm_buttons->Label(-text => "Snake oil at \$$snake_price")->grid(-row=>3,-column=>1,,-sticky=>"w");
	
	my ($wos,$sps,$sos) = qw"active active active";
	($wos,$sps,$sos) = qw"disabled disabled disabled" if ($freespace == 0);
	$wos = "disabled" if $cash < $wood_price;
	$sps = "disabled" if $cash < $span_price;
	$sos = "disabled" if $cash < $snake_price;

	$frm_buttons->Button(
		-state=>$wos,
		-text => "Buy", 
		-command => sub {
			my $s =rect_buy(int($cash/$wood_price));
			$wood_buy +=$s;
			$cash-=$s*$wood_price;
			$freespace-=$s;
			$mw->messageBox(-message=>"It's a deal\n\nyou have bought $s packs of woodbines");											
			set_stats($mw);
			$frm_body->destroy; 
			$frm_buttons->destroy;

			buy($mw)
		}, 
		-width => 3
	)->grid(-row=>1,-column=>2,,-sticky=>"w");
	
	$frm_buttons->Button(
		-state=>$sps,
		-text => "Buy", 
		-command => sub{
 			my $s =rect_buy(int($cash/$span_price));
  		$span_buy +=$s;
  		$cash-=$s*$span_price;
  		$freespace-=$s;
			$mw->messageBox(-message=>"It's a deal\n\nyou have bought $s boxes of spandex");
			set_stats($mw);
			$frm_body->destroy; 
			$frm_buttons->destroy;
			buy($mw)
		}, 
		-width => 3
	)->grid(-row=>2,-column=>2,,-sticky=>"w");
	
	$frm_buttons->Button(
		-state=>$sos,
		-text => "Buy",
		-command => sub{
	   	my $s =rect_buy(int($cash/$snake_price));
  		$snake_buy +=$s;
  		$cash-=$s*$snake_price;
  		$freespace-=$s;
			$mw->messageBox(-message=>"It's a deal\n\nyou have bought $s bottles of snake oil");
			set_stats($mw);
			$frm_body->destroy; 
			$frm_buttons->destroy;
			buy($mw)
		},
		-width => 3
	)->grid(-row=>3,-column=>2,,-sticky=>"w");
	
	$frm_buttons->Button(-text => "Back", -command => sub{$frm_body->destroy; $frm_buttons->destroy;trade($mw)}, -width => 10)->grid(-row=>4,-column=>1,,-sticky=>"w");
	$frm_body->Label(-text=>"You have \$$cash credits and $freespace cargo space")->grid(-row=>1,-column=>1,,-sticky=>"w");
	$frm_body->Label(-text=>"What's your business today captain?")->grid(-row=>3,-column=>1,-sticky=>"w");

	MainLoop;

#	trade();
	
}

sub rect_buy {
	my ($ret) = @_;
	if ($ret > $freespace) {$ret = $freespace;}
	#$freespace-=$ret;
	print "$ret\n";
	return $ret;
	
}

sub sell {
	#if ($freespace == 100) {trade();}
	my ($mw) = @_;
#	my $frm_player = $mw->Frame();
	my $frm_body = $mw->Frame(-padx=>"4m", -pady=>"4m");
	my $frm_buttons = $mw->Frame();
#	$frm_player->grid(-row=>1,-column=>1);
	$frm_buttons->grid(-row=>1,-column=>2);
	$frm_body->grid(-row=>1,-column=>3,-sticky=>"n");

#	set_stats($mw);
	
	$frm_buttons->Label(-text => "Woodbines at \$".$wood_price*.95)->grid(-row=>1,-column=>1,,-sticky=>"w");
	$frm_buttons->Label(-text => "Spandex at \$".$span_price*.95)->grid(-row=>2,-column=>1,,-sticky=>"w");
	$frm_buttons->Label(-text => "Snake oil at \$".$snake_price*.95)->grid(-row=>3,-column=>1,,-sticky=>"w");

	my ($wos,$sps,$sos) = qw"active active active";
	#($wos,$sps,$sos) = qw"disabled disabled disabled" if ($freespace == 0);
	$wos = "disabled" if $wood_buy == 0;
	$sps = "disabled" if $span_buy == 0;
	$sos = "disabled" if $snake_buy == 0;
	
	
	$frm_buttons->Button(
		-state=>$wos,
		-text => "Sell", 
		-command => sub {
  		$cash+=$wood_buy*$wood_price*.95;
  		$freespace+=$wood_buy;
  		$wood_sell+=$wood_buy;
			$mw->messageBox(-message=>"It's a deal\n\nyou have sold $wood_buy packs of woodbines for \$".$wood_buy*$wood_price*.95);		
			$wood_buy=0;
			set_stats($mw);									
			$frm_body->destroy; 
			$frm_buttons->destroy;
			sell($mw);
		}, 
		-width => 3
	)->grid(-row=>1,-column=>2,,-sticky=>"w");
	
	$frm_buttons->Button(
		-state=>$sps,
		-text => "Sell", 
		-command => sub{
  		$cash+=$span_buy*$span_price*.95;
  		$freespace+=$span_buy;
  		$span_sell+=$span_buy;
			$mw->messageBox(-message=>"It's a deal\n\nyou have sold $span_buy packs of woodbines for \$".$span_buy*$span_price*.95);		
			$span_buy=0;
			set_stats($mw);									
			$frm_body->destroy; 
			$frm_buttons->destroy;
			sell($mw);
		}, 
		-width => 3
	)->grid(-row=>2,-column=>2,,-sticky=>"w");
	
	$frm_buttons->Button(
		-state=>$sos,
		-text => "Sell",
		-command => sub{
  		$cash+=$snake_buy*$snake_price*.95;
  		$freespace+=$snake_buy;
  		$snake_sell+=$snake_buy;
			$mw->messageBox(-message=>"It's a deal\n\nyou have sold $snake_buy packs of woodbines for \$".$snake_buy*$snake_price*.95);		
			$snake_buy=0;	
			set_stats($mw);								
			$frm_body->destroy; 
			$frm_buttons->destroy;
			sell($mw);
		},
		-width => 3
	)->grid(-row=>3,-column=>2,,-sticky=>"w");
	$frm_buttons->Button(-text => "Back", -command => sub{$frm_body->destroy; $frm_buttons->destroy;trade($mw)}, -width => 10)->grid(-row=>4,-column=>1,,-sticky=>"w");
	$frm_body->Label(-text=>"In your cargo hold you have:")->grid(-row=>2,-column=>1,,-sticky=>"w");
	$frm_body->Label(-text=>"  $wood_buy packs of woodbines")->grid(-row=>3,-column=>1,,-sticky=>"w");
	$frm_body->Label(-text=>"  $span_buy boxes of spandex")->grid(-row=>4,-column=>1,,-sticky=>"w");
	$frm_body->Label(-text=>"  $snake_buy bottles of snake oil")->grid(-row=>5,-column=>1,,-sticky=>"w");			
	$frm_body->Label(-text=>"What's your business today captain?\n")->grid(-row=>1,-column=>1,-sticky=>"w");
		
	MainLoop;
	
}


sub fly {
  my ($mw_keep) = @_;
  my $mw=MainWindow->new;
  my $canvas = $mw->Scrolled('Canvas',-width => 900, -height => 500, -scrollbars => "osoe", -scrollregion => "-500 -500 500 500");
        #my $canvas = $mw->Canvas;
	$canvas->pack(-expand => 1, -fill => 'both');
	$mw->Button(
            -text    => 'Exit',
            -command => sub { exit },
        )->pack(-side=> 'right');    	
	$mw->Button(
            -text    => 'Fly',
            -command => sub {
            	update_planet();
	    				$wood_sell=0;
							$snake_sell=0;
							$span_sell=0;
							$cash-=10;
  						$my_location=$t_location;
            	$mw ->destroy;
            	set_prices();
            	space_encounter($mw_keep);
            }
        )->pack(-side=> 'right');
	
	create_item($canvas,'0c','0c','home','red',$my_location);
	foreach my $key (keys %planets) {
		#if ($cu%3==0) {print "\n";$cu++}
		if ($key ne $my_location) {
			my $dist = sqrt(($planets{$key}[0]-$planets{$my_location}[0])**2 + ($planets{$key}[3]-$planets{$my_location}[3])**2);
			if ($dist <=$fuel) {
				my $t_cost = int($dist*5);
				create_item($canvas, (($planets{$key}[0]-$planets{$my_location}[0])/2),(-($planets{$key}[3]-$planets{$my_location}[3])/2),
			, 'circle', 'blue', $key);
				$fly_planets{$key}="";

			} else {
				create_item($canvas, (($planets{$key}[0]-$planets{$my_location}[0])/2),(-($planets{$key}[3]-$planets{$my_location}[3])/2),
			, 'outer', 'black', $key);
			}
		}
	}
	my $old_fill = " ";
	my $circ_rad = $fuel/2;
	$canvas->create('oval',"-".$circ_rad."c",'-'.$circ_rad."c",$circ_rad."c",$circ_rad."c");
  $canvas->bind('circle', '<1>' => sub {handle_select($canvas)});
  $canvas->bind('circle', '<Double-1>' => sub {handle_invoke($canvas,$mw)});
	$canvas->bind('circle', '<Any-Enter>' =>  sub {p_enter($canvas,$old_fill)});
	$canvas->bind('circle', '<Any-Leave>' =>  sub {p_leave($canvas,$old_fill)});
	
  MainLoop;

	print "new planet $t_location..\n";

}


sub create_item {
    my ($can, $x, $y, $form, $color, $name) = @_;

    my $x2 = $x + 0.2;
    my $y2 = $y + 0.2;
    my $kind= 'oval';
    $can->create(
	($kind, "$x" . 'c', "$y" . 'c',
	"$x2" . 'c', "$y2" . 'c'),
	-tags => [$form,$color,$name],
	-fill => $color);
    $can->create('text',"$x" . 'c', ($y-0.2) . 'c',-text=>$name);
}

sub get_name {
    my ($can) = @_;
    my $item = $can->find('withtag', 'current');
    my @taglist = $can->gettags($item);
    my $name;
    foreach (@taglist) {
    	next if ($_ eq 'current');
    	next if ($_ eq 'circle');
    	next if ($_ eq 'blue');
    	next if ($_ eq 'red');
    	next if ($_ eq 'orange');
	$name = $_;
	last;
    }
    return $name;
}

sub handle_select {
   my ($can) = @_;
   my $name = get_name($can);
}

sub handle_invoke {
    my ($can) = @_;
    my $name = get_name($can);
    my $old = $can->find('withtag', 'orange');
    $can->itemconfigure($old, -fill => 'blue'); 
    $can->itemconfigure($old, -tags => ['circle','blue',$name]);		
    my $id = $can->find('withtag', 'current');
    $can->itemconfigure($id, -fill => 'orange');
    $can->itemconfigure($id, -tags => ['circle','orange',$name]);
    print "Planet set to $name...\n";
    $t_location = $name;
}

sub p_enter {
	my($c, $old_fill) = @_;
	my $id = $c->find('withtag', 'current');
	$c->itemconfigure($id, -fill => 'SeaGreen1');
}

sub p_leave {
	my($c, $old_fill) = @_;
	my $id = $c->find('withtag', 'current');
	my @taglist = $c->gettags($id);
	foreach (@taglist) {
		next if ($_ eq 'current');
		next if ($_ eq 'circle');
		$old_fill = $_;
	last;
	}
	$c->itemconfigure($id, -fill => $old_fill);
}

sub shipyard {

	my ($mw) = @_;

	my $frm_body = $mw->Frame(-padx=>"4m", -pady=>"4m");
	my $frm_buttons = $mw->Frame();
	$frm_buttons->grid(-row=>1,-column=>2);
	$frm_body->grid(-row=>1,-column=>3,-sticky=>"n");
	
	my ($rep, $arm) = qw(active active);
	$rep="disabled" if $shields == $shields_max;
	$arm="disabled" if $missiles == 10;
	
	$frm_buttons->StickyButton(
		-state=> $rep,
		-text => "Repair ship", 
		-command => sub{
			$cash-=($shields_max-$shields)*($shield_up+0.5);
			$shields=$shields_max;
  	  set_stats($mw);
		}, 
		-width => 10
	)->grid(-row=>1,-column=>1,,-sticky=>"w");
	
	$frm_buttons->StickyButton(
		-state=>$arm,
		-text => "Re-arm", 
		-command => sub{
			$cash-=(10-$missiles)*5*($missile_up+1);
			$missiles=10;
			set_stats($mw);
		}, 
		-width => 10
	)->grid(-row=>2,-column=>1,,-sticky=>"w");
	
	$frm_buttons->Button(-text => "Weapons upgrade", -command => sub{$frm_body->destroy; $frm_buttons->destroy;weapons_upgrade($mw)}, -width => 10)->grid(-row=>3,-column=>1,,-sticky=>"w");
	$frm_buttons->Button(-text => "Ship upgrades", -command => sub{$frm_body->destroy; $frm_buttons->destroy;ship_upgrade($mw)}, -width => 10)->grid(-row=>4,-column=>1,,-sticky=>"w");
	$frm_buttons->Button(-text => "Back", -command => sub{$frm_body->destroy; $frm_buttons->destroy;begin($mw)}, -width => 10)->grid(-row=>5,-column=>1,,-sticky=>"w");
	
	$frm_body->Label(-text=>"You venture into the shipyard room")->grid(-row=>1,-column=>1,,-sticky=>"w");
	$frm_body->Label(-text=>"What's your business today captain?")->grid(-row=>3,-column=>1,-sticky=>"w");

	MainLoop;

	
}

sub weapons_upgrade {

	my ($mw) = @_;
#	my $frm_player = $mw->Frame();
	my $frm_body = $mw->Frame(-padx=>"4m", -pady=>"4m");
	my $frm_buttons = $mw->Frame();
#	$frm_player->grid(-row=>1,-column=>1);
	$frm_buttons->grid(-row=>1,-column=>2);
	$frm_body->grid(-row=>1,-column=>3,-sticky=>"n");

#	set_stats($frm_player);
	
	my ($rep, $arm) = qw(disabled disabled);
	$rep="normal" if $fighter/(($laser_up+1)*5+15)>1&(($laser_up+1)**2)*100<=$cash;
	$arm="normal" if $fighter/(($missile_up+1)*3+12)>1&(($missile_up+1)**2)*200<=$cash;

	
	$frm_buttons->StickyButton(
		-state=> $rep,
		-text => "Upgrade lasers", 
		-command => sub{
  	  	 	$laser_power*=2;
  	  	 	$laser_speed++;
  	  	 	$cash-=(($laser_up+1)**2)*100;
  	  	 	$laser_up++;
  	  		set_stats($mw);
		}, 
		-width => 10
	)->grid(-row=>1,-column=>1,,-sticky=>"w");
	
	$frm_buttons->StickyButton(
		-state=>$arm,
		-text => "Upgrade missiles", 
		-command => sub{
  	  		$missile_power+=10;
  	  		$cash-=(($missile_up+1)**2)*200;
  	  		$missile_up++;
  	  		set_stats($mw);
		}, 
		-width => 10
	)->grid(-row=>2,-column=>1,,-sticky=>"w");
	
#	$frm_buttons->Button(-text => "Upgrade lasers", -command => sub{$mw -> destroy;$option= "w"}, -width => 10)->grid(-row=>3,-column=>1,,-sticky=>"w");
#	$frm_buttons->Button(-text => "Upgrade missiles", -command => sub{$mw -> destroy;$option= "s"}, -width => 10)->grid(-row=>4,-column=>1,,-sticky=>"w");
	$frm_buttons->Button(-text => "Back", -command => sub{$frm_body->destroy; $frm_buttons->destroy;shipyard($mw)}, -width => 10)->grid(-row=>3,-column=>1,,-sticky=>"w");
	
	$frm_body->Label(-text=>"Upgrade your lasers and missiles here")->grid(-row=>1,-column=>1,-columnspan=>2,-sticky=>"ew");
	$frm_body->Label(-text=>"..if you have enough experience")->grid(-row=>2,-column=>1,-columnspan=>2,-sticky=>"w");
	$frm_body->Label(-text=>"Laser stats:")->grid(-row=>3,-column=>1,-sticky=>"w");
	$frm_body->Label(-text=>"power $laser_power")->grid(-row=>4,-column=>1,-sticky=>"w");
	$frm_body->Label(-text=>"speed $laser_speed")->grid(-row=>5,-column=>1,-sticky=>"w");
	$frm_body->Label(-text=>" Upgrade cost \$".(($laser_up+1)**2)*100)->grid(-row=>6,-column=>1,-sticky=>"w");
	$frm_body->Label(-text=>"Missile stats:")->grid(-row=>3,-column=>2,-sticky=>"w");
	$frm_body->Label(-text=>"power $missile_power")->grid(-row=>4,-column=>2,-sticky=>"w");
	$frm_body->Label(-text=>" Upgrade cost \$".(($missile_up+1)**2)*200)->grid(-row=>5,-column=>2,-sticky=>"w");
	
	MainLoop;
	
#	shipyard()
}

sub ship_upgrade {

	my ($mw) = @_;
#	my $frm_player = $mw->Frame();
	my $frm_body = $mw->Frame(-padx=>"4m", -pady=>"4m");
	my $frm_buttons = $mw->Frame();
#	$frm_player->grid(-row=>1,-column=>1);
	$frm_buttons->grid(-row=>1,-column=>2);
	$frm_body->grid(-row=>1,-column=>3,-sticky=>"n");

#	set_stats($frm_player);
	
	my ($h, $c, $s, $e) = qw(disabled disabled disabled disabled);
	$h="normal" if ($engines*30)-($crew_quarters*5+$freespace)>=5&$cash>=500;
	$s="normal" if ($engineer+$engines-$shield_up*3)>=17&$cash>=(($shield_up+1)**2)*50;
	$c="normal" if ($engines*30)-($crew_quarters*5+$freespace)>=5&$cash>=1000;
	$e="normal" if ($engineer-($engines*2))>=18&$cash>=($engines**2*5000);	
	
	$frm_buttons->StickyButton(
		-state=> $h,
		-text => "Hold space", 
		-command => sub{
  	  		$freespace+=5;
  	  		$cash-=500;
		}, 
		-width => 10
	)->grid(-row=>1,-column=>1,,-sticky=>"w");
	
	$frm_buttons->StickyButton(
		-state=>$c,
		-text => "Crew quarters", 
		-command => sub{
  	  		$crew_quarters+=2;
  	  		$cash-=1000;
  	  		set_stats($mw);  	  		
		}, 
		-width => 10
	)->grid(-row=>2,-column=>1,,-sticky=>"w");
	
	$frm_buttons->StickyButton(
		-state=>$s,
		-text => "Upgrade shields", 
		-command => sub{
  	  		$shields+=50;
  	  		$shields_max+=50;
  	  		$cash-=(($shield_up+1)**2)*50;
  	  		$shield_up++;
  	  		set_stats($mw);
		}, 
		-width => 10
	)->grid(-row=>3,-column=>1,,-sticky=>"w");	
	
	$frm_buttons->StickyButton(
		-state=>$e,
		-text => "Upgrade engines", 
		-command => sub{
  	  		$engines+=1;
  	  		$cash-=($engines**2)*5000;
  	  		set_stats($mw);
		}, 
		-width => 10
	)->grid(-row=>4,-column=>1,,-sticky=>"w");	
		
	$frm_buttons->Button(-text => "Back", -command => sub{$frm_body->destroy; $frm_buttons->destroy;shipyard($mw)}, -width => 10)->grid(-row=>5,-column=>1,,-sticky=>"w");
	
	$frm_body->Label(-text=>"Add some more hold space and crew quarters")->grid(-row=>1,-column=>1,-columnspan=>2,-sticky=>"ew");
	$frm_body->Label(-text=>"or get some extra protection\n")->grid(-row=>2,-column=>1,-columnspan=>2,-sticky=>"w");
	$frm_body->Label(-text=>"Current")->grid(-row=>3,-column=>1,-sticky=>"w");
	$frm_body->Label(-text=>"Holdspace $freespace units")->grid(-row=>4,-column=>1,-sticky=>"w");
	$frm_body->Label(-text=>"Crewquarters $crew_quarters")->grid(-row=>5,-column=>1,-sticky=>"w");
	$frm_body->Label(-text=>"Shield strength $shields_max")->grid(-row=>6,-column=>1,-sticky=>"w");
	$frm_body->Label(-text=>"Engine rating $engines")->grid(-row=>7,-column=>1,-sticky=>"w");
	$frm_body->Label(-text=>" Upgrade costs")->grid(-row=>3,-column=>2,-sticky=>"w");
	$frm_body->Label(-text=>" Five extra hold units \$500")->grid(-row=>4,-column=>2,-sticky=>"w");
	$frm_body->Label(-text=>" Two crew quartes \$1000")->grid(-row=>5,-column=>2,-sticky=>"w");
	$frm_body->Label(-text=>" Plus 50 strength \$".(($shield_up+1)**2)*50)->grid(-row=>6,-column=>2,-sticky=>"w");
	$frm_body->Label(-text=>" Uprate engines \$".($engines**2*5000))->grid(-row=>7,-column=>2,-sticky=>"w");
	
	MainLoop;
	
#	shipyard();

}

sub bulletin {

	my ($mw) = @_;
	my $frm_body = $mw->Frame(-padx=>"4m", -pady=>"4m");
	my $frm_buttons = $mw->Frame();
	$frm_buttons->grid(-row=>1,-column=>2);
	$frm_body->grid(-row=>1,-column=>3,-sticky=>"n");

	my $c_exist = 0;
	foreach my $key (keys %crew_store) {
		if ($my_location=~/$crew_store{$key}[0]/) {
			$c_exist=1;
		}
	}

	my $s_exist = 0;
	foreach my $key (keys %trader_store) {
		if ($my_location=~/$trader_store{$key}[0]/) {
			$s_exist=1;
		}
	}
	
	my ($c, $s, $m) = qw(disabled disabled disabled);
	$c="normal" if $c_exist&$crew_quarters>$my_crew;
	$s="normal" if $s_exist;
	$m="normal" if $missiles == 12;
	
	$frm_buttons->Button(
		-state=> $c,
		-text => "Crew", 
		-command => sub{
			$frm_body->destroy; 
			$frm_buttons->destroy;
			crew($mw)
		}, 
		-width => 10
	)->grid(-row=>1,-column=>1,,-sticky=>"w");
	
	$frm_buttons->Button(
		-state=>$s,
		-text => "Special trade", 
		-command => sub{
			$frm_body->destroy; 
			$frm_buttons->destroy;
			s_trade($mw)
		}, 
		-width => 10
	)->grid(-row=>2,-column=>1,,-sticky=>"w");
	
	$frm_buttons->Button(
		-state=>$m,
		-text => "Missions", 
		-command => sub{
			$frm_body->destroy; 
			$frm_buttons->destroy;
			missions($mw)
		}, 
		-width => 10
	)->grid(-row=>3,-column=>1,,-sticky=>"w");	
	
	$frm_buttons->Button(-text => "Back", -command => sub{$frm_body->destroy; $frm_buttons->destroy;begin($mw)}, -width => 10)->grid(-row=>4,-column=>1,,-sticky=>"w");
	
	$frm_body->Label(-text=>"Find out about special services available at this location")->grid(-row=>1,-column=>1,,-sticky=>"w");
	$frm_body->Label(-text=>"What's your business captain today?")->grid(-row=>3,-column=>1,-sticky=>"w");

	MainLoop;

}

sub crew {

	my ($mw) = @_;
	my $frm_body = $mw->Frame(-padx=>"4m", -pady=>"4m");
	my $frm_buttons = $mw->Frame();
	$frm_buttons->grid(-row=>1,-column=>2);
	$frm_body->grid(-row=>1,-column=>3,-sticky=>"n");

	
	my $inc = 2;
	$frm_body->Label(-text=>"Lieutenant")->grid(-row=>3,-column=>1,-sticky=>"w");
	$frm_body->Label(-text=>"Charisma")->grid(-row=>4,-column=>1,-sticky=>"w");
	$frm_body->Label(-text=>"Engineer")->grid(-row=>5,-column=>1,-sticky=>"w");
	$frm_body->Label(-text=>"Fighter")->grid(-row=>6,-column=>1,-sticky=>"w");
	$frm_body->Label(-text=>"Pilot")->grid(-row=>7,-column=>1,-sticky=>"w");
	$frm_body->Label(-text=>"Hire cost")->grid(-row=>8,-column=>1,-sticky=>"w");
	$frm_body->Label(-text=>"Wage")->grid(-row=>9,-column=>1,-sticky=>"w");
	my $dis = "normal";
	
	foreach my $key (keys %crew_store) {
		if ($my_location=~/$crew_store{$key}[0]/) {
			$dis="disabled" if $crew_store{$key}[6]>$cash;
			$frm_buttons->Label(-text=>"$key")->grid(-row=>$inc,-column=>1,-sticky=>"w");
			$frm_buttons->Button(
				-state=> $dis,
				-text => "Hire", 
				-command => sub{
					$charisma_max = $crew_store{$key}[2] if $crew_store{$key}[2] > $charisma_max;
					$engineer_max = $crew_store{$key}[2] if $crew_store{$key}[3] > $engineer_max;
					$fighter_max = $crew_store{$key}[2] if $crew_store{$key}[4] > $fighter_max;
					$pilot_max = $crew_store{$key}[2] if $crew_store{$key}[5] > $pilot_max;
					$crew_store{$key}[0] = "ship";
					$my_crew++;
					$cash-=$crew_store{$key}[6];
					set_stats($mw);
				}, 
				-width => 10
			)->grid(-row=>$inc,-column=>2,-sticky=>"w");
 			#$frm_body->Label(-text=>"Lieutenants avaiable for hire")->grid(-row=>1,-column=>1,-columnspan=>3,-sticky=>"w");
			$frm_body->Label(-text=>$key)->grid(-row=>3,-column=>($inc/2)+1,-sticky=>"w");
			$frm_body->Label(-text=>$crew_store{$key}[2])->grid(-row=>4,-column=>($inc/2)+1,-sticky=>"w");		
			$frm_body->Label(-text=>$crew_store{$key}[3])->grid(-row=>5,-column=>($inc/2)+1,-sticky=>"w");
			$frm_body->Label(-text=>$crew_store{$key}[4])->grid(-row=>6,-column=>($inc/2)+1,-sticky=>"w");
			$frm_body->Label(-text=>$crew_store{$key}[5])->grid(-row=>7,-column=>($inc/2)+1,-sticky=>"w");
			$frm_body->Label(-text=>$crew_store{$key}[6])->grid(-row=>8,-column=>($inc/2)+1,-sticky=>"w");
			$frm_body->Label(-text=>$crew_store{$key}[7])->grid(-row=>9,-column=>($inc/2)+1,-sticky=>"w");
		}
		$inc++;		
		$inc++;
	}
	$frm_buttons->Button(-text => "Back", -command => sub{$frm_body->destroy; $frm_buttons->destroy;bulletin($mw)}, -width => 10)->grid(-row=>$inc+1,-column=>2,,-sticky=>"w");	
	
	MainLoop;

#	bulletin();
	
}

sub hire {
	my (@inp) = @_;
print $inp[2];
	if ($inp[2] > $charisma_max) {$charisma_max=$inp[2]}
	if ($inp[3] > $engineer_max) {$engineer_max=$inp[3]}
	if ($inp[4] > $fighter_max) {$fighter_max=$inp[4]}
	if ($inp[5] > $pilot_max) {$pilot_max=$inp[5]}
}

sub s_trade {

	my ($mw) = @_;
	my $option="x";
#	my $frm_player = $mw->Frame();
	my $frm_body = $mw->Frame(-padx=>"4m", -pady=>"4m");
	my $frm_buttons = $mw->Frame();
#	$frm_player->grid(-row=>1,-column=>1);
	$frm_buttons->grid(-row=>1,-column=>2);
	$frm_body->grid(-row=>1,-column=>3,-sticky=>"n");
#	set_stats($frm_player);
	
	my $inc=1;
	$frm_body->Label(-text=>"The following traders have mission here:")->grid(-row=>1,-column=>1,-sticky=>"w");
	foreach my $key (keys %trader_store) {
		if ($my_location=~/$trader_store{$key}[0]/) {
			my @missions = @{$trader_store{$key}};
			$frm_body->Label(-text=>"$key")->grid(-row=>$inc*2,-column=>1,-sticky=>"w");
			for (my $i=4;$i<@missions;$i++) {
				$frm_buttons->Label(-text=>"Mission $inc")->grid(-row=>$inc,-column=>1,-sticky=>"w");
				my @split = split(/,/,@missions[$i]);
				my $state = "normal";
				given ($split[0]) {
				  when (/1/) { 
						$frm_body->Label(-text=>"Mission $inc")->grid(-row=>$inc*2+1,-column=>1,-sticky=>"w");
						$frm_body->Label(-text=>"I have $split[1] associates who need transport to $split[2]")->grid(-row=>$inc*2+2,-column=>1,-sticky=>"w");
						$frm_body->Label(-text=>"If you can get them there safely I will pay \$$split[3]\n")->grid(-row=>$inc*2+3,-column=>1,-sticky=>"w");
						$state = "disabled" if ($crew_quarters - $my_crew)<$split[1];
				  }
				  when (/2/) { 
						$frm_body->Label(-text=>"Mission $inc")->grid(-row=>$inc*2+1,-column=>1,-sticky=>"w");
						$frm_body->Label(-text=>"I have $split[1] associates who need picking up from $split[2]")->grid(-row=>$inc*2+2,-column=>1,-sticky=>"w");
						$frm_body->Label(-text=>"If you can get them back here safely I will pay \$$split[3]\n")->grid(-row=>$inc*2+3,-column=>1,-sticky=>"w");
						$state = "disabled" if ($crew_quarters - $my_crew)<$split[1];
				  }	
				  when (/3/) { 
						$frm_body->Label(-text=>"Mission $inc")->grid(-row=>$inc*2+1,-column=>1,-sticky=>"w");
						$frm_body->Label(-text=>"I have a small package that needs delivering to $split[2]")->grid(-row=>$inc*2+2,-column=>1,-sticky=>"w");
						$frm_body->Label(-text=>"If you can get it there safely I will pay \$$split[3]\n")->grid(-row=>$inc*2+3,-column=>1,-sticky=>"w");
				  }
				  when (/2/) { 
						$frm_body->Label(-text=>"Mission $inc")->grid(-row=>$inc*2+1,-column=>1,-sticky=>"w");
						$frm_body->Label(-text=>"I want a small package picked up from $split[2]")->grid(-row=>$inc*2+2,-column=>1,-sticky=>"w");
						$frm_body->Label(-text=>"If you can get it back here safely I will pay \$$split[3]\n")->grid(-row=>$inc*2+3,-column=>1,-sticky=>"w");
				  }	
				}
				$frm_buttons->StickyButton(
					-state=> $state,
					-text => "Accept", 
					-command => sub{
						$option = $key;
						push (@{$my_trade_missions{$key}},@{$trader_store{$key}}[$inc]);
						pop @{$trader_store{$key}};
						$my_crew+=$split[1];
					}, 
					-width => 10
				)->grid(-row=>$inc,-column=>2,-sticky=>"w");				  			  				  			  
				
				$inc++;
			}
		}
			
	}
	$frm_buttons->Button(-text => "Back", -command => sub{$frm_body->destroy; $frm_buttons->destroy;bulletin($mw)}, -width => 10)->grid(-row=>$inc+1,-column=>2,,-sticky=>"w");	
	
	MainLoop;
	
	#create_trade_mission($option) if $option ne "x";
	
#	bulletin();
	
}

sub create_trade_mission {
	my ($trader) = @_;
	my $random_number = rand(4) +1;
	my $ret = "";
	my @hash_keys = keys %planets;
	my $p = $hash_keys[rand @hash_keys];	
	my $p_dist = abs(sqrt(($planets{$p}[0]-$planets{$my_location}[0])**2 + ($planets{$p}[3]-$planets{$my_location}[3])**2));
	my $h = rand($_[2]) + 1;
	my $l = 1;
	my $x = int(rand(4)+1);
	
	given ($random_number) {
	  when (/1/) {

	  	my $c = int((@{$trader_store{$trader}}[1]/10)+$h+$l*($p_dist)*2);
	  	chop($p);
	  	$ret = "1,$x,$p,$c,$h";
	  }
	  when (/2/) { 
	  	my $c = int((@{$trader_store{$trader}}[1]/10)+$h+$l*($p_dist)*4);
	  	chop($p);
	  	$ret = "2,$x,$p,$c,$h";	  
	  }
	  when (/3/) { 
	  	my $c = int((@{$trader_store{$trader}}[1]/10)+$h+$l*($p_dist)*2);
	  	chop($p);
	  	$ret = "3,$x,$p,$c,$h";  
	  }
	  when (/4/) { 
	  	my $c = int((@{$trader_store{$trader}}[1]/10)+$h+$l*($p_dist)*4);
	  	chop($p);
	  	$ret = "3,$x,$p,$c,$h";  	  
	  }
	  when (/5/) { 
	  
	  }
	  when (/6/) { 
	  
	  }
	}
#print "$ret\n";	
	return $ret;

}

sub complete_trade_mission {
	foreach my $key (keys %my_trade_missions) {
		my @split = split(/,/,@{$my_trade_missions{$key}});
		foreach (@split) {
			print $_;
		}
	}
			
	
	
}

sub missions {

}

sub status {
	my $mw = MainWindow->new;
	my $canvas = $mw->Scrolled('WorldCanvas',-width => 900, -height => 500, -scrollbars => "osoe", -scrollregion => "0 0 8 8");
	#my $canvas = $mw->Canvas;
	$canvas->pack(-expand => 1, -fill => 'both');
	$mw->Button(
	    -text    => 'Find',
	    -command => sub {$mw->destroy;},
	)->pack(-side=> 'right');  	
	$mw->Button(
	    -text    => 'Exit',
	    -command => sub { exit },
	)->pack(-side=> 'right');   

	foreach my $key (keys %planets) {
		if ($key ne $planets{$my_location}) {
			create_item2($canvas, ($planets{$key}[0]/100),($planets{$key}[3]/100),
			, 'circle', 'blue', $key);
		}
	}
	create_item2($canvas,($planets{$my_location}[0]/100),($planets{$my_location}[3]/100),'home','red',$my_location);
	$canvas->center($planets{$my_location}[0]/100,$planets{$my_location}[3]/100);

	$canvas->configure(-bandColor => 'purple');
	$canvas->CanvasBind('<3>'               => sub {$canvas->CanvasFocus;
							 $canvas->rubberBand(0)
							});
	$canvas->CanvasBind('<B3-Motion>'       => sub {$canvas->rubberBand(1)});
	$canvas->CanvasBind('<ButtonRelease-3>' => sub {my @box = $canvas->rubberBand(2);
							$canvas->zoom(2); $canvas->rubberBand(1);});
	#                                                      my @ids = $canvas->find('enclosed', @box);
	#                                                      foreach my $id (@ids) {$canvas->delete($id)}
	#                                                     });
	# Note: '<B3-ButtonRelease>' will be called for any ButtonRelease!
	# You should use '<ButtonRelease-3>' instead.

	# If you want the rubber band to look smooth during panning and
	# zooming, add rubberBand(1) update calls to the appropriate key-bindings:

	$canvas->CanvasBind(   '<Up>' => sub {$canvas->rubberBand(1);});
	$canvas->CanvasBind( '<Down>' => sub {$canvas->rubberBand(1);});
	$canvas->CanvasBind( '<Left>' => sub {$canvas->rubberBand(1);});
	$canvas->CanvasBind('<Right>' => sub {$canvas->rubberBand(1);});
	$canvas->CanvasBind('<i>' => sub {$canvas->zoom(1.25); $canvas->rubberBand(1);});
	$canvas->CanvasBind('<o>' => sub {$canvas->zoom(0.8);  $canvas->rubberBand(1);});

	MainLoop;
	
	begin();
}

sub create_item2 {
    my ($can, $x, $y, $form, $color, $name) = @_;

    my $x2 = $x + 0.01;
    my $y2 = $y + 0.01;
    my $kind= 'oval';
    $can->create(
	($kind, "$x" . 'c', "$y" . 'c',
	"$x2" . 'c', "$y2" . 'c'),
	-tags => [$form,$color,$name],
	-fill => $color);
    $can->create('text',($x+0.01), ($y+0.031) . 'c',-text=>$name);
}


sub space_encounter {

	my ($mw, $encs) = @_;
	$encs ||=rand(5)+1;
	my $inp = 2;
	my $frm_body = $mw->Frame(-padx=>"4m", -pady=>"4m");
	my $frm_buttons = $mw->Frame();
	$frm_buttons->grid(-row=>1,-column=>2);
	$frm_body->grid(-row=>1,-column=>3,-sticky=>"n");
	given ($inp) {
		when (/1/) {
#			my $mw = MainWindow->new;
			$mw->Label(-text => "Long range scanners have identified an\nunknown ship in your vicinity\n\nAvailable options:")->pack;
			$mw->Button(
				-text => "Run away"
			)->pack;
			$mw->Button(
				-text => "Send hail"
			)->pack;
			$mw->Button(
				-text => "Approach slowly"
			)->pack;
			$mw->Button(
				-text => "Approach at pace",
				-command => sub {exit}
			)->pack(-side => 'left');	
		MainLoop;
		}

		when (/2/) {

			my $b_magnificence = int((rand(4)+1)*($reputation/100)+1);
			#my $b_hull = int(rand(100)+1)*$b_magnificence;
			my $b_shields = int(rand(200)+1)*$b_magnificence;
			my $b_laser_power= int(rand(8)+1)*$b_magnificence;
			my $b_laser_speed= int(rand(2)+1)+$b_magnificence;
			my $b_pilot=int(rand(20) + 1)*$b_magnificence;
			my $b_fighter = int(rand(20) + 1)*$b_magnificence;
			my $b_engineer = int(rand(20) + 1)*$b_magnificence;
			my $surrender = 0;
			my $runaway=0;
			my $wrong_key;
		
		
		
			$frm_buttons->Button(
				-text => "Run away", 
				-command => sub{
					for(my $i=1;$i<=$b_laser_speed;$i++) {	
						if (rand(2)>=1-($b_fighter/100)+($pilot_max/100)) {
								$shields-=$b_laser_power;
								if ($shields <0) {
									print "\nOh no... my chance for a long and fruitful life has been dashed\n";
									$mw->destroy;
								}
						}
					}
				
					if (rand(2)>= 1.2-($pilot_max/100)){
						$frm_body->Label(-text=>"\nYou manged to escape...")->grid(-row=>5,-column=>1,-sticky=>"w");
						$encs--;
						$frm_body->destroy;
						$frm_buttons->destroy;
						if ($encs<1) {
							begin($mw);
						} else {
							space_encounter($mw,$encs);
						}
					} else {
						$frm_body->Label(-text=>"\nStill in pursuit...")->grid(-row=>5,-column=>1,-sticky=>"w")	;
						$frm_body->Label(-text=>"$shields")->grid(-row=>3,-column=>2,-sticky=>"w");	
						$frm_body->Label(-text=>"$b_shields")->grid(-row=>3,-column=>3,-sticky=>"w");	
					}
				}, 
				-width => 10
			)->grid(-row=>1,-column=>1,,-sticky=>"w");
		
			$frm_buttons->Button(
				-text => "Fire Lasers", 
				-command => sub{
					for(my $i=1;$i<=$laser_speed;$i++) {
						if (rand(2)>=1-($fighter_max/100)+($b_pilot/100)) {
			 	  		$b_shields-=$laser_power;
		 	  			if ($b_shields<0) {
			 	  			bandit_destroyed($b_magnificence);
			 	  			set_stats($mw);
								$frm_body->Label(-text=>"You have destroyed the bad guy\nThere\'s a bounty payment of \$".$b_magnificence**2*100);
								$encs--;
								$frm_body->destroy;
								$frm_buttons->destroy;
								if ($encs<1) {
									begin($mw);
								} else {
									space_encounter($mw,$encs);
								}				 	  			 
			 	  		}
						}
					}
					for(my $i=1;$i<=$b_laser_speed;$i++) {	
						if (rand(2)>=1-($b_fighter/100)+($pilot_max/100)) {
								$shields-=$b_laser_power;
								if ($shields <0) {
									print "\nOh no... my chance for a long and fruitful life has been dashed\n";
									$mw->destroy;
								}
						}
					}
					$frm_body->Label(-text=>"$shields")->grid(-row=>3,-column=>2,-sticky=>"w");	
					$frm_body->Label(-text=>"$b_shields")->grid(-row=>3,-column=>3,-sticky=>"w");	
				}, 
				-width => 10
			)->grid(-row=>2,-column=>1,,-sticky=>"w");	
		
			$frm_buttons->Button(
				-text => "Fire Missiles", 
				-command => sub{
					$missiles--;
		  		if (rand(2)>=0.7+($b_pilot/100)) {
		  			$b_shields-=$missile_power;	
	 	  			if ($b_shields<0) {
		 	  			bandit_destroyed($b_magnificence);
		 	  			set_stats($mw);
							$frm_body->label(text=>"You have destroyed the bad guy\nThere\'s a bounty payment of \$".$b_magnificence**2*100);
							$encs--;
							$frm_body->destroy;
							$frm_buttons->destroy;
							if ($encs<1) {
								begin($mw);
							} else {
								space_encounter($mw,$encs);
							}				 	  			 
		 	  		}
		  		}
					for(my $i=1;$i<=$b_laser_speed;$i++) {	
						if (rand(2)>=1-($b_fighter/100)+($pilot_max/100)) {
								$shields-=$b_laser_power;
								if ($shields <0) {
									print "\nOh no... my chance for a long and fruitful life has been dashed\n";
									$mw->destroy;
								}
						}
					}	
					$frm_body->Label(-text=>"$shields")->grid(-row=>3,-column=>2,-sticky=>"w");	
					$frm_body->Label(-text=>"$b_shields")->grid(-row=>3,-column=>3,-sticky=>"w");
					$frm_body->Label(-text=>"$missiles")->grid(-row=>4,-column=>2,-sticky=>"w");		  		
				}, 
				-width => 10
			)->grid(-row=>3,-column=>1,,-sticky=>"w");	
		
			$frm_buttons->StickyButton(
				-text => "Surrender", 
				-command => sub{
					if($cash<=0){

							$wood_buy=0;
							$snake_buy=0;
							$span_buy=0;
							$freespace=100;
							$cash-=int($cash*.5);
							print "\nYour French ancestry comes to the for and you surrender forthwith\n";
							print "The pirates strip you of all your goods and half your bank balance\n";
							$encs--;
							$frm_body->destroy;
							$frm_buttons->destroy;
							if ($encs<1) {
								begin($mw);
							} else {
								space_encounter($mw,$encs);
							}
					}
					else {
						print "The pirates turn down your offer to surrender - they want you dead!!!";
					}
				}, 
				-width => 10
			)->grid(-row=>4,-column=>1,,-sticky=>"w");	


	
			$frm_body->Label(-text=>"You've been attacked by pirates - defend yourself")->grid(-row=>1,-column=>1,-sticky=>"w");			
			$frm_body->Label(-text=>"My Status")->grid(-row=>2,-column=>2,-sticky=>"w");	
			$frm_body->Label(-text=>"Pirate status")->grid(-row=>2,-column=>3,-sticky=>"w");
			$frm_body->Label(-text=>"Shields")->grid(-row=>3,-column=>1,-sticky=>"w");	
			$frm_body->Label(-text=>"$shields")->grid(-row=>3,-column=>2,-sticky=>"w");	
			$frm_body->Label(-text=>"$b_shields")->grid(-row=>3,-column=>3,-sticky=>"w");	
			$frm_body->Label(-text=>"Missiles")->grid(-row=>4,-column=>1,-sticky=>"w");	
			$frm_body->Label(-text=>"$missiles")->grid(-row=>4,-column=>2,-sticky=>"w");
			$frm_body->Label(-text=>"???")->grid(-row=>3,-column=>4,-sticky=>"w");		
		}
	}
}



sub bandit_destroyed {

	my ($b_magnificence) =@_;
	print "\nWell done you have destroyed the bandit\n Here\'s a reward of \$".$b_magnificence**2*100;
	print "\n";
	$cash+=$b_magnificence**2*100;
	$experience+=$b_magnificence**2;
	$reputation+=$b_magnificence**2;
	if ($experience%10==0) {
		$reputation++;
		%holder = player_stats(3);
		$charisma+=$holder{"k1"};
		$engineer+=$holder{"k2"};
		$fighter+=$holder{"k3"};
		$pilot+=$holder{"k4"};				
	}
	update_captain();

}

sub get_quantity {
	print "How many?: ";
	my $ret;
	while (<>) {
		$ret = $_;
		last if ($_ =~/^[1-9]+\d*$/);
	}
	return $ret;
}

sub get_planet {
	my $ret;
	while (<>) {
		chomp;
		$ret = $_;		
		last if /\b$ret\b/ ~~ %fly_planets;
	}

	return $ret;
}

sub start {
	my $start_key;

	while ($start_key !~/[$_[0]]/) {
		$start_key = get_key();
	}
	return $start_key;
}


sub set_prices {
	$wood_price = int($woodbines + 0.05*($planets{$my_location}[1]) - 0.05*($planets{$my_location}[2]) + rand(100)/$charisma);
	$span_price = int($spandex + 0.2*($planets{$my_location}[2]) - 0.2*($planets{$my_location}[0])+ rand(350)/$charisma);
	$snake_price = int($snakeoil + $planets{$my_location}[2] - $planets{$my_location}[0]+ rand(1700)/$charisma);
}


####Control the program
sub get_key {

	ReadMode 4;
	my $key;
	while (not defined ($key = ReadKey(-1))) {
	}
	ReadMode 0;
	return $key;
	
}


sub update_planet {
	$planets{$my_location}[0]+= int(($snake_buy + $snake_sell)/10 - ($span_buy/50) - ($wood_sell/150));
	$planets{$my_location}[1]+= int(($wood_sell/150)+($span_sell/50)+($snake_sell/10)-($wood_buy/150)-($span_buy/50)-($snake_buy/10));
	$planets{$my_location}[2]+= int(($span_sell/50) + ($wood_sell/150) - ($span_buy/50) - ($snake_sell/10));
	for my $key (keys %planets) {
		if ($planets{$key}[0] > 100) {
			$planets{$key}[0] = 100
		}
		if ($planets{$key}[0] < 1) {
			$planets{$key}[0] = 1
		}
		if ($planets{$key}[1] > 100) {
			$planets{$key}[1] = 100
		}
		if ($planets{$key}[1] < 1) {
			$planets{$key}[1] = 1
		}
		if ($planets{$key}[2] > 100) {
			$planets{$key}[2] = 100
		}
		if ($planets{$key}[2] < 1) {
			$planets{$key}[2] = 1
		}		
			
	}
}

sub update_captain {
	given ($reputation) {
	  when ($_<100) {$rep_name = "Harmless";}
	  when ($_<300){$rep_name = "Goon";}
	  when ($_<700){$rep_name = "Average";}
	  when ($_<1500){$rep_name = "Compotent";}
	  when ($_<3100){$rep_name = "Good";}
	  when ($_<6300){$rep_name = "Dangerous";}
	  when ($_<12500){$rep_name = "Exceptional";}
	  default {$rep_name = "Elite";}
	}
}


sub load_file {
  open (MYINFILE, $_[0]) or die "can't open file $_[0]";
  my @ret = <MYINFILE>;
  chomp(@ret);
  close MYINFILE;
  return @ret;
}

