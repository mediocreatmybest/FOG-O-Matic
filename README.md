# FOG-O-Matic

Some items I've found useful with FOG from the FOG Project as well as scripts to make my life easier.

[Fog project](https://fogproject.org/)

## Fog-Snapins

[Fog-Snapins](https://github.com/mediocreatmybest/FOG-O-Matic/tree/main/FOG-Snapins)

Deployment scripts with FOG, mostly written in PowerShell, feel free to do any pull requests to fix or add items.

## iPXE

[iPXE](https://github.com/mediocreatmybest/FOG-O-Matic/tree/main/iPXE)

iPXE scripts and files for the iPXE menu within FOG, as well as an iPXE script for USB key booting.

## Miscellaneous

[Misc](https://github.com/mediocreatmybest/FOG-O-Matic/tree/main/Misc)

Miscellaneous scripts that I wrote or have been found online, these are useful for some Windows administration tasks.
External scripts *should* be unedited with their original url and details contained.

### Python Scripts

*firefox_ext_id.py* - This script displays the ID of a FireFox extension file (xpi), this is useful for deploying extensions with FireFox-ESR.
Use *--path* to the path of the xpi file. For example: *python firefox_ext_id.py --path ublock.xpi*

*PaperCut_Top-Up-Cards.py* - This script is based on the [PaperCut TopUpCards example](https://github.com/PaperCutSoftware/PaperCutExamples/tree/main/TopUpCards) files and is used with the PaperCut Printing Application for docx mail merge (pip install docx-mailmerge2).

The script needs a template.docx that has the following merge fields:
CardNumber1, CardNumber2, CardNumber3, CardNumber4, CardNumber5, CardNumber6, CardNumber7, CardNumber7 (These are the unique codes)
Value, ExpDateDisplay (These are the cards value and expiry date)
