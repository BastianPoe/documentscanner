FROM debian:stable
MAINTAINER Wolf-Bastian Pöttner <bastian@poettner.de>

# Expose inbox and outbox
VOLUME ["/inbox", "/outbox"]

# Install dependencies
RUN apt-get update && apt-get -y -qq install unpaper tesseract-ocr tesseract-ocr-deu imagemagick

# Install our scripts
COPY scripts/process.sh scripts/create_pdf.sh /root

# Run document processor
ENTRYPOINT /root/process.sh
CMD ["/inbox", "/outbox"]
