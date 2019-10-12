FROM ubuntu:18.04

LABEL Description="This image provides a base Android development environment for React Native, and may be used to run tests."

# —————————————
# Install java8
# —————————————
RUN apt-get update && \
  apt-get install -y software-properties-common && \
  add-apt-repository -y ppa:webupd8team/java && \
  (echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections) && \
  apt-get update && \
  apt-get install -y openjdk-8-jdk openjdk-8-jre ruby && \
  apt-get clean && \
  rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ————————————
# Install Deps
# ————————————
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y curl \
                       git \
                       lib32stdc++6 \
                       lib32gcc1 \
                       lib32ncurses5 \
                       lib32z1 \
                       libc6-i386 \
                       libcurl4-openssl-dev \
                       libpulse0 \
                       libqt5widgets5 \
                       python \
                       unzip && \
    apt-get clean && \
    rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*

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
            "add-ons;addon-google_apis-google-24" \
            "system-images;android-${ANDROID_VERSION};google_apis;x86"

# Use correct Qt libs for emulator
ENV LD_LIBRARY_PATH ${ANDROID_HOME}/emulator/lib64/qt/lib/

# —————————————————
# Setup environment
# —————————————————
ENV PATH ${PATH}:${ANDROID_HOME}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools

# ————————————————————————————————
# Install Node and global packages
# ————————————————————————————————
ENV NODE_VERSION 10.15.2
RUN cd && \
    curl -L http://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz -o node-v${NODE_VERSION}-linux-x64.tar.gz && \
    tar -xzf node-v${NODE_VERSION}-linux-x64.tar.gz && \
    mv node-v${NODE_VERSION}-linux-x64 /opt/node && \
    rm node-v${NODE_VERSION}-linux-x64.tar.gz
ENV PATH ${PATH}:/opt/node/bin

# ————————————
# Install Yarn
# ————————————
ENV YARN_VERSION 1.16.0
RUN cd && \
    curl -L https://github.com/yarnpkg/yarn/releases/download/v${YARN_VERSION}/yarn_${YARN_VERSION}_all.deb -o yarn_${YARN_VERSION}_all.deb && \
    dpkg -i ./yarn_${YARN_VERSION}_all.deb && \
    rm yarn_${YARN_VERSION}_all.deb

ENV LANG en_US.UTF-8

# # Imports tools
# COPY tools/ /usr/local/bin
# RUN chmod +x /usr/local/bin/*


RUN apt-get -qq update && apt-get -qq install -y curl gnupg build-essential openssl
# RUN gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
# RUN curl -sSL https://get.rvm.io | bash -s stable
# RUN source /usr/local/rvm/scripts/rvm
# RUN rvm install ruby
# RUN rvm use ruby --default
RUN ruby -v
RUN apt-get update && \
  apt-get install -y ruby-full && \
  apt-get clean && \
  rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*
  
RUN gem install fastlane -NV
RUN npm i -g envinfo && envinfo




# # set default build arguments
# ARG SDK_VERSION=sdk-tools-linux-4333796.zip
# ARG ANDROID_BUILD_VERSION=28
# ARG ANDROID_TOOLS_VERSION=28.0.3
# ARG BUCK_VERSION=2019.09.03.01
# ARG NDK_VERSION=20
# ARG NODE_VERSION=10.x
# ARG WATCHMAN_VERSION=4.9.0

# # set default environment variables
# ENV ADB_INSTALL_TIMEOUT=10
# ENV ANDROID_HOME=/opt/android
# ENV ANDROID_SDK_HOME=${ANDROID_HOME}
# ENV ANDROID_NDK=/opt/ndk/android-ndk-r$NDK_VERSION

# ENV PATH=${ANDROID_NDK}:${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:/opt/buck/bin/:${PATH}

# # Install system dependencies
# RUN apt update -qq && apt install -qq -y --no-install-recommends \
#         apt-transport-https \
#         curl \
#         build-essential \
#         file \
#         git \
#         openjdk-8-jre \
#         gnupg2 \
#         python \
#         openssh-client \
#         unzip \
#     && rm -rf /var/lib/apt/lists/*;

# # install nodejs and yarn packages from nodesource and yarn apt sources
# RUN echo "deb https://deb.nodesource.com/node_${NODE_VERSION} stretch main" > /etc/apt/sources.list.d/nodesource.list \
#     && echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
#     && curl -sS https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
#     && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
#     && apt-get update -qq \
#     && apt-get install -qq -y --no-install-recommends nodejs yarn \
#     && rm -rf /var/lib/apt/lists/*

# # download and unpack NDK
# RUN curl -sS https://dl.google.com/android/repository/android-ndk-r$NDK_VERSION-linux-x86_64.zip -o /tmp/ndk.zip \
#     && mkdir /opt/ndk \
#     && unzip -q -d /opt/ndk /tmp/ndk.zip \
#     && rm /tmp/ndk.zip

# # download and install buck using debian package
# RUN curl -sS -L https://github.com/facebook/buck/releases/download/v${BUCK_VERSION}/buck.${BUCK_VERSION}_all.deb -o /tmp/buck.deb \
#     && dpkg -i /tmp/buck.deb \
#     && rm /tmp/buck.deb

# # Full reference at https://dl.google.com/android/repository/repository2-1.xml
# # download and unpack android
# RUN curl -sS https://dl.google.com/android/repository/${SDK_VERSION} -o /tmp/sdk.zip \
#     && mkdir ${ANDROID_HOME} \
#     && unzip -q -d ${ANDROID_HOME} /tmp/sdk.zip \
#     && rm /tmp/sdk.zip \
#     && yes | sdkmanager --licenses \
#     && yes | sdkmanager "platform-tools" \
#         "emulator" \
#         "platforms;android-$ANDROID_BUILD_VERSION" \
#         "build-tools;$ANDROID_TOOLS_VERSION" \
#         "add-ons;addon-google_apis-google-23" \
#         "system-images;android-19;google_apis;armeabi-v7a" \
#         "extras;android;m2repository"
