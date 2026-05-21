FROM ollama/ollama:0.23.1

ENV OLLAMA_MODELS=/root/.ollama/models

RUN nohup bash -c "ollama serve &" && \
    sleep 5 && \
    ollama pull qwen3:0.6b
