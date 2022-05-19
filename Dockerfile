FROM openjdk:11.0.11-jdk

# nodejs, zip, to unzip things
RUN apt-get update && \
    apt-get -y install zip expect && \
    curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/* && \
	apt-get autoremove -y && \
	apt-get clean

# Install 32bit support for Android SDK
RUN dpkg --add-architecture i386 && \
    apt-get update -q && \
    apt-get install -qy --no-install-recommends libstdc++6:i386 libgcc1:i386 zlib1g:i386 libncurses5:i386  && \
    rm -rf /var/lib/apt/lists/* && \
	apt-get autoremove -y && \
	apt-get clean

# install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn  && \
    rm -rf /var/lib/apt/lists/* && \
	apt-get autoremove -y && \
	apt-get clean

# install build-essential
RUN apt-get update && apt-get install -y build-essential \
    cmake \
    git \
    ninja-build && \
    rm -rf /var/lib/apt/lists/* && \
	apt-get autoremove -y && \
	apt-get clean

# ------------------------------------------------------
# --- Android NDK

# download
# RUN mkdir /opt/android-ndk-tmp && \
#     cd /opt/android-ndk-tmp && \
#     wget -q https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip && \
# # uncompress
#     unzip -q android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip && \
# # move to its final location
#     mv ./android-ndk-${ANDROID_NDK_VERSION} ${ANDROID_NDK_HOME} && \
# # remove temp dir
#     cd ${ANDROID_NDK_HOME} && \
#     rm -rf /opt/android-ndk-tmp

ENV GRADLE_VERSION 6.7
ENV GRADLE_SDK_URL https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip
RUN curl -sSL "${GRADLE_SDK_URL}" -o gradle-${GRADLE_VERSION}-bin.zip  \
    && unzip gradle-${GRADLE_VERSION}-bin.zip -d /usr/local  \
    && rm -rf gradle-${GRADLE_VERSION}-bin.zip
ENV GRADLE_HOME /usr/local/gradle-${GRADLE_VERSION}
ENV PATH ${GRADLE_HOME}/bin:$PATH

# Setup environment
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# android sdk tools
RUN cd /opt \
    && wget -q https://dl.google.com/android/repository/commandlinetools-linux-7302050_latest.zip -O tools.zip \
    && mkdir -p ${ANDROID_HOME} \
    && unzip tools.zip  \
    && rm -f tools.zip \
    && mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && mv cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest

RUN mkdir $ANDROID_HOME/licenses
RUN echo 8933bad161af4178b1185d1a37fbf41ea5269c55 >> $ANDROID_HOME/licenses/android-sdk-license
RUN echo 84831b9409646a918e30573bab4c9c91346d8abd >> $ANDROID_HOME/licenses/android-sdk-preview-license
RUN echo d56f5187479451eabf01fb78af6dfcb131a6481e >> $ANDROID_HOME/licenses/android-sdk-license
RUN echo 24333f8a63b6825ea9c5514f83c2829b004d1fee >> $ANDROID_HOME/licenses/android-sdk-license

# copy tools folder
COPY tools /opt/tools
ENV PATH ${PATH}:/opt/tools

# sdk
RUN echo "y" | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "tools"
RUN echo "y" | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platform-tools"
RUN echo "y" | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "build-tools;26.0.2"
RUN echo "y" | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "build-tools;27.0.3"
RUN echo "y" | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "build-tools;28.0.2"
RUN echo "y" | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "build-tools;28.0.3"
RUN echo "y" | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "build-tools;29.0.2"
RUN echo "y" | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platforms;android-23"
RUN echo "y" | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platforms;android-28"
RUN echo "y" | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platforms;android-29"
RUN echo "y" | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platforms;android-30"
RUN echo "y" | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "extras;android;m2repository"
RUN echo "y" | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "extras;google;m2repository"
RUN echo "y" | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "extras;google;google_play_services"
RUN echo "y" | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "ndk-bundle"
RUN echo "y" | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "cmake;3.6.4111459"
RUN echo "y" | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --channel=3 --channel=1 "cmake;3.10.2.4988404"
RUN echo "y" | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses

RUN \
  wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh \
  && chmod +x dotnet-install.sh \
  && mkdir -p /usr/share/dotnet \
  && ./dotnet-install.sh --channel 3.1 --install-dir /usr/share/dotnet \
  && ./dotnet-install.sh --channel 5.0 --install-dir /usr/share/dotnet \
  && ./dotnet-install.sh --channel 6.0 --install-dir /usr/share/dotnet

ENV PATH /usr/share/dotnet:$PATH

WORKDIR /root
