From ubuntu:16.04

# Install the matlab compiled runtime
RUN apt-get update && apt-get install -y wget unzip && \
    mkdir /MCR && \
    wget -nv -P /MCR http://ssd.mathworks.com/supportfiles/downloads/R2017a/deployment_files/R2017a/installers/glnxa64/MCR_R2017a_glnxa64_installer.zip && \
    unzip /MCR/MCR_R2017a_glnxa64_installer.zip -d /MCR/MCR_R2017a_glnxa64_installer && \
    /MCR/MCR_R2017a_glnxa64_installer/install -mode silent -agreeToLicense yes && \
    rm -r /MCR/MCR_R2017a_glnxa64_installer /MCR/MCR_R2017a_glnxa64_installer.zip && \
    rmdir /MCR

# Other system packages
RUN apt-get update && \
    apt-get install -y openjdk-8-jre

# Copy the compiled matlab that runs our processing
COPY bin /opt/gradtensor

# Create input/output directories for binding
mkdir /INPUTS && mkdir /OUTPUTS

# Default command shows usage for the two modules
CMD /bin/bash usage.sh
