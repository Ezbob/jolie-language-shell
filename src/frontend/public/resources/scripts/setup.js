$(function() {      
    var editor = ace.edit("editor");
    editor.setTheme("ace/theme/chrome");
    editor.session.setMode("ace/mode/jolie");  

    var result = ace.edit("output");
    result.setTheme("ace/theme/chrome");
    
    result.setReadOnly(true);
    result.setHighlightActiveLine(false);
    result.setShowPrintMargin(false);
    result.$blockScrolling = Infinity;
});