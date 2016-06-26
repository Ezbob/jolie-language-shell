$(function() {
	var editor = ace.edit("editor");
    var result = ace.edit("output");

	$('.runbutton').click(function() {

        var url = "/runCode";

        result.selectAll();
        result.insert("Running code...");

        $.post({
        	url: url,
        	data: { short: false, program: editor.getValue() }
        }).done(function(data) {
            result.selectAll();
            result.insert(data);
        }).fail(function() {
            result.selectAll();
            result.insert("ERROR: Connection failed.");
        });
    });

    var snippets = $('#snippets');
 
    snippets.change( function() {
        var url = "resources/snippets/" + snippets.val();
        $.get(url).done(function(data) { 
            editor.selectAll();
            editor.insert(data);
        }).fail(function(){
            console.log("Snippet loading failed...");
        });
    });

    $('.exitbutton').click( function() {
        result.selectAll();
        result.insert("Shutting down. Please wait...");
        window.location.href = "/shutdown";
    });
});