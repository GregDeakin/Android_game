package Fly;

use strict;
use warnings;
use Exporter 'import';
our $VERSION = '1.00';
our @EXPORT  = qw(fly create_item get_name handle_select handle_invoke p_enter p_leave);


sub fly {
	system $^O eq 'MSWin32' ? 'cls' : 'clear';
	print "Location\\t\Shields\tLasers\t\Missiles\n$my_location\t\t$shields\tL$laser_up\t$missiles (L$missile_up)\n\n";
	#print "Where to:\n (E)arth\n M(i)cro\n M(a)cro\n (B)ack\n\n";
	print "Planets\t\tCost\n";

	my $cu = 1;

        my $mw = MainWindow->new;
        my $canvas = $mw->Scrolled('Canvas',-width => 900, -height => 500, -scrollbars => "osoe", -scrollregion => "-500 -500 500 500");
        #my $canvas = $mw->Canvas;
	$canvas->pack(-expand => 1, -fill => 'both');
	$mw->Button(
            -text    => 'Exit',
            -command => sub { exit },
        )->pack(-side=> 'right');    	
	$mw->Button(
            -text    => 'Fly',
            -command => [$mw => 'destroy']
        )->pack(-side=> 'right');
	
	create_item($canvas,'0c','0c','home','red',$my_location);
	foreach my $key (keys %planets) {
		#if ($cu%3==0) {print "\n";$cu++}
		if ($key !=$my_location) {
			my $dist = sqrt(($planets{$key}[0]-$planets{$my_location}[0])**2 + ($planets{$key}[3]-$planets{$my_location}[3])**2);
			if ($dist <=$fuel) {
				my $t_cost = int($dist*5);
				create_item($canvas, (($planets{$key}[0]-$planets{$my_location}[0])/2),(($planets{$key}[3]-$planets{$my_location}[3])/2),
			, 'circle', 'blue', $key);
				$fly_planets{$key}="";

			} else {
				create_item($canvas, (($planets{$key}[0]-$planets{$my_location}[0])/2),(($planets{$key}[3]-$planets{$my_location}[3])/2),
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
	
	if ($my_location != $t_location) {
		update_planet();
	      	$my_location = $t_location;
	} else {begin();}

	$wood_sell=0;
	$snake_sell=0;
	$span_sell=0;
	$cash-=10;
	my $i = 0;
	if ($my_location =~m/earth/) {
		$i = int(rand(5)+5);
	} elsif ($my_location =~ m/macro/ig) {
		$i = 10;#int(rand(2));
	} else {
		$i = int(rand(10));
	}

	for ($i;$i<=10;$i++) {
		space_encounter();
	}
	set_prices();
	begin();
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
    my ($can, $mw) = @_;
    my $name = get_name($can);
    my $old = $can->find('withtag', 'orange');
    $can->itemconfigure($old, -fill => 'blue'); 
    $can->itemconfigure($old, -tags => ['circle','blue',$name]);		
    my $id = $can->find('withtag', 'current');
    $can->itemconfigure($id, -fill => 'orange');
    $can->itemconfigure($id, -tags => ['circle','orange',$name]);
    print "Planet set to $name...\n";
    $t_location = $name;
    $mw->destroy;
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

1;
