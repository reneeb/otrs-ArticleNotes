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

    my $LayoutObject   = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $JSONObject     = $Kernel::OM->Get('Kernel::System::JSON');
    my $ArticleObject  = $Kernel::OM->Get('Kernel::System::Ticket::Article');
    my $ConfigObject   = $Kernel::OM->Get('Kernel::Config');
    my $LanguageObject = $Kernel::OM->Get('Kernel::Language');
    my $ParamObject    = $Kernel::OM->Get('Kernel::System::Web::Request');

    my $TicketID = $ParamObject->GetParam( Param => 'TicketID' );

    my @ArticleIDs = ${ $Param{Data} } =~ m{<input \s+ type="hidden" \s+ class="ArticleID" \s+ value="([^"]+)"}xmsg;

    return 1 if !@ArticleIDs;

    my %ArticlesWithNotes;
    my %ArticlesNotes;

    my $Name  = $ConfigObject->Get('ArticleNotes::Field') || 'ArticleNote';
    my $Title = $LanguageObject->Translate('Note');

    for my $ArticleID ( @ArticleIDs ) {
        my $BackendObject = $ArticleObject->BackendForArticle(
            TicketID  => $TicketID,
            ArticleID => $ArticleID,
        );

        my %Article = $BackendObject->ArticleGet(
            TicketID      => $TicketID,
            ArticleID     => $ArticleID,
            DynamicFields => 1,
            UserID        => $Self->{UserID},
        );

        if ( $Article{"DynamicField_$Name"} ) {
            $ArticlesWithNotes{$ArticleID} = 1;
            $ArticlesNotes{$ArticleID} = $LayoutObject->Output(
                Template => '[% Data.Text | html %]',
                Data     => { Text => $Article{"DynamicField_$Name"} },
            );
        }
    }

    my $JSON      = $JSONObject->Encode( Data => \%ArticlesWithNotes );
    my $NotesJSON = $JSONObject->Encode( Data => \%ArticlesNotes );

    my $Code = qq~
        <script type="text/javascript">//<![CDATA[
            var ArticleNotes      = $NotesJSON;
            var NotesTitle        = "$Title";
            var ArticlesWithNotes = $JSON;
        //]]></script>
    ~;

    ${ $Param{Data} } =~ s{</head>}{$Code</head>};

    return 1;
}

1;
