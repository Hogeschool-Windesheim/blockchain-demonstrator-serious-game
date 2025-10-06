namespace BlockchainDemonstratorApi.Models.Classes
{
    /// <summary>
    /// This method is used to currently determine the URL of the RestApiUrl.
    /// This is because this URL can change between the debug and release environment.
    /// This class is used to easily determine the what URL to use, instead of having to change it manually when switching between the environments.
    /// </summary>
    /// <remarks>Other URL's can be added if need be when they change between the debug and release environment.</remarks>
    public static class Config
    {
        public static string RestApiUrl { get; set; }
        public static string ServerIp { get; set; }

        /// <summary>
        /// Public-facing API URL for client-side JavaScript (browsers).
        /// Falls back to RestApiUrl if not explicitly set.
        /// Set via environment variable: PUBLIC_API_URL
        /// </summary>
        public static string PublicApiUrl
        {
            get => _publicApiUrl ?? RestApiUrl;
            set => _publicApiUrl = value;
        }
        private static string _publicApiUrl;
    }
}
