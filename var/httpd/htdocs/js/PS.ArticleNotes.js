        function PSArticleNotesShow( ArticleID, Event ) {
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
                '    <div style="z-index: 5; background-color: #EEE; border: 1px solid #CCC; padding: 6px"><h2>' + NotesTitle + '</h2><pre>' +
                         Note +
                '    </pre></div> ' +
                '</div> ';

            $(Layer).appendTo('body');
            $('#events-layer').fadeIn('fast');
        }

        Core.App.Ready( function() {
            $('input[class="ArticleID"]').each( function() {
                var ArticleID = $(this).val();

                if( ArticlesWithNotes[ArticleID] == 1 ) {
                    var Span = $( '<span class="fa fa-exclamation-circle"></span>' );
                    $(this).parent().append( Span );

                    Span.bind('mouseover', function( event ) {
                        PSArticleNotesShow( ArticleID, event );
                    }).bind( 'mouseout', function() {
                        $('#events-layer').fadeOut('fast');
                        $('#events-layer').remove();
                    });
                }
            });
        });

