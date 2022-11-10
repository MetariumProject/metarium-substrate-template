# Note: This is currently designed to simplify development
# To get a smaller docker image, there should be 2 images generated, in 2 stages.

FROM rustlang/rust:nightly

LABEL Name=metariumsubstratetemplate Version=0.0.1

ARG PROFILE=release
WORKDIR /metarium

# Upcd dates core parts
RUN apt-get update -y && \
	apt-get install -y cmake pkg-config libssl-dev openssh-client git gcc build-essential clang libclang-dev

# Install rust wasm. Needed for substrate wasm engine
RUN rustup target add wasm32-unknown-unknown

# # Download Metarium subtrate template repo
RUN mkdir -p -m 0700 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts
RUN --mount=type=ssh git clone --depth=1 "git@github.com:MetariumProject/metarium-substrate-template.git" /metarium
# RUN git clone https://github.com/MetariumProject/metarium-substrate-template /metarium
# RUN cd /metarium && git submodule init && git submodule update
RUN cd /metarium

# COPY . .

# Download rust dependencies and build the rust binary
# RUN cargo run "--$PROFILE"
RUN ls
RUN cargo build "--$PROFILE"

# 30333 for p2p traffic
# 9933 for RPC call
# 9945 for Websocket
# 9615 for Prometheus (metrics)
EXPOSE 30333 9933 9945 9615


ENV PROFILE ${PROFILE}

# The execution will re-compile the project to run it
# This allows to modify the code and not have to re-compile the
# dependencies.
CMD cargo check -p node-template-runtime "--$PROFILE"

# CMD cargo run --bin node-template -- --dev