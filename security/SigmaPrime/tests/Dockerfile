FROM python:3.9.4-slim-buster

# Get required packages
RUN apt-get update && \
apt-get -y upgrade && \
apt-get install -y --no-install-recommends wget autoconf automake openssl libtool libffi-dev npm make g++ git clang lld && \
apt-get clean

# build the libsecp256k1 library
# (in a docker cache friendly way)
ADD https://api.github.com/repos/bitcoin-core/secp256k1/git/refs/heads/master version.json
RUN git clone https://github.com/bitcoin-core/secp256k1.git && cd secp256k1 && ./autogen.sh && ./configure && make && make install

# Install Ganache
RUN npm install -g ganache-cli

# Install the Python requirements
COPY tests/requirements.txt /

RUN python3 -m pip install --no-cache-dir --upgrade pip && \
python3 -m pip install --no-cache-dir -r requirements.txt --no-deps

# Copy the contract source code and test suite
COPY ./tests /tests

# Set the working directory to the tests/ dir
WORKDIR /tests

ARG INFURA_URL

# Create a mainnet fork
RUN echo "Docker file params: $INFURA_URL"
RUN brownie networks add development mainnet-fork-16286330 cmd=ganache-cli host=http://127.0.0.1 fork=$INFURA_URL@16286330 accounts=10 mnemonic=brownie port=8545


# Create a script for running Ganache and then running the tests (need to sleep to ensure Ganache has initialised)
RUN echo "brownie test -sv" > run-tests.sh
RUN chmod u+x run-tests.sh

# "docker run" will execute the tests against the compiled contracts
CMD ./run-tests.sh