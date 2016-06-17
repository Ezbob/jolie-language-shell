$(function() {
	var editor = ace.edit("editor");
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
        }).done(function(d){
            console.log("Sent! " + d);
        }).fail(function(){
            console.log("Failed!");
        });
    });
});