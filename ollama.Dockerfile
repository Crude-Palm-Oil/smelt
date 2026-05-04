FROM ollama/ollama:0.2.3

ENV OLLAMA_MODELS=/root/.ollama/models

RUN nohup bash -c "ollama serve &" && \
    sleep 5 && \
    ollama pull qwen2.5:7b
