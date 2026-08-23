# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

- parseruri required -> no need for pcre

## [2.5.4] - 2026-07-30

- nix: switch to flakoboros
- ⚠️ drop external-libs
- fix minizip includes
- CMake & Nix: enable tests
- update boost filesystem uses
- CMake: clean
- add `daeStringRef::empty()`, fix build with gcc16

## [2.5.3] - 2026-02-21

- removed boost system, to fix build with boost 1.89
- automated flake lock update

## [2.5.2] - 2024-11-15

- update CMake minimum version to 3.10, to fix build with CMake v4
- setup Nix flake & CI
- setup pre-commit to remove end-of-line spaces
- setup mergify

## Previous versions

At <https://github.com/rdiankov/collada-dom> and <https://sourceforge.net/projects/collada-dom/>

[Unreleased]: https://github.com/Gepetto/collada-dom/compare/v2.5.3...HEAD
[2.5.3]: https://github.com/Gepetto/collada-dom/compare/v2.5.2...v2.5.3
[2.5.2]: https://github.com/Gepetto/collada-dom/releases/tag/v2.5.2
