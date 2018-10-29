FROM openjdk:8

# nodejs, zip, to unzip things
RUN apt-get update && \
    apt-get -y install zip expect && \
    curl -sL https://deb.nodesource.com/setup_11.x | bash - && \
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

ENV GRADLE_VERSION 3.3
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
    && wget -q https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip -O tools.zip \
    && mkdir -p ${ANDROID_HOME} \
    && unzip tools.zip -d ${ANDROID_HOME} \
    && rm -f tools.zip

RUN mkdir $ANDROID_HOME/licenses
RUN echo 8933bad161af4178b1185d1a37fbf41ea5269c55 > $ANDROID_HOME/licenses/android-sdk-license
RUN echo 84831b9409646a918e30573bab4c9c91346d8abd > $ANDROID_HOME/licenses/android-sdk-preview-license

# copy tools folder
COPY tools /opt/tools
ENV PATH ${PATH}:/opt/tools

# sdk
RUN echo "y" | $ANDROID_HOME/tools/bin/sdkmanager "tools" \
    && echo "y" | $ANDROID_HOME/tools/bin/sdkmanager "platform-tools" \
    && echo "y" | $ANDROID_HOME/tools/bin/sdkmanager "build-tools;23.0.1" \
    && echo "y" | $ANDROID_HOME/tools/bin/sdkmanager "build-tools;23.0.3" \
    && echo "y" | $ANDROID_HOME/tools/bin/sdkmanager "build-tools;25.0.3" \
    && echo "y" | $ANDROID_HOME/tools/bin/sdkmanager "build-tools;26.0.2" \
    && echo "y" | $ANDROID_HOME/tools/bin/sdkmanager "build-tools;27.0.3" \
    && echo "y" | $ANDROID_HOME/tools/bin/sdkmanager "build-tools;28.0.2" \
    && echo "y" | $ANDROID_HOME/tools/bin/sdkmanager "build-tools;28.0.3" \
    && echo "y" | $ANDROID_HOME/tools/bin/sdkmanager "platforms;android-23" \
    && echo "y" | $ANDROID_HOME/tools/bin/sdkmanager "platforms;android-25" \
    && echo "y" | $ANDROID_HOME/tools/bin/sdkmanager "platforms;android-26" \
    && echo "y" | $ANDROID_HOME/tools/bin/sdkmanager "platforms;android-27" \
    && echo "y" | $ANDROID_HOME/tools/bin/sdkmanager "platforms;android-28" \
    && echo "y" | $ANDROID_HOME/tools/bin/sdkmanager "extras;android;m2repository" \
    && echo "y" | $ANDROID_HOME/tools/bin/sdkmanager "extras;google;m2repository" \
    && echo "y" | $ANDROID_HOME/tools/bin/sdkmanager "extras;google;google_play_services" \
    && echo "y" | $ANDROID_HOME/tools/bin/sdkmanager --licenses

WORKDIR /root
