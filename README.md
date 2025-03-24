# told_ya

Project initially presented for Starkhack 2024. The original repository can be found [here](https://github.com/RomainLafont/told_ya). This repository was separated from the first one as a way to clearly separate the original project and its state at the end of the hackathon from the future developments.

## Test / deploy

### Requirements

Requirements:

- scarb 2.8.4 ()
- cairo: 2.8.4 ([https://crates.io/crates/cairo-lang-compiler/](https://crates.io/crates/cairo-lang-compiler/))
- sierra: 1.6.0
- make (gcc)
- starkli: 0.3.8
- katana: 0.7.2 (dev dependency)

### Setup

Install the requirements:

```bash
make setup-unix
```

### Commands

Run devnet:

```bash
make run-network
```

In another terminal window, declare and deploy on devnet:

```bash
make contract-full
```
