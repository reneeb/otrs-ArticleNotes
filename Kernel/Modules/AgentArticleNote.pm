# --
# Copyright (C) 2016 Perl-Services.de, http://perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentArticleNote;
 
use strict;
use warnings;
 
our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;
 
    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}
 
sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject        = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $BackendObject      = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    my $Name   = $ConfigObject->Get('ArticleNotes::Field')  || 'ArticleNote';
    my $Config = $DynamicFieldObject->DynamicFieldGet( Name => $Name );

    my @Params = qw(ArticleID TicketID);
    my %GetParam;

    for my $Param ( @Params, "DynamicField_$Name" ) {
        $GetParam{$Param} = $ParamObject->GetParam( Param => $Param ) // '';
    }

    if ( $Self->{Subaction} eq 'Save' && $GetParam{ArticleID} ) {
        my $Success = $BackendObject->ValueSet(
            DynamicFieldConfig => $Config,
            ObjectID           => $GetParam{ArticleID},
            Value              => $GetParam{"DynamicField_$Name"},
            UserID             => $Self->{UserID},
        );

        if ( $Success ) {
            $TicketObject->_TicketCacheClear( TicketID => $GetParam{TicketID} );

            return $LayoutObject->PopupClose(
                URL => 'Action=AgentTicketZoom&TicketID=' . $GetParam{TicketID}
                    . '&ArticleID=' . $GetParam{ArticleID},
            );
        }
    }

    my %Article = $TicketObject->ArticleGet(
        ArticleID     => $GetParam{ArticleID},
        DynamicFields => 1,
        UserID        => $Self->{UserID},
    );

    my $Field = $BackendObject->EditFieldRender(
        DynamicFieldConfig => $Config,
        ParamObject        => $ParamObject,
        LayoutObject       => $LayoutObject,
        Mandatory          => 0,
        Value              => $Article{"DynamicField_$Name"},
    );

    my $Output = $LayoutObject->Header( Type => 'Small' );
    $Output .= $LayoutObject->Output(
        TemplateFile => 'AgentArticleNote',
        Data         => {
            %Param,
            %GetParam,
            %{$Field || {} },
        },
    );
    $Output .= $LayoutObject->Footer( Type => 'Small' );

    return $Output;
}
 
1;

