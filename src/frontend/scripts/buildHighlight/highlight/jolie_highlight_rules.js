define(function(require, exports, module) {
    "use strict";
    
    var oop = require("../lib/oop");
    var TextHighlightRules = require("./text_highlight_rules").TextHighlightRules;

    var JolieHighlightRules = function() {

        var keywords = (
            "include|if|else|main|void|bool|long|" +
            "char|int|string|any|undefined|raw|" +
            "double|while|for|cset|init|include|" +
            "new|outputPort|inputPort|Interfaces|" +
            "Protocol|Location|Agregates|is_defined|" +
            "undef|interface|RequestResponse|OneWay|" +
            "type|install|scope|define|embedded|foreach|" +
            "with|instanceof|constants|global|execution|" +
            "throw|throws"
        );

        var buildinConstants = ("nullProcess");
        
        var executionKeywords = ("concurrent|sequential|single"); // TODO put this only in execution block?

        var keywordMapper = this.createKeywordMapper({
            "keyword": keywords,
            "constant.language": buildinConstants
        }, "identifier");
    
        // regexp must not have capturing parentheses. Use (?:) instead.
        // regexps are ordered -> the first match is used
       this.$rules = {
            "start" : [
                {
                    token : "comment",
                    regex : "\\/\\/.*$"
                },
                {
                    token : "comment", // multi line comment
                    regex : "\\/\\*",
                    next : "comment"
                },
                {
                    token : "string", // single line
                    regex : '["](?:(?:\\\\.)|(?:[^"\\\\]))*?["]'
                },
                {
                    token : "string",
                    regex : "['](?:(?:\\\\.)|(?:[^'\\\\]))*?[']"
                },
                {
                    token : "text",
                    regex : "\\s+"
                },
                {
                    token : "constant.language.boolean",
                    regex : "(?:true|false)\\b"
                },
                {
                    token : "constant.numeric", // float
                    regex : /[+-]?\d[\d_]*(?:(?:\.[\d_]*)?(?:[eE][+-]?[\d_]+)?)?[LlSsDdFfYy]?\b/
                },
                {
                    token : "lparen",
                    regex : "[[({]"
                },
                {
                    token : "rparen",
                    regex : "[\\])}]"
                },
                {
                    token : "attoken",
                    regex : "\@"
                },
                {
                    token : "compose",
                    regex : "[;\|]"
                },
                {
                    token : keywordMapper,
                    regex : "[a-zA-Z_$][a-zA-Z0-9_$]*\\b"
                }
            ],
            
            "comment" : [
                {
                    token : "comment", // multi closing comment
                    regex : ".*?\\*\\/",
                    next : "start"
                },
                {
                    token : "comment", // comment spanning whole line
                    regex : ".+"
                }
            ]
        };
    };
    
    oop.inherits(JolieHighlightRules, TextHighlightRules);
    
    exports.JolieHighlightRules = JolieHighlightRules;

});
