FROM swift:5.9

WORKDIR /server
COPY Package.swift .
COPY Package.resolved .
COPY Sources .

WORKDIR /server

RUN swift build -c release

ENTRYPOINT ["/server/.build/release/IR_Controller"]

CMD ["/dev/ttyACM0"]
