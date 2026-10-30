
FROM python:3.12-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends git curl ca-certificates \
 && rm -rf /var/lib/apt/lists/*

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

RUN uv tool install --reinstall "git+https://github.com/huggingface/safeagents" \
 && ln -s /root/.local/bin/safeagents /usr/local/bin/safeagents

# Bifrost Virtual Key statt Bearer Authentication verwenden
RUN sed -i \
  's/{"authorization": f"Bearer {api_key}"}/{"x-bf-vk": api_key}/' \
  /root/.local/share/uv/tools/safeagents/lib/python3.12/site-packages/safeagents/judge.py

ENV PATH="/root/.local/bin:$PATH"

EXPOSE 8787

ENTRYPOINT ["safeagents"]
CMD ["start", "http://bifrost:8080", "0.0.0.0:8787"]
