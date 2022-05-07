# --
# Copyright (C) 2016 - 2022 Perl-Services.de, https://www.perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package var::packagesetup::ArticleNotes;

use strict;
use warnings;

use utf8;

use File::Basename;
use List::Util qw(first);
use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = qw(
    Kernel::Config
    Kernel::System::SysConfig
    Kernel::System::Valid
    Kernel::System::DynamicField
);

=head1 NAME

TicketAttachments.pm - code to excecute during package installation

=head1 SYNOPSIS

All functions

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # create needed sysconfig object
    my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');

    # rebuild ZZZ* files
    $SysConfigObject->WriteDefault();

    # define the ZZZ files
    my @ZZZFiles = (
        'ZZZAAuto.pm',
        'ZZZAuto.pm',
    );

    # reload the ZZZ files (mod_perl workaround)
    for my $ZZZFile (@ZZZFiles) {

        PREFIX:
        for my $Prefix (@INC) {
            my $File = $Prefix . '/Kernel/Config/Files/' . $ZZZFile;
            next PREFIX if !-f $File;
            do $File;
            last PREFIX;
        }
    }

    return $Self;
}

=item CodeInstall()

run the code install part

    my $Result = $CodeObject->CodeInstall();

=cut

sub CodeInstall {
    my ( $Self, %Param ) = @_;

    # create dynamic fields 
    $Self->_CreateDynamicFields();

    return 1;
}

=item CodeReinstall()

run the code reinstall part

    my $Result = $CodeObject->CodeReinstall();

=cut

sub CodeReinstall {
    my ( $Self, %Param ) = @_;

    return 1;
}

=item CodeUpgrade()

run the code upgrade part

    my $Result = $CodeObject->CodeUpgrade();

=cut

sub CodeUpgrade {
    my ( $Self, %Param ) = @_;

    $Self->_CreateDynamicFields();

    return 1;
}

=item CodeUninstall()

run the code uninstall part

    my $Result = $CodeObject->CodeUninstall();

=cut

sub CodeUninstall {
    my ( $Self, %Param ) = @_;

    return 1;
}

=item _CreateDynamicFields()

creates all dynamic fields that are necessary for reporting 

    my $Result = $CodeObject->_CreateDynamicFields();

=cut

sub _CreateDynamicFields {
    my ( $Self, %Param ) = @_;

    my $ValidObject        = $Kernel::OM->Get('Kernel::System::Valid');
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

    my $ValidID = $ValidObject->ValidLookup(
        Valid => 'valid',
    );

    # get all current dynamic fields
    my $DynamicFieldList = $DynamicFieldObject->DynamicFieldListGet(
        Valid => 0,
    );

    # get the list of order numbers (is already sorted).
    my @DynamicfieldOrderList;
    for my $Dynamicfield ( @{$DynamicFieldList} ) {
        push @DynamicfieldOrderList, $Dynamicfield->{FieldOrder};
    }

    # get the last element from the order list and add 1
    my $NextOrderNumber = 1;
    if (@DynamicfieldOrderList) {
        $NextOrderNumber = $DynamicfieldOrderList[-1] + 1;
    }

    # get the definition for all dynamic fields for ITSM
    my @DynamicFields = $Self->_GetDynamicFieldsDefinition();

    # create a dynamic fields lookup table
    my %DynamicFieldLookup;
    for my $DynamicField ( @{$DynamicFieldList} ) {
        next if ref $DynamicField ne 'HASH';
        $DynamicFieldLookup{ $DynamicField->{Name} } = $DynamicField;
    }

    # create or update dynamic fields
    DYNAMICFIELD:
    for my $DynamicField (@DynamicFields) {

        my $CreateDynamicField;

        # check if the dynamic field already exists
        if ( ref $DynamicFieldLookup{ $DynamicField->{Name} } ne 'HASH' ) {
            $CreateDynamicField = 1;
        }

        # check if new field has to be created
        if ($CreateDynamicField) {

            # create a new field
            my $FieldID = $DynamicFieldObject->DynamicFieldAdd(
                Name       => $DynamicField->{Name},
                Label      => $DynamicField->{Label},
                FieldOrder => $NextOrderNumber,
                FieldType  => $DynamicField->{FieldType},
                ObjectType => $DynamicField->{ObjectType},
                Config     => $DynamicField->{Config},
                ValidID    => $ValidID,
                UserID     => 1,
            );
            next DYNAMICFIELD if !$FieldID;

            # increase the order number
            $NextOrderNumber++;
        }

    }

    return 1;
}

=item _GetDynamicFieldsDefinition()

returns the definition for reporting related dynamic fields

    my $Result = $CodeObject->_GetDynamicFieldsDefinition();

=cut

sub _GetDynamicFieldsDefinition {
    my ( $Self, %Param ) = @_;

    # define all dynamic fields for reporting
    my @DynamicFields = (
        {
            Name       => 'ArticleNote',
            Label      => 'Note',
            FieldType  => 'TextArea',
            ObjectType => 'Article',
            Config     => {
                DefaultValue => '',
            },
        },
    );

    return @DynamicFields;
}

1;


=back

=head1 TERMS AND CONDITIONS

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut

