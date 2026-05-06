# modvendor

A simple tool to copy additional (non-Go) module files into the local `./vendor`
folder after running `go mod vendor`.

`go mod vendor` only vendors `.go` files and `LICENSE` / `PATENTS` notices. If
your build depends on assets such as `.c`, `.h`, `.proto`, `.tmpl`, or any other
companion files, they are stripped from `./vendor` and your vendored build
breaks. `modvendor` walks `./vendor/modules.txt`, finds the matching source
directories under `$GOPATH/pkg/mod`, and copies the missing files back.

## Install

```sh
go install github.com/zhwei820/modvendor@latest
```

## Usage

Run `modvendor` from your project root, immediately after `go mod vendor`.

```sh
GO111MODULE=on go mod vendor
modvendor -copy="**/*.c **/*.h **/*.proto" -v
```

### Flags

| Flag | Description |
| --- | --- |
| `-copy` | Space-separated glob patterns to copy into `./vendor/` (e.g. `"**/*.c **/*.h **/*.proto"`). Required. |
| `-include` | Comma-separated list of import paths to include. When set, **only** these paths are vendored; everything else in `modules.txt` is skipped. |
| `-v` | Verbose output — print each file that is vendored. |

### Including extra paths

Some modules contain directories that aren't referenced by any Go package and
therefore don't appear in `./vendor/modules.txt`. Use `-include` to force them
to be vendored:

```sh
GO111MODULE=on go mod vendor
modvendor -copy="**/*.c **/*.h **/*.proto" -v \
  -include="github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis/google/api,\
github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis/google/rpc,\
github.com/prometheus/client_model"
```

If any `-include` path doesn't match a module in `vendor/modules.txt`,
`modvendor` exits with an error so typos surface immediately.

## How it works

1. Reads `./vendor/modules.txt` to learn each module's import path and version
   (including `replace` directives, both registry and local-path forms).
2. Resolves each module's source directory under `$GOPATH/pkg/mod`, applying
   the same case-folding (`!a` for uppercase) the Go toolchain uses.
3. Globs the module source against the `-copy` patterns.
4. Filters matches to the sub-packages actually listed in `modules.txt` (or to
   the `-include` allowlist when provided).
5. Copies surviving files into `./vendor/<import-path>/...`, mirroring the
   source layout.

## Requirements

- A `go.mod` file in the working directory.
- An existing `./vendor/modules.txt` (run `go mod vendor` first).
- The module sources present under `$GOPATH/pkg/mod` (populated by `go mod
  vendor` / `go mod download`).

## License

MIT
