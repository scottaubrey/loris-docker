# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

# Update packages and install tools
RUN apt-get update -y --fix-missing && \
    apt-get install -y --no-install-recommends \
    gcc \
    python3-dev python3-setuptools python3-pip python3-venv \
    wget curl git unzip \
    libjpeg8 libjpeg8-dev libjpeg-turbo8-dev \
    libfreetype6 libfreetype6-dev \
    liblcms2-2 liblcms2-dev liblcms2-utils \
    libtiff5-dev libwebp-dev \
    libxml2-dev libxslt1-dev \
    zlib1g-dev \
    libssl-dev libpcre3-dev \
    build-essential \
    netcat \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip, setuptools, and wheel
RUN python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel

# Install uwsgi from Ubuntu repository
RUN apt-get update -y && \
    apt-get install -y uwsgi uwsgi-plugin-python3

# Install other Python packages
RUN python3 -m pip install --no-cache-dir configobj==5.0.6

# Install Loris
WORKDIR /opt

RUN wget --quiet https://github.com/loris-imageserver/loris/archive/v3.0.0.zip && \
    unzip v3.0.0.zip && \
    mv loris-3.0.0 loris && \
    rm v3.0.0.zip

RUN mkdir /usr/local/share/images

# Configure Loris
WORKDIR /opt/loris

# Copy necessary configuration files
COPY loris2.wsgi /var/www/loris2/loris2.wsgi 
COPY uwsgi.ini /etc/loris2/uwsgi.ini
COPY loris2.conf /etc/loris2.conf

# Install Pillow directly with specific version
RUN python3 -m pip install --no-cache-dir Pillow==8.2.0

# Install each package individually from requirements.txt
COPY requirements.txt /opt/loris/requirements.txt
RUN while read requirement; do python3 -m pip install --no-cache-dir $requirement; done < /opt/loris/requirements.txt

# Setup directories for Loris
RUN PYTHONPATH=/opt/loris/ python3 ./bin/setup_directories.py

# Change ownership to www-data
RUN chown www-data:www-data -R .

# Add healthcheck script
COPY healthcheck.sh .
HEALTHCHECK --interval=10s --timeout=5s --retries=3 CMD ./healthcheck.sh

# Expose port and set CMD
EXPOSE 5004
CMD ["uwsgi", "--ini", "/etc/loris2/uwsgi.ini"]


