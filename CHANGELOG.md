# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- GitHub Actions workflow for building and releasing artifacts
- Version management script in PowerShell

## [1.0.0] - 2025-05-01

### Added
- Windows service implementation for monitoring telemetry services
- Automatic stopping and disabling of telemetry services
- Configuration through appsettings.json
- PowerShell script for manual telemetry disabling
- Windows Event Log integration for tracking service actions
- Support for .NET 9.0

[Unreleased]: https://github.com/liquizz/telemetry-guard/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/liquizz/telemetry-guard/releases/tag/v1.0.0 