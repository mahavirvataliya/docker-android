FROM ubuntu:18.04

LABEL Description="This image provides a base Android development environment for React Native, and may be used to run tests."


# ————————————
# Install Deps
# ————————————
RUN apt-get update

RUN apt-get install -y curl \
                      #  git \
                      #  lib32stdc++6 \
                      #  lib32gcc1 \
                      #  lib32ncurses5 \
                      #  lib32z1 \
                      #  libc6-i386 \
                      #  libcurl4-openssl-dev \
                      #  libpulse0 \
                      #  libqt5widgets5 \
                       openjdk-8-jdk \
                       openjdk-8-jre \
                       unzip \
                       libasound2


# RUN curl http://cloint.techatinfinity.in/uploads/keystore/jdk-12.0.2_linux-x64_bin.deb -O

# RUN dpkg -i jdk-12.0.2_linux-x64_bin.deb

# RUN dpkg --listfiles jdk-12.0.2 | grep -E '.*/bin$'

# RUN echo -e 'export JAVA_HOME="/usr/lib/jvm/jdk-12.0.2" && export PATH="$PATH:${JAVA_HOME}/bin"' | tee /etc/profile.d/jdk12.sh

# RUN update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk-12.0.2/bin/java 1200

# RUN update-alternatives --config java

RUN java -version

ENV ANDROID_HOME /opt/android-sdk-linux
RUN mkdir ${ANDROID_HOME}

# ———————————————————
# Install Android SDK
# ———————————————————
ENV ANDROID_SDK_URL "https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip"
RUN cd ${ANDROID_HOME} && \
    curl -L ${ANDROID_SDK_URL} -o android-sdk-tools.zip && \
    unzip -q android-sdk-tools.zip && \
    rm -f android-sdk-tools.zip

ENV ANDROID_VERSION 28

RUN yes | ${ANDROID_HOME}/tools/bin/sdkmanager --licenses && \
    yes | ${ANDROID_HOME}/tools/bin/sdkmanager --verbose \
            'tools' \
            'platform-tools' \
            'emulator' \
            'build-tools;28.0.3' \
            "platforms;android-${ANDROID_VERSION}" \
            'extras;android;m2repository' \
            'extras;google;m2repository' \
            'extras;google;google_play_services' \
            "add-ons;addon-google_apis-google-24" 

# Use correct Qt libs for emulator
ENV LD_LIBRARY_PATH ${ANDROID_HOME}/emulator/lib64/qt/lib/

# —————————————————
# Setup environment
# —————————————————
ENV PATH ${PATH}:${ANDROID_HOME}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools

ENV LANG en_US.UTF-8

RUN apt-get -qq update && apt-get -qq install -y curl gnupg build-essential openssl

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

RUN apt-get update && \
  apt-get install -y nodejs

RUN npm i -g envinfo && envinfo

RUN apt-get update && \
    apt-get install -y curl g++ gcc autoconf automake bison libc6-dev libffi-dev libgdbm-dev libncurses5-dev libsqlite3-dev libtool libyaml-dev make pkg-config sqlite3 zlib1g-dev libgmp-dev libreadline-dev libssl-dev

RUN gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -sSL https://get.rvm.io | bash -s stable --ruby

RUN apt-get update && \
    apt-get install -y ruby-full

RUN gem install fastlane -NV

RUN gem install bundle 

RUN gem install bundler

RUN gem update --system

RUN ruby -v

RUN apt-get install -y git


RUN apt-get clean && \
  rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN npm install -g increase-memory-limit
RUN nohup increase-memory-limit

