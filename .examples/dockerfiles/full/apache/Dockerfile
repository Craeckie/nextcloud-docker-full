FROM nextcloud

RUN set -ex; \
    \
    apt-get update; \
    apt-get upgrade -y --no-install-recommends \
        ffmpeg \
        libmagickcore-6.q16-6-extra \
        procps \
        smbclient \
        supervisor \
#       libreoffice \
    ; \
    rm -rf /var/lib/apt/lists/*

RUN set -ex; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libbz2-dev \
        libc-client-dev \
        libkrb5-dev \
        libsmbclient-dev \
    ; \
    \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl; \
    ln -svf "/usr/include/$(dpkg-architecture --query DEB_BUILD_MULTIARCH)/gmp.h" /usr/include/gmp.h; \
    docker-php-ext-install \
        bz2 \
        imap \
    ; \
    pecl install smbclient; \
    docker-php-ext-enable smbclient; \
    \
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark; \
    ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
        | awk '/=>/ { print $3 }' \
        | sort -u \
        | xargs -r dpkg-query -S \
        | cut -d: -f1 \
        | sort -u \
        | xargs -rt apt-mark manual; \
    \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*

RUN rm -f /etc/apache2/mods-enabled/reqtimeout.{conf,load}

ADD 000-default.conf userdata.conf /etc/apache2/sites-available/
RUN mkdir -p --mode=660 /var/www/userdata && \
    chown 9000:9000 /var/www/userdata && \
    a2enmod proxy_http ssl headers env dir mime proxy && \
    a2ensite userdata

# RUN apt update && apt install -y gnupg && \
#     echo deb https://dl.jsxc.org stable main > /etc/apt/sources.list.d/jsxc.list && \
#     curl https://dl.jsxc.org/archive.key | apt-key add - && \
#     apt update && \
#     apt install -y xcauth

RUN apt-get update && apt-get  install -y supervisor && \
    mkdir -p /var/log/supervisord /var/run/supervisord && \
    rm -rf /var/lib/apt/lists/*

ADD supervisord.conf /supervisord.conf

ENV NEXTCLOUD_UPDATE=1

CMD ["/usr/bin/supervisord", "-c", "/supervisord.conf"]
