# TestKafka

Minimal Kafka 0.8 runner suitable for integration testing.

Adapted from the excellent [poseidon](https://github.com/bpot/poseidon)'s integration tests.

## Installation

Add TestKafka to your application's Gemfile:

```ruby
gem 'test_kafka', '~> 0.1.0'
```

and bundle:

    $ bundle

## Usage

```ruby
require 'test_kafka'

cluster = TestKafka.start('/usr/local/kafka')
# or specify custom a temp directory and kafka/zk ports:
# cluster = TestKafka.start('/usr/local/kafka', '/tmp', 9092, 2181)

# ... interact with Kafka/ZK ...

cluster.stop
```

## Requirements

* Kafka 0.8 or higher
