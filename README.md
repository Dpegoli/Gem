# gem

Write validators in the `validators` folder, and supporting functions in the `lib` folder using `.ak` as a file extension.

```aiken
validator my_first_validator {
  spend(_datum: Option<Data>, _redeemer: Data, _output_reference: Data, _context: Data) {
    True
  }
}
```

## Building

```sh
aiken build
```

## Configuring

**aiken.toml**
```toml
[config.default]
network_id = 41
```

Or, alternatively, write conditional environment modules under `env`.

## Testing

You can write tests in any module using the `test` keyword. For example:

```aiken
use config

test foo() {
  config.network_id + 1 == 42
}
```

To run all tests, simply do:

```sh
aiken check
```

To run only tests matching the string `foo`, do:

```sh
aiken check -m foo
```

## Documentation

If you're writing a library, you might want to generate an HTML documentation for it.

Use:

```sh
aiken docs
```

## Resources

Find more on the [Aiken's user manual](https://aiken-lang.org).

## Off-Chain Setup

The off-chain Lucid prototype lives in `off-chain/lucid-test`.

1. Copy `off-chain/lucid-test/.env.example` to `off-chain/lucid-test/.env`
2. Add your Blockfrost Preview API key to `off-chain/lucid-test/.env`
3. Build the package:

```sh
cd off-chain/lucid-test
npm run build
```

4. Verify Blockfrost connectivity:

```sh
npm run dev
```

5. Optionally generate a local wallet file:

```sh
npm run wallet:generate
```

`wallet.json` and `.env` are local-only files and should never be committed.
