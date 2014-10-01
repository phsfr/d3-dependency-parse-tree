#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
from argparse import ArgumentParser, FileType

"""
This module converts a CoNLL2009 formatted file of dependency parsed sentences
into an HTML file with visualizations of the dependency parse trees.
"""

HTML_HEADER = """<html>
<head>
	<meta charset="utf-8">
	<title>Dependency Parse Tree visualization using d3.js</title>
</head>
<body>
<link rel="stylesheet" href="css/bootstrap.min.css">
<link rel="stylesheet" href="css/main.css">
<link rel="stylesheet" href="tree.css">
<script type="text/javascript" src="d3.js"></script>
<script type="text/javascript" src="dependency-tree.js"></script>

"""

HTML_SENTENCE = """
<div class="container">
<h2>{title}</h2>
<div class="tree" id="s{sentence_id}">
	<svg height="0"></svg>
</div>
<textarea id="data{sentence_id}" class="form-control" style="display:none;">
{conll}
</textarea>
<button id="draw{sentence_id}" class="btn btn-default">draw</button>
</div>
<script type="text/javascript">
    drawTree('#s{sentence_id}.tree svg', d3.select('#data{sentence_id}')[0][0].value, false);
</script>
"""

HTML_FOOTER = """
</body>
</html>
"""


def conll2html(input_file, output_file):
    conll_doc = input_file.read()

    output_file.write(HTML_HEADER)
    for i, conll_str in enumerate(conll_doc.strip().split('\n\n')):
        sentence = ' '.join(line.split()[1] for line in conll_str.split('\n'))
        output_file.write(HTML_SENTENCE.format(title=sentence, conll=conll_str, sentence_id=i))
    output_file.write(HTML_FOOTER)  


if __name__ == '__main__':
    parser = ArgumentParser(prog='conll2009_visualizer')

    parser.add_argument('input_file', type=FileType('r'),
        help='CoNLL2009 input file')

    parser.add_argument('output_file',
        nargs='?', type=FileType('w'), default=sys.stdout,
        help=('HTML output file (optional)'))

    args = parser.parse_args(sys.argv[1:])
    conll2html(args.input_file, args.output_file)
