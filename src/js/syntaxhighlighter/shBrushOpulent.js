/**
 * SyntaxHighlighter
 * http://alexgorbatchev.com/SyntaxHighlighter
 *
 * SyntaxHighlighter is donationware. If you are using it, please donate.
 * http://alexgorbatchev.com/SyntaxHighlighter/donate.html
 *
 * @version
 * 3.0.83 (July 02 2010)
 *
 * @copyright
 * Copyright (C) 2004-2010 Alex Gorbatchev.
 *
 * @license
 * Dual licensed under the MIT and GPL licenses.
 */
;(function()
{
	// CommonJS
	typeof(require) != 'undefined' ? SyntaxHighlighter = require('shCore').SyntaxHighlighter : null;

	function Brush()
	{
		// Contributed by Erik Peterson.

		var keywords =	'if elsif else unless case when each while do until include loop break end';

		var builtins =	'Array Bignum Binding Class Continuation Dir Exception FalseClass File::Stat File Fixnum Fload ' +
						'Hash Integer IO MatchData Method Module NilClass Numeric Object Proc Range Regexp String Struct::TMS Symbol ' +
						'ThreadGroup Thread Time TrueClass doctype';

		var doc_nodes = 'validname VALIDNAME validName valid_name valid-name bread tomato ham ul li span div a b c p ' +
										'input number hash_var array_var node'


		this.regexList = [
			// { regex: /[\.\#\&]\w+([\-\_]\w+)*/g,	css: 'variable color1' },		// one line comments
			{ regex: /(\w+([\-\_]\w+)*)?([\.\#]\w+([\-\_]\w+)*)+/g,	css: 'variable color1' },		// one line comments
			{ regex: new RegExp(this.getKeywords(doc_nodes), 'gm'),    css: 'variable color1' },	// $global, @instance, and @@class variables
			{ regex: new RegExp(this.getKeywords('def'), 'gm'),    css: 'constants' },	// $global, @instance, and @@class variables
			{ regex: /\/.*/g,	css: 'comments' },		// one line comments
			{ regex: SyntaxHighlighter.regexLib.doubleQuotedString,		css: 'string' },		// double quoted strings
			{ regex: SyntaxHighlighter.regexLib.singleQuotedString,		css: 'string' },		// single quoted strings
			{ regex: /\b[A-Z0-9_]+\b/g,									css: 'constants' },		// constants
			{ regex: /:[a-z][A-Za-z0-9_]*/g,							css: 'color2' },		// symbols
			{ regex: /(\$|@@|@)\w+/g,									css: 'variable' },	// $global, @instance, and @@class variables
			{ regex: new RegExp(this.getKeywords(keywords), 'gm'),		css: 'keyword' },		// keywords
			{ regex: new RegExp(this.getKeywords(builtins), 'gm'),		css: 'color1' },		// builtins
			];

		// this.forHtmlScript(SyntaxHighlighter.regexLib.aspScriptTags);
	};

	Brush.prototype	= new SyntaxHighlighter.Highlighter();
	Brush.aliases	= ['opulent', 'op'];

	SyntaxHighlighter.brushes.Opulent = Brush;

	// CommonJS
	typeof(exports) != 'undefined' ? exports.Brush = Brush : null;
})();
