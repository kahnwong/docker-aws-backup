FROM amazon/aws-cli:latest

RUN yum update -y && \
    yum install -y tar gzip postgresql && \
    yum clean all
