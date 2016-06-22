$( function() {      
    var editor = ace.edit("editor");
    editor.setTheme("ace/theme/chrome");
    editor.session.setMode("ace/mode/jolie");
    editor.$blockScrolling = Infinity;
    editor.setShowPrintMargin(false);

    $.get("snippets/helloworld.ol").done( function(data) {
    	editor.selectAll();
        editor.insert(data); 
    });

    var result = ace.edit("output");
    result.setTheme("ace/theme/chrome");
    
    result.setReadOnly(true);
    result.setHighlightActiveLine(false);
    result.setShowPrintMargin(false);
    result.$blockScrolling = Infinity;
} );