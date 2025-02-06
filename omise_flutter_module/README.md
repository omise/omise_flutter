# omise_flutter_module

A flutter module used in native SDKs to replace the native UI and add payment methods in one place and reflect changes across the other native platforms.

## Getting Started

To use this module you should compile it and add it into your desired native integration.

### For android use:

```
flutter build aar
```

Copy the folder with everything inside it `~/omise_flutter/omise_flutter_module/build/host/outputs/repo`.

- There are three major builds: release, debug and profile.
- Paste that folder in the desired path, you can use any of the desired builds and delete the ones that you do not need.
