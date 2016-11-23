# dstat-redis [![Build Status](https://travis-ci.org/maiha/dstat-redis.cr.svg?branch=master)](https://travis-ci.org/maiha/dstat-redis.cr)

Store dstat output into redis as JSON string.

- crystal: 0.19.4, 0.20.0
- binary download: https://github.com/maiha/dstat-redis.cr/releases

## Features

- Handy : just one x86 binary (no fluentd or Ruby needed)

## Config

- edit `config.toml`

```toml
verbose = false

[dstat]
prog = "dstat"
args = "-clmdny --tcp"

[redis]
host = "127.0.0.1"
port = 6379
# pass = "secret"

cmds = [
  "SET dstat __json__",
]
```

#### Dynamic Value

- `__json__` : a runtime dstat data as JSON
- `__host__` : a running host name
- `__XXXX__` : a dstat value correspond to the field (ex. `__epoch__`)
- `__%Y%m__` : keywords that starts with '%' will be passed to `strftime(3)` with dstat[epoch]

## Usage

#### basic

- Running with default `config.toml` puts json to `redis://localhost:6379/dstat`
- Get and jq as you like! For example, show current `Used Memory` and `TIME_WAIT` socket.

```shell
% dstat-redis config.toml &
% redis-cli --raw GET dstat | jq .used,.tim
"1193M"
"14"
```

#### pub/sub

- vi `config.toml` (add "PUBLISH" command)

```toml
cmds = [
  "SET     dstat __json__",
  "PUBLISH dstat __json__",
]
```

```shell
% dstat-redis config.toml &
% redis-cli --raw SUBSCRIBE dstat
subscribe
dstat
1
message
dstat
{"usr":1,"sys":1,"idl":98,"wai":0,"hiq":0,"siq":0,"1m":0.34,"5m":0.2,"15m":0.14,"used":663000000,"buff":356000000,"cach":788000000,"free":193000000,"read":0,"writ":16000,"recv":1740,"send":1320,"int":374,"csw":474,"lis":19,"act":19,"syn":0,"tim":2,"clo":0,"epoch":1472404633}
```

- Oh, it's noisy. Body Template will be good use for this case.

```toml
cmds = [
  "PUBLISH dstat mem:__used__,disk(in=__read__,out=__writ__)",
]
```

```shell
% dstat-redis config.toml -v
Connecting 127.0.0.1:6379 ... OK
debug: ["PUBLISH", "dstat", "mem:1213000000,disk(in=676,out=33000)"]
...
```

#### store as epoched stats for one day

- vi `config.toml` (add "ZADD" command)
- NOTE: ZADD `CH` option needs Redis 3.0.2 or higher

```toml
cmds = [
  "ZADD   dstat/__host__/__%Y%m%d-%H__ CH __epoch__ __json__",
  "EXPIRE dstat/__host__/__%Y%m%d-%H__ 86400",
  "SADD   dstat/__host__ __%Y%m%d-%H__",
]
```

```shell
% dstat-redis config.toml -v
debug: ["ZADD", "dstat/ubuntu/20160829-23", "CH", "1472480308", ...]
debug: ["SADD", "dstat/ubuntu", "20160829-23"]

% redis-cli SMEMBERS dstat/ubuntu
1) "20160829-23"

# We can find heavy HDD `writ` on some period between epoch1 and epoch2.
# For instance, the hostname is `ubuntu` and the period is between 1472480308 and 1472480310.
% redis-cli --raw ZRANGEBYSCORE "dstat/ubuntu/20160829-23" 1472480308 1472480310 | jq .writ | sort -nr | head
60000
16000
6866
```

## Restrictions

- json : Duplicated keys would be exist (not a valid JSON format)
  - ex: `(mem)used` and `(swap)used` -> `{"used":"10KB",...,"used":"0"}`

## Roadmap

#### 0.5

- [ ] Other Formats

#### 1.0

- [ ] Independent from `dstat`

## Contributing

1. Fork it ( https://github.com/maiha/dstat-redis/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [maiha](https://github.com/maiha) maiha - creator, maintainer
