FROM swift:5.9

WORKDIR /server
COPY Package.swift .
COPY Package.resolved .
COPY Sources ./Sources/

WORKDIR /server

RUN swift package update

RUN swift build -c release

ENTRYPOINT ["/server/.build/release/IR_Controller"]

CMD ["/dev/ttyACM0", "--hostname", "0.0.0.0", "--port", "8080"]
