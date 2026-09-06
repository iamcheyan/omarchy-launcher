# Application Launcher

An Omarchy launcher with the original single-level launcher layout and Omarchy's native menu content and application launch behavior.

## Design

- Single-level searchable launcher surface inspired by the original Sumika launcher.
- Menu entries are read from Omarchy's native `omarchy-menu.jsonc` files.
- Applications are provided by Omarchy's native application library.
- Launches use Omarchy's native application handling instead of a second desktop-entry cache or launcher daemon.

## Install

```sh
omarchy plugin add https://github.com/iamcheyan/omarchy-launcher.git --enable
```

## Test

```sh
omarchy-shell shell summon iamcheyan.launcher '{"menu":"root"}'
```

## Remove

```sh
omarchy plugin remove iamcheyan.launcher
```

## License

MIT.
