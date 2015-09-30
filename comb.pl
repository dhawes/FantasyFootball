#!/usr/bin/perl

use strict;

use Math::Combinatorics;
use XML::LibXML;

my @QB = ();
my @WR = ();
my @RB = ();
my @TE = ();
my @K  = ();
my @D  = ();

my $parser = XML::LibXML->new();
my $doc    = $parser->parse_file($ARGV[0]);

my %Points = ();

foreach my $player ($doc->findnodes('/query/results/team/roster/players/player'))
{
    my($player_name) = $player->findnodes('./name/full');
    my($player_position) = $player->findnodes('./display_position');
    my($player_points) = $player->findnodes('./player_points/total');
#    print $player_name->to_literal." ".
#          $player_position->to_literal." ".
#          $player_points->to_literal."\n";
    if($player_position->to_literal eq "QB")
    {
        push(@QB, $player_name->to_literal);
    }
    elsif($player_position->to_literal eq "WR")
    {
        push(@WR, $player_name->to_literal);
    }
    elsif($player_position->to_literal eq "RB")
    {
        push(@RB, $player_name->to_literal);
    }
    elsif($player_position->to_literal eq "TE")
    {
        push(@TE, $player_name->to_literal);
    }
    elsif($player_position->to_literal eq "K")
    {
        push(@K, $player_name->to_literal);
    }
    elsif($player_position->to_literal eq "DEF")
    {
        push(@D, $player_name->to_literal);
    }
    $Points{$player_name->to_literal} = $player_points->to_literal;
}

#foreach my $key (sort(keys %Points))
#{
#    print "$key = ".$Points{$key}."\n";
#}

my @QBcomb = combine(1, @QB);
my @WRcomb = combine(3, @WR);
my @RBcomb = combine(2, @RB);
my @TEcomb = combine(1, @TE);
my @Kcomb  = combine(1, @K);
my @Dcomb  = combine(1, @D);

my @Teams = ();

#printSet(\@QBcomb);
#printSet(\@WRcomb);
#printSet(\@RBcomb);

# lazy to not use recursion here
for(my $q = 0; $q < @QBcomb; $q++)
{
    for(my $w = 0; $w < @WRcomb; $w++)
    {
        for(my $r = 0; $r < @RBcomb; $r++)
        {
            for(my $t = 0; $t < @TEcomb; $t++)
            {
                for(my $k = 0; $k < @Kcomb; $k++)
                {
                    for(my $d = 0; $d < @Dcomb; $d++)
                    {
                        my @Team = ();
                        push(@Team, $QBcomb[$q]);
                        push(@Team, $WRcomb[$w]);
                        push(@Team, $RBcomb[$r]);
                        push(@Team, $TEcomb[$t]);
                        push(@Team, $Kcomb[$k]);
                        push(@Team, $Dcomb[$d]);
                        push(@Teams, \@Team);
                    }
                }
            }
        }
    }
}

printTeams(\@Teams, $ARGV[1]);

sub printSet
{
    my $aref = shift;
    foreach my $ref (@{$aref})
    {
        for(my $i = 0; $i < @{$ref}; $i++)
        {
            print ${$ref}[$i]." ";
        }
        print "\n";
    }
}

sub printTeams
{
    my $aref = shift;
    my $thresh = shift;
    my $total_teams = scalar(@{$aref});
    my $min = 0;
    my $max = 0;
    my $winning_teams = 0;
    foreach my $ref (@{$aref})
    {
        my $points = 0;
        print "( ";
        for(my $i = 0; $i < @{$ref}; $i++)
        {
            for(my $j = 0; $j < @{${$ref}[$i]}; $j++)
            {
                print '"'.${${$ref}[$i]}[$j].'" ';
                $points += $Points{${${$ref}[$i]}[$j]};
            }
        }
        print ")\n";
        print $points."\n";
        if($points > $thresh)
        {
            $winning_teams++;
        }
        if($points > $max) { $max = $points; }
        if($points < $min || $min == 0) { $min = $points; }
    }
    print "combinations = ".
          scalar(@QBcomb)." (QB) * ".
          scalar(@WRcomb)." (WR) * ".
          scalar(@RBcomb)." (RB) * ".
          scalar(@TEcomb)." (TE) * ".
          scalar(@Kcomb)." (K) * ".
          scalar(@Dcomb)." (DEF) = ".
          (scalar(@QBcomb) * scalar(@WRcomb) * scalar(@RBcomb) *
           scalar(@TEcomb) * scalar(@Kcomb) * scalar(@Dcomb)).
          "\n";
    print "Total teams = $total_teams\n";
    print "Number of teams that could have won = $winning_teams\n";
    print "Percentage of teams that could have won = ".
        ($winning_teams * 100) / $total_teams."\n";
    print "Min points: $min\n";
    print "Max points: $max\n";
}

sub printArray
{
    my $aref = shift;
    for(my $i = 0; $i < @{$aref}; $i++)
    {
        print ${$aref}[$i]." ";
    }
    print ", ";
}
