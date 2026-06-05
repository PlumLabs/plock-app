class AnalyticsAssistantAgent < RubyLLM::Agent
  TRANSIENT_ERRORS = [
    RubyLLM::RateLimitError,
    RubyLLM::ServerError,
    RubyLLM::ServiceUnavailableError,
    RubyLLM::OverloadedError
  ].freeze

  TERMINAL_ERRORS = [
    RubyLLM::ConfigurationError,
    RubyLLM::ModelNotFoundError,
    RubyLLM::InvalidRoleError,
    RubyLLM::BadRequestError,
    RubyLLM::UnauthorizedError,
    RubyLLM::PaymentRequiredError,
    RubyLLM::ForbiddenError,
    RubyLLM::ContextLengthExceededError
  ].freeze

  chat_model Ai::Chat
  instructions
  tools Ai::InspectSchemaTool, Ai::RunSqlTool, Ai::CurrentDateTool
end
