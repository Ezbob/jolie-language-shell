$(function() {
	var editor = ace.edit("editor");
    var result = ace.edit("output");
    var runButton = $('.runbutton');
    var exitButton = $('.exitbutton');
    var snippets = $('#snippets');
 
	runButton.click( function() {

        var request = { url: "/runCode", data: { short: false, program: editor.getValue() } };

        result.selectAll();
        result.insert("Running code...");

        $.post(request).done( function(data) {
            result.selectAll();
            result.insert(data);
        }).fail( function() {
            result.selectAll();
            result.insert("ERROR: Connection failed.");
        });
    });

    exitButton.click( function() {
        
        result.selectAll();
        result.insert("Shutting down. Please wait...");
        window.location.href = "/shutdown";
    });

    snippets.change( function() {

        var url = "resources/snippets/" + snippets.val();
        
        $.post(url).done( function(data) { 
            editor.selectAll();
            editor.insert(data);
        }).fail( function() {
            console.log("Snippet loading failed...");
        });
    });
});