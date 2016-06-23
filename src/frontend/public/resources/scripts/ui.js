$(function() {
	var editor = ace.edit("editor");
    var result = ace.edit("output");

	$('.runbutton').click(function() {
        var stuff = editor.getValue();

        var url = "/runCode";

        var content = {
		      short: false,
		      program: stuff
		    };
        
        result.selectAll();
        result.insert("Running code...");

        $.post({
        	url: url,
        	data: content
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
        var url = "snippets/" + snippets.val();
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