$(function() {
	var editor = ace.edit("editor");
    var result = ace.edit("output");
	$('.runbutton').click(function() {
        var stuff = editor.getValue();

        var url = "http://localhost:9002/runCode";

        var content = {
		      short: false,
		      program: stuff
		    };
            
        $.post({
        	url: url,
        	data: content
        }).always(function(){
            console.log("Sending...");
        }).done(function(data){
            result.gotoLine(result.session.getLength());
            result.insert(data + "\n");
            result.gotoLine(result.session.getLength());
        }).fail(function(){
            console.log("Failed!");
        });
    });
});