#!/usr/bin/env python
# USAGE: ./un2up.py < in.pdf > out.pdf
# It takes a 2up page and returns it to 1up
#
# Adapted from http://stackoverflow.com/questions/7047656/why-my-code-not-correctly-split-every-page-in-a-scanned-pdf
# and http://unix.stackexchange.com/questions/12482/split-pages-in-pdf

import copy, sys
from pyPDF2 import PdfFileWriter, PdfFileReader
input = PdfFileReader(sys.stdin)
output = PdfFileWriter()
for i in range(input.getNumPages()):
	p = input.getPage(i)
	q = copy.copy(p)

	bl = p.mediaBox.lowerLeft
	ur = p.mediaBox.upperRight

	print >> sys.stderr, 'splitting page',i
	print >> sys.stderr, '\tlowerLeft:',p.mediaBox.lowerLeft
	print >> sys.stderr, '\tupperRight:',p.mediaBox.upperRight

# altered for landscaped 2up of portrait original
	p.mediaBox.upperRight = (ur[0]/2, ur[1])
	p.mediaBox.lowerLeft = bl

# altered for landscaped 2up of portrait original
	q.mediaBox.upperRight = ur
	q.mediaBox.lowerLeft = (ur[0]/2, bl[1])

# This bit allows adjustment if each 2up page alternates which side is odd and even

	if i%2==0:
		output.addPage(p)
		output.addPage(q)
	else:
		output.addPage(p)
		output.addPage(q)

output.write(sys.stdout)