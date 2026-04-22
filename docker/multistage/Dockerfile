# ── Stage 1: Builder ──────────────────────────────────────────
FROM ubuntu:latest AS builder

# Install build tools
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git

# Simulate building something
WORKDIR /build
COPY index.html .

# Simulate a build process — minify HTML
RUN sed 's/  */ /g' index.html > index.min.html

# ── Stage 2: Production ───────────────────────────────────────
FROM nginx:alpine AS production

# Copy ONLY the built file from Stage 1
# Nothing else comes with it — no ubuntu, no curl, no wget, no git
COPY --from=builder /build/index.min.html /usr/share/nginx/html/index.html

EXPOSE 80
