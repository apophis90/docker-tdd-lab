FROM golang:1.10-alpine

COPY . /app

WORKDIR /app

RUN go build -o copycat

ENV PORT=2000

CMD ["./copycat"]