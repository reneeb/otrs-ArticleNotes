# --
# Copyright (C) 2016 Perl-Services.de, http://perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::FilterContent::ArticleNotesIcons;

use strict;
use warnings;

our @ObjectDependencies = qw(
    Kernel::Language
    Kernel::Output::HTML::Layout
    Kernel::System::Web::Request
    Kernel::Config
    Kernel::System::Ticket
    Kernel::System::Log
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $JSONObject   = $Kernel::OM->Get('Kernel::System::JSON');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my @ArticleIDs = ${ $Param{Data} } =~ m{<input \s+ type="hidden" \s+ class="ArticleID" \s+ value="([^"]+)"}xmsg;

    my %ArticlesWithNotes;
    my %ArticlesNotes;

    my $Name = $ConfigObject->Get('ArticleNotes::Field') || 'ArticleNote';

    for my $ArticleID ( @ArticleIDs ) {
        my %Article = $TicketObject->ArticleGet(
            ArticleID     => $ArticleID,
            DynamicFields => 1,
            UserID        => $Self->{UserID},
        );

        if ( $Article{"DynamicField_$Name"} ) {
            $ArticlesWithNotes{$ArticleID} = 1;
            $ArticlesNotes{$ArticleID} = $Article{"DynamicField_$Name"};
        }
    }

    my $JSON      = $JSONObject->Encode( Data => \%ArticlesWithNotes );
    my $NotesJSON = $JSONObject->Encode( Data => \%ArticlesNotes );

    my $Code = qq~
        var ArticlesWithNotes = $JSON;
        var ArticlesNotes     = $NotesJSON;
        \$('input[class="ArticleID"]').each( function() {
            var ArticleID = \$(this).val();

            if( ArticlesWithNotes[ArticleID] == 1 ) {
                var Title = ArticleNotes[ArticleID];
                \$(this).parent().append( '<span class="fa fa-exclamation-circle" title="' + Title + '"></span>' );
            }
        });
    ~;

    ${ $Param{Data} } =~ s{Core\.App\.Ready.*?\{\K}{$Code};

    return 1;
}

1;
