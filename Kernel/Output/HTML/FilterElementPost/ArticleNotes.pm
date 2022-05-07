# --
# Copyright (C) 2016 - 2022 Perl-Services.de, https://www.perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::FilterElementPost::ArticleNotes;

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

    my $LanguageObject = $Kernel::OM->Get('Kernel::Language');
    my $LayoutObject   = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject    = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $JSONObject     = $Kernel::OM->Get('Kernel::System::JSON');

    my $Title    = $LanguageObject->Translate('Article Note');
    my $Baselink = $LayoutObject->{Baselink};
    my $TicketID = $ParamObject->GetParam( Param => 'TicketID' );

    ${ $Param{Data} } =~ s{
        ( <a \s name="Article(\d+)" .*? <ul \s class="Actions"> ) \s+ <li>
    }{
        $1 . $Self->__Linkify( $Baselink, $TicketID, $2, $Title ) . '<li>';
    }exmsg;

    return 1;
}

sub __Linkify {
    my ($Self, $Baselink, $TicketID, $ArticleID, $Title, $HashRef ) = @_;

    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    my %Article = $TicketObject->ArticleGet(
        ArticleID => $ArticleID,
        UserID    => $Self->{UserID},
    );

    my $Link = qq~
        <li class="ArticleNote">
            <a href="${Baselink}Action=AgentArticleNote;TicketID=$TicketID;ArticleID=$ArticleID" title="$Title" class="AsPopup Popup_Type_TicketAction">$Title</a>
        </li>
    ~;

    return $Link;
}

1;
