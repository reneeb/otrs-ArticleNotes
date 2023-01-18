# --
# Kernel/Language/hu_ArticleNotes.pm - the Hungarian translation of ArticleNotes
# Copyright (C) 2016 - 2023 Perl-Services.de, https://www.perl-services.de/
# Copyright (C) 2016 Balázs Úr, http://www.otrs-megoldasok.hu/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::hu_ArticleNotes;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    my $Lang = $Self->{Translation} || {};

    # Kernel/Config/Files/ArticleNotes.xml
    $Lang->{'Adds a link in the article menu to change the article note.'} =
        'Egy hivatkozást ad a bejegyzésmenübe a bejegyzés jegyzetének megváltoztatásához.';
    $Lang->{'Adds a link in the article menu to articles with notes.'} =
        'Egy hivatkozást ad a bejegyzésmenübe a jegyzeteket tartalmazó bejegyzésekhez.';
    $Lang->{'Frontend module registration for the agent interface.'} =
        'Előtétprogram-modul regisztráció az ügyintézői felülethez.';
    $Lang->{'Change article note.'} = 'Bejegyzés jegyzetének megváltoztatása.';
    $Lang->{'Change Article Note'} = 'Bejegyzés jegyzetének megváltoztatása';
    $Lang->{'Defines which dynamic field stores the note.'} =
        'Meghatározza, hogy mely dinamikus mező tárolja a jegyzetet.';

    # Kernel/Output/HTML/FilterElementPost/ArticleNotes.pm
    $Lang->{'Article Note'} = 'Bejegyzés jegyzet';

    # Kernel/Output/HTML/Templates/Standard/AgentArticleNote.tt
    $Lang->{'Set article note'} = 'Bejegyzés jegyzetének beállítása';
    $Lang->{'Cancel & close window'} = 'Megszakítás és az ablak bezárása';
    $Lang->{'Submit'} = 'Elküldés';
}

1;
