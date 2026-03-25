enum ConfigurationProfile {
  development(
    baseUrl: 'https://631eb73e58a1c0fe9f562cec.mockapi.io/',
    name: 'development',
  ),
  staging(
    baseUrl: 'https://631eb73e58a1c0fe9f562cec.mockapi.io/',
    name: 'staging',
  ),
  production(
    baseUrl: 'https://631eb73e58a1c0fe9f562cec.mockapi.io/',
    name: 'production',
  );

  final String baseUrl;
  final int connectTimeout = _defaultConnectTimeout;
  final int receiveTimeout = _defaultReceiveTimeout;
  final int sendTimeout = _defaultSendTimeout;
  final String name;

  // Flavor things...

  const ConfigurationProfile({required this.baseUrl, required this.name});

  static const _defaultConnectTimeout = 30000;
  static const _defaultReceiveTimeout = 30000;
  static const _defaultSendTimeout = 30000;

  static ConfigurationProfile _current = ConfigurationProfile.development;

  static ConfigurationProfile get current {
    return _current;
  }

  static set current(ConfigurationProfile flavor) {
    _current = flavor;
  }
}
