RubyLLM.configure do |config|
  # Ollama (local).
  config.ollama_api_base = "http://localhost:11434/v1"
  config.ollama_api_key = "fake-ollama-key-for-dev-and-test"  # Ollama ignores the value; the header just has to be present.
  config.default_model = "gpt-oss:20b"

  # Use the new association-based acts_as API (recommended)
  config.use_new_acts_as = true

  # Custom model registry class name
  config.model_registry_class = "Ai::Model"

  config.logger = Rails.logger

  # Environment-specific settings
  config.request_timeout = Rails.env.production? ? 120 : 30
  config.log_level = Rails.env.production? ? :info : :debug
end
