module ErrorHelper
  def render_error(code, message)
    halt(code, slim(:error, locals: { message: message }))
  end
end
