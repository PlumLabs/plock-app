RubyLLM.configure do |config|
  # Ollama (local by default).
  config.ollama_api_base = ENV.fetch("OLLAMA_API_BASE", "http://localhost:11434/v1")
  config.ollama_api_key  = ENV.fetch("OLLAMA_API_KEY", "fake-ollama-key-for-dev-and-test")
  config.default_model   = ENV.fetch("RUBYLLM_DEFAULT_MODEL", "gpt-oss:20b")

  # Use the new association-based acts_as API (recommended)
  config.use_new_acts_as = true

  # Custom model registry class name
  config.model_registry_class = "Ai::Model"

  config.logger = Rails.logger

  # Environment-specific settings
  config.request_timeout = Rails.env.production? ? 120 : 30
  config.log_level = Rails.env.production? ? :info : :debug
end
