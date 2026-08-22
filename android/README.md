# Android Setup

The intended application ID and namespace are:

`com.wellsint.brainyte.safeshake`

Generate the Android platform with Flutter, then set both `namespace` and
`applicationId` to this value in the Android Gradle configuration.

```bash
flutter create --platforms=android,ios --org com.wellsint.brainyte .
```

After Firebase configuration, add `google-services.json` through the normal
FlutterFire setup. Do not commit it if your repository policy excludes it.
