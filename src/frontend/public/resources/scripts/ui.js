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
            
        $.post({
        	url: url,
        	data: content
        }).done(function(data) {
            result.selectAll();
            result.insert(data);
        }).fail(function() {
            console.log("Failed!");
        });
    });
});