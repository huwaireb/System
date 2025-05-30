(when (string= system-type "darwin") 
  (add-to-list 'auth-sources 'macos-keychain-internet)
  (add-to-list 'auth-sources 'macos-keychain-generic))

(setopt gptel-model 'anthropic/claude-sonnet-4
        gptel-backend (gptel-make-gh-copilot "Copilot"))

(gptel-make-openai "OpenRouter"
                   :host "openrouter.ai"
                   :endpoint "/api/v1/chat/completions"
                   :stream t
                   :key (lambda () (auth-source-pick-first-password :label "openrouter.ai"))
                   :models '(anthropic/claude-sonnet-4
                             google/gemini-2.5-pro-preview))
