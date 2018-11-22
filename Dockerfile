From ubuntu:16.04

RUN apt-get update 
RUN apt-get -y install libxmu6

RUN mkdir /sharm_dti
RUN mkdir /INPUTS
RUN mkdir /OUTPUTS

COPY driver /sharm_dti/driver
COPY run_driver.sh /sharm_dti/run_driver.sh
COPY MATLAB_Runtime /MATLAB_Runtime

ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:/MATLAB_Runtim/v94/runtime/glnxa64:/MATLAB_Runtim/v94/bin/glnxa64:/MATLAB_Runtim/v94/sys/os/glnxa64 

CMD /bin/bash usage.sh
