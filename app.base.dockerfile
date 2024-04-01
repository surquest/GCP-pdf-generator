FROM python:3.12-alpine AS base

# Install Weasyprint
# RUN apk --update --upgrade 
# RUN apk add py3-pip gcc musl-dev python3-dev pango zlib-dev jpeg-dev openjpeg-dev g++ libffi-dev
# RUN apk add pango
RUN apk --update --upgrade --no-cache add fontconfig ttf-freefont font-noto terminus-font \ 
   && fc-cache -f \ 
   && fc-list | sort 
RUN apk add weasyprint
# RUN apk add weasyprint fontconfig
# RUN apk add weasyprint pango
# RUN apk --update --upgrade --no-cache add \
#     cairo-dev pango-dev gdk-pixbuf

# Update pip
RUN pip install --no-cache-dir --upgrade pip

# Define root directory
ENV ROOT_DIR /app
# Set the working directory to /app
WORKDIR $ROOT_DIR

# Copy the python requirements file to install dependencies
COPY src/requirements.txt src/requirements.txt

# Install all needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r src/requirements.txt
