# dstat-redis

Store dstat output into redis as JSON string.

- tested on crystal-0.18.7
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
  "SET dstat __json__",
  "PUBLISH dstat/timeline __json__",
]
```

```shell
% dstat-redis config.toml &
% redis-cli --raw SUBSCRIBE dstat/timeline
subscribe
dstat/timeline
1
message
dstat/timeline
{"usr":"0","sys":"0","idl":"99","wai":"0","hiq":"0","siq":"0","1m":"0.15","5m":"0.15","15m":"0.10","used":"1196M","buff":"135M","cach":"7028M","free":"2959M","read":"0","writ":"0","recv":"298B","send":"418B","int":"519","csw":"839","lis":"23","act":"22","syn":"0","tim":"2","clo":"0","epoch":"1472204432"}
...
```

- Oh, it's noisy. Body Template will be implemented in 0.2.
- The image is like this.

```toml
cmds = [
  "PUBLISH dstat/timeline mem:{{used}},disk(in={{read}},out={{writ}})",
]
```

## Restrictions

- All data are stored as String
- Duplicated keys would be exist (not a valid JSON format)
  - ex: `(mem)used` and `(swap)used` -> `{"used":"10KB",...,"used":"0"}`

## Roadmap

#### 0.2

- [ ] Body Template

#### 0.3

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
