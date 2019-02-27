ARG TAG="20190220"
ARG DESTDIR="/tomcat-native"

FROM huggla/alpine-official as alpine

ARG BUILDDEPS="build-base apr-dev chrpath openjdk8 openssl-dev"
ARG VERSION="1.2.21"
ARG DOWNLOAD="https://www-eu.apache.org/dist/tomcat/tomcat-connectors/native/$VERSION/source/tomcat-native-$VERSION-src.tar.gz"
ARG DESTDIR

RUN apk add $BUILDDEPS \
 && buildDir="$(mktemp -d)" \
 && cd $buildDir \
 && wget "$DOWNLOAD" \
 && tar -xvp -f "$(basename "$DOWNLOAD")" \
 && rm "$(basename "$DOWNLOAD")" \
 && cd tomcat-native-$VERSION-src/native \
 && ./configure --prefix=/usr --with-apr=/usr/bin/apr-1-config --with-java-home=/usr/lib/jvm/default-jvm --with-ssl=yes \
 && make \
 && mkdir -p "$DESTDIR" \
 && make install \
 && chrpath --delete "$DESTDIR/usr/lib/libtcnative-1.so" \
 && rm -f "$DESTDIR/usr/lib/libtcnative-1.la" "$DESTDIR/usr/lib/libtcnative-1.a" "$DESTDIR/usr/lib/pkgconfig/tcnative-1.pc" \
 && rm -rf "$DESTDIR/usr/bin" "$DESTDIR/usr/include" "$DESTDIR/usr/lib/pkgconfig"
 
FROM huggla/busybox:$TAG as image

ARG DESTDIR

COPY --from=alpine $DESTDIR $DESTDIR
