class FailureApp
  def self.call(env)
    error_message = env['warden.options'][:message] || 'Unauthorized'
    [401, { 'Content-Type' => 'application/json' }, [{ error: error_message }.to_json]]
  end
end