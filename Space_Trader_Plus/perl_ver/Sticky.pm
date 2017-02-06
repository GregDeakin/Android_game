#!/usr/local/bin/perl -w

package StickyButton;
require Tk::Widget;
require Tk::Button;
@ISA = qw(Tk::Button);
Construct Tk::Widget 'StickyButton';

sub invoke
{
 my $w = shift;
 my $state = $w->cget('-state');
 $w->configure('-state' => 'disabled'); 
 $w->update;
 $w->Callback('-command');
 $w->configure('-state' => 'disabled'); 
}

