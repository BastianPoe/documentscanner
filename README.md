# documentscanner
`documentscanner` allows you to transform (almost) any [ADF](https://en.wikipedia.org/wiki/Automatic_document_feeder) scanner into a document scanner that produces OCRed PDFs. All you need is
* a [sane](http://sane-project.org/sane-supported-devices.html)-compatible ADF scanner
* a raspberry pi
* (optional) a more powerful host to run the OCR tasks

## Setup instructions
1. Check out `documentscanner` onto a raspberry pi: `$ git checkout https://github.com/BastianPoe/documentscanner.git`
1. Install sane and other dependencies`$ apt-get install sane sane-utils bash unpaper tesseract-ocr tesseract-ocr-deu imagemagick bc poppler-utils findutils scanbd`
1. Install scanbd script: `$ cp scanbd/test.script /etc/scanbd/scripts/`
1. Restart scanbd: `$ systemctl restart scanbd`
1. Create inbox and outbox: `$ mkdir -p /inbox /outbox`
1. Start document processor: `$ cd scripts ; ./process.sh /inbox /outbox`
1. Done

## What if it does not work
1. Check if `sane` recognizes your scanner via `$ scanimage -L`
1. Check the logs of `scanbd` via `$ journalctl -f`. You should be seeing log outputs whenever you press a button
1. Modify the events scanbd triggers for in `/etc/scanbd/scripts/test.script` (currently: scan and email)
1. Check if scanned raw documents end up in `/inbox`
1. Check logfiles of the processor
1. Check if PDFs end up in `/outbox`

## How it works

### Scanning
`documentscanner` uses [scanbd](https://sourceforge.net/p/scanbd/code/HEAD/tree/) to wait for someone to press a button on the scanner. This triggers the script in `/etc/scanbd/scripts/test.script` which differentiates which button has been pressed. The script calls `/home/pi/documentscanner/scripts/scan.sh` and scans all pages available into a folder in `/inbox`. After completing the scan, a file called `complete` is placed in the scan directory.

### PDF conversion
The processor checks every 10s in `/inbox` and if there is a new document with the `complete` flag, the document is processed. Initially, we use [identify](https://www.imagemagick.org/script/identify.php) with a heuristic to identify and remove empty pages. Then, each page is processed using [unpaper](http://mcs.une.edu.au/doc/unpaper/doc/index.html) to remove the background, etc. Subsequently, the pages are OCRed using [tesseract](https://github.com/tesseract-ocr/tesseract) and converted to PDFs. Finally, the individual PDFs are joined into one using [pdfunite](https://github.com/mtgrosser/pdfunite) and the scan directory is deleted.

### Maintenance required
Incomplete scans (e.g. those where the ADF pulled multiple pages at once) are aborted and never receive the `complete` flag and hence are not processed by the processor. Check `/inbox` from time to time to see, which documents have ended up there and delete them.

### (Optional) Speed up PDF generation
I run the processor in a Docker container on my [Synology](https://www.synology.com) NAS. This is way faster than on the raspberry and does not slow down subsequent scans. The required setup steps are quite easy:

1. Create a new shared directory on your NAS and expose it via NFS to your raspberry pi
1. Install autofs: `$ apt-get install autofs`
1. Add NFS mounting to /etc/autofs.misc: `documentarchive -rw,soft,intr,rsize=8192,wsize=8192 192.168.1.26:/volume1/documentarchive`
1. Enable autofs.misc by adding the following line to `/etc/autofs.master`: `/misc   /etc/auto.misc`
1. Edit your `/etc/scanbd/scripts/test.script` to place scans into your output folder. E.g. `FOLDER="/misc/documentarchive/scans_raw`
1. Pull `bastianpoe/document_archive` into the [Docker Station](https://www.synology.com/de-de/dsm/feature/docker) on your NAS
1. Map `/inbox` onto the NFS share created above and `/outbox` onto where the PDFs shall be stored
1. Start the docker container
1. Done
