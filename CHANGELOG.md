# Changelog

## [0.5.0] - Update payment method icons

- Update icons for payment methods

## [0.4.1] - Update readme for passkey support

## [0.4.0] - Support TAS Passkey Authentication

- Support Passkey authentication flow

## [0.3.0] - Added all APMs

- Now omise-flutter supports all major APMs with UI screens added to handle the custom flows.

## [0.2.0] - Major Update

### Breaking Changes

- **Complete Rewrite**: The library has been completely rewritten to enhance functionality, usability, and maintainability.
- **Deprecated Legacy APIs**: All APIs and patterns from `0.1.x` series have been removed. Users of previous versions will need to migrate to the new API.

### Added

- **Built-in UI Components**: Introduced customizable UI components for payment processing, simplifying integration for Flutter developers.
- **New Payment Flows**: Added support for tokenization and authorization flows.
- **Source Creation**: Seamless support for creating sources such as:
  - `promptpay`
  - `mobile_banking`
- **Internationalization (i18n)**: Added built-in support for multiple languages:
  - English (`en`)
  - Thai (`th`)
  - Japanese (`ja`)
- **Improved Debugging**: Added detailed debugging support with `enableDebug` option.
- **Error Handling**: Built-in mechanisms to manage common payment-related errors.

### Removed

- Legacy code and attributes from `0.1.x` versions.
- Examples and code patterns from the old architecture.

---

### Historical Archive (Pre-Rewrite)

## [0.1.6] - Bug fixes

- Bug fixes

## [0.1.5] - Minor update

- Null safety support; Thanks PR from @pitsanujiw

## [0.1.4] - Minor update

- Update an exmaple
- Update packages
- Deprecated a `security_code_check` attribute of Card API
- Added a new attribute named `charge_status` of Token API

## [0.1.3] - Update an example

- Add timeout error

## [0.1.2] - Update an example

- Bug fixes

## [0.1.1] - Update an example

- Bug fixes

## [0.1.0] - Update an example

- Update an example
- Update package
- Format code

## [0.0.1] - Initial release

- Initial release

---

### Notes:

- The historical changelog has been preserved for reference but is no longer actively maintained.
- For users on `0.1.x`, upgrading to `0.2.0` is a breaking change and requires revising your integration to align with the new architecture.
