ARG PROJ=bun-mod
ARG BUILDER=localhost/${PROJ}-builder:develop
ARG BASE=localhost/${PROJ}-base:develop

FROM $BUILDER AS BUILD
ARG PROJ
COPY . /app/${PROJ}/
WORKDIR /app/${PROJ}
RUN task compile -- --frozen-lockfile --production

#######################################################

FROM $BASE AS RUNTIME
ARG PROJ
ENV PROJ=$PROJ

COPY --chown=1000:0 --from=BUILD /app/${PROJ}/out/ /app/
RUN sh -c 'test -f /app/app || printf "#!/bin/bash\nexec /app/${PROJ} \$@\n" > /app/app ; chmod 755 /app/app' && \
    sh -c 'printf "#!/bin/bash\nexec /app/${PROJ} %s\n" live > /app/app-live ; chmod 755 /app/app-live' && \
    sh -c 'printf "#!/bin/bash\nexec /app/${PROJ} %s\n" ready > /app/app-ready ; chmod 755 /app/app-ready'

EXPOSE 3000
# ENV DB_FILE=/data/${PROJ}.db
CMD ["/app/app"]
