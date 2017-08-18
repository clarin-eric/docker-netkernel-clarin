FROM nk

# add mod-clarin
ADD mod-clarin /app/nk/1060-NetKernel-SE-DK-3.3.1/modules/own/mod-clarin
RUN sed -i 's|</modules>|<module>modules/own/mod-clarin</module></modules>|g' /app/nk/1060-NetKernel-SE-DK-3.3.1/etc/deployedModules.xml

# add mod-clarin to the front end fulcrum
RUN cd /app/nk/1060-NetKernel-SE-DK-3.3.1/modules/mod-fulcrum-frontend &&\
    xmlstarlet ed -a "//mapping/comment()[last()]" -t elem -name import -s "//mapping/import[last()]" -t elem -name uri -v "urn:clarin" module.xml > module.xml.NEW &&\
    mv module.xml module.xml.BAK &&\
    mv module.xml.NEW module.xml 