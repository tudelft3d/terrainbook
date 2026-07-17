Vanilla APA doesn't display any other fields (no "note" no "annotate"), so I took the file `apa-annotated-bibliography.csl` from there <https://github.com/citation-style-language/styles/blob/master/apa-annotated-bibliography.csl> which shows them, but they are indented and on another line. 

So I modified a bit the CSL file, and it works.

Use note like this and it'll work:

```bibtex
@article{vanKreveld96,
	author = {Van Kreveld, Marc},
	journal = {International Journal of Geographical Information Science},
	keywords = {contour lines},
	number = {5},
	pages = {523--540},
	title = {{E}fficient methods for isoline extraction from a {TIN}},
	volume = {10},
	year = {1996},
	note = {This is important stuff and https://www.tudelft.nl}
}
```
