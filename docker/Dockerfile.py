FROM python:3.8-slim-buster
COPY ./trigger_scripts /trigger_scripts
COPY ./trigger.py /
RUN pip3 install flask && \
    apt update -y && \ 
    apt install curl -y
    
CMD [ "python", "./trigger.py"]