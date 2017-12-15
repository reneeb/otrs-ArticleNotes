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
        function PSArticleNotesShow( ArticleID, Event ) {
            var ArticleNotes = $NotesJSON;

            var PosX = 0;
            var PosY = 0;

            var jsEvent = Event || window.event;
            if (jsEvent.pageX || jsEvent.pageY) {

                PosX = jsEvent.pageX;
                PosY = jsEvent.pageY;
            }
            else if (jsEvent.clientX || jsEvent.clientY) {

                PosX = jsEvent.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
                PosY = jsEvent.clientY + document.body.scrollTop + document.documentElement.scrollTop;
            }

            // increase X position to don't be overlapped by mouse pointer
            PosX = PosX + 15;

            var Note = ArticleNotes[ArticleID];
            var Layer = '<div id="events-layer" class="Hidden" style="position:absolute; top: ' + PosY + 'px; left:' + PosX + 'px; z-index: 999;"> ' +
                '    <div style="z-index: 5; background-color: #EEE; border: 1px solid #CCC; padding: 6px"><h2>$Title</h2><code>' +
                         Note +
                '    </code></div> ' +
                '</div> ';

            \$(Layer).appendTo('body');
            \$('#events-layer').fadeIn('fast');
        }

        Core.App.Ready( function() {
            var ArticlesWithNotes = $JSON;
            \$('input[class="ArticleID"]').each( function() {
                var ArticleID = \$(this).val();

                if( ArticlesWithNotes[ArticleID] == 1 ) {
                    var Span = \$( '<span class="fa fa-exclamation-circle"></span>' );
                    \$(this).parent().append( Span );

                    Span.bind('mouseover', function( event ) {
                        PSArticleNotesShow( ArticleID, event );
                    }).bind( 'mouseout', function() {
                        \$('#events-layer').fadeOut('fast');
                        \$('#events-layer').remove();
                    });
                }
            });
        });
        //]]></script>
    ~;

    ${ $Param{Data} } =~ s{</body>}{$Code</body>};

    return 1;
}

1;
