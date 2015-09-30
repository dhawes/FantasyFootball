#!/usr/bin/perl

use strict;

use Math::Combinatorics;
use XML::LibXML;

my %Points = ();
my @Comp = ();

foreach my $file(@ARGV)
{
    my @QB = ();
    my @WR = ();
    my @RB = ();
    my @TE = ();
    my @K  = ();
    my @D  = ();

    my $parser = XML::LibXML->new();
    my $doc    = $parser->parse_file($file);


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
    push(@Comp, \@Teams);
}

#print scalar(@{$Comp[0]})."\n";
#print scalar(@{$Comp[1]})."\n";
#print $Comp[0]."\n";
#print $Comp[1]."\n";

cmpTeams($Comp[0], $Comp[1]);

sub cmpTeams
{
    my $team1 = shift;
    my $team2 = shift;
    my $total = scalar(@{$team1}) * scalar(@{$team2});
    my $team1_wins = 0;
    my $team2_wins = 0;
    my $i = 0;
    for($i = 0; $i < @{$team1}; $i++)
    {
        my $team1_points = getPoints(${$team1}[$i]);
        for(my $j = 0; $j < @{$team2}; $j++)
        {
            my $team2_points = getPoints(${$team2}[$j]);
            if($team1_points > $team2_points)
            {
                $team1_wins++;
            }
            else
            {
                $team2_wins++;
            }
        }
    }
    print "i = $i\n";
    print "Total games = $total\n";
    print "Team 1 wins: $team1_wins\n";
    print "Team 2 wins: $team2_wins\n";
}

sub getPoints
{
    my $aref = shift;
    my $points = 0;
    for(my $i = 0; $i < @{$aref}; $i++)
    {
        for(my $j = 0; $j < @{${$aref}[$i]}; $j++)
        {
            $points += $Points{${${$aref}[$i]}[$j]};
        }
    }
    return $points;
}
