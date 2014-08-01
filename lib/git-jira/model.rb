require 'ostruct'
require 'forwardable'

module GitJira
  class Model < OpenStruct
    extend Forwardable

    def ok?
      error_messages.nil?
    end

    def error_messages
      errorMessages
    end
  end
end
