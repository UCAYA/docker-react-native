FROM reactnativecommunity/react-native-android

RUN \
  apt update && apt install -y wget

RUN \
  wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh \
  && chmod +x dotnet-install.sh \
  && mkdir -p /usr/share/dotnet \
  && ./dotnet-install.sh --channel 3.1 --install-dir /usr/share/dotnet \
  && ./dotnet-install.sh --channel 6.0 --install-dir /usr/share/dotnet \
  && ./dotnet-install.sh --channel 7.0 --install-dir /usr/share/dotnet

ENV PATH /usr/share/dotnet:$PATH

WORKDIR /root
