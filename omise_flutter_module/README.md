# omise_flutter_module

A flutter module used in native SDKs to replace the native UI and add payment methods in one place and reflect changes across the other native platforms.

## Getting Started

To use this module you should compile it and add it into your desired native integration.

### Environment variables

The `omise_flutter` package that is used inside the module depends on `omise_dart`. `omise_dart` uses some environment variables to manage the url of the vault and the main api of the omise integration. When using the production environment you do not need to set up any env as the package will automatically point to the correct url. But when we set the env to staging the staging urls should already be defined in the envs in order for the module to work properly in your native app. For this, before compiling the module using the build command make sure to set up the following envs:

```bash
BASE_STAGING_VAULT_URL
BASE_STAGING_URL
```

### For android use:

```bash
flutter build aar \
  --release \
  --no-debug \
  --no-profile \
  --dart-define=BASE_STAGING_URL=$BASE_STAGING_URL \
  --dart-define=BASE_STAGING_VAULT_URL=$BASE_STAGING_VAULT_URL
```

Copy the folder with everything inside it `~/omise_flutter/omise_flutter_module/build/host/outputs/repo`.

- There are three major builds: release, debug and profile.
- The command will only generate the release version but you can edit to generate your desired output.
- Paste that folder in the desired path, you can use any of the desired builds and delete the ones that you do not need.
