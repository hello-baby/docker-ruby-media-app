FROM eu.gcr.io/baby-snap-173700/ruby-dev-app:2.4.2

RUN apt-get update -qq && \
    apt-get install -y autoconf automake libass-dev libfreetype6-dev libsdl2-dev \
                       libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev \
                       libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev pkg-config texinfo \
                       zlib1g-dev yasm libvpx-dev cmake mercurial && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir $HOME/ffmpeg_sources
ENV PATH $HOME/bin:$PATH

RUN cd $HOME/ffmpeg_sources && \
    wget http://www.nasm.us/pub/nasm/releasebuilds/2.13.01/nasm-2.13.01.tar.bz2 && \
    tar xjvf nasm-2.13.01.tar.bz2 && \
    cd nasm-2.13.01 && \
    ./autogen.sh && \
    ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" && \
    make && make install && \
    cd $HOME/ffmpeg_sources && \
    wget http://download.videolan.org/pub/x264/snapshots/last_x264.tar.bz2 && \
    tar xjvf last_x264.tar.bz2 && \
    cd x264-snapshot* && \
    ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-shared --disable-opencl && \
    make && make install && \
    cd $HOME/ffmpeg_sources && \
    hg clone https://bitbucket.org/multicoreware/x265 && \
    cd $HOME/ffmpeg_sources/x265/build/linux && \
    cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=on ../../source && \
    make && make install && \
    cd $HOME/ffmpeg_sources && \
    wget -O fdk-aac.tar.gz https://github.com/mstorsjo/fdk-aac/tarball/master && \
    tar xzvf fdk-aac.tar.gz && \
    cd mstorsjo-fdk-aac* && \
    autoreconf -fiv && \
    ./configure --prefix="$HOME/ffmpeg_build" --enable-shared && \
    make && make install && \
    cd $HOME/ffmpeg_sources && \
    wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 && \
    tar xjvf ffmpeg-snapshot.tar.bz2 && \
    cd ffmpeg && \
    PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
      --prefix="$HOME/ffmpeg_build" \
      --disable-static \
      --extra-cflags="-I$HOME/ffmpeg_build/include" \
      --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
      --extra-libs="-lpthread" \
      --bindir="$HOME/bin" \
      --enable-gpl \
      --enable-libass \
      --enable-libfdk-aac \
      --enable-libfreetype \
      --enable-libtheora \
      --enable-libvorbis \
      --enable-libvpx \
      --enable-libx264 \
      --enable-libx265 \
      --enable-pic \
      --enable-shared \
      --enable-nonfree && \
    PATH="$HOME/bin:$PATH" make && \
    make install && \
    hash -r && \
    cp -r /home/apps/ffmpeg_sources/ffmpeg/lib* /usr/include && \
    export PKG_CONFIG_PATH=/home/apps/ffmpeg_build/lib/pkgconfig && \
    cd $HOME && git clone https://github.com/dirkvdb/ffmpegthumbnailer && \
    cd $HOME/ffmpegthumbnailer && cmake -DCMAKE_BUILD_TYPE=Release -DENABLE_GIO=ON -DENABLE_THUMBNAILER=ON . && \
    make && make install && \
    rm -rf /home/apps/ffmpeg_sources

ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/lib:/usr/local/lib64:/home/apps/ffmpeg_build/lib
