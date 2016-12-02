# --
# Kernel/Language/de_ArticleNotes.pm - the German translation of ArticleNotes
# Copyright (C) 2016 Perl-Services.de, http://perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_ArticleNotes;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    my $Lang = $Self->{Translation} || {};

    # Kernel/Config/Files/ArticleNotes.xml
    $Lang->{'Adds a link in the article menu to change the article note.'} = '';
    $Lang->{'Adds a link in the article menu to articles with notes.'} = '';
    $Lang->{'Frontend module registration for the agent interface.'} = '';
    $Lang->{'Change article note.'} = '';
    $Lang->{'Change Article Note'} = '';
    $Lang->{'Defines which dynamic field stores the note.'} = '';

    # Kernel/Output/HTML/FilterElementPost/ArticleNotes.pm
    $Lang->{'Article Note'} = '';

    # Kernel/Output/HTML/Templates/Standard/AgentArticleNote.tt
    $Lang->{'Set article note'} = '';
    $Lang->{'Cancel & close window'} = '';
    $Lang->{'Submit'} = '';
}

1;
