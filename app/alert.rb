module FC
  module Alert
    module_function

    def send(reason, message)
      alert.setMessageText(reason)
      alert.setInformativeText(message)
      alert.runModal
    end

    def alert
      @alert ||= NSAlert.alloc.init
    end
  end
end
