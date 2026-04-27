# DocuAsk // Local Document Intelligence

DocuAsk is a high-performance, local-first RAG (Retrieval-Augmented Generation) application designed for secure and private document analysis. By utilizing **pgvector** for semantic search and **Ollama** for local inference, DocuAsk allows you to chat with your documents without your data ever leaving your machine.

---

## ⚡ Features

- **Local-First RAG:** Complete privacy. All embeddings and LLM processing happen on your hardware.
- **Vector-Based Retrieval:** Uses `pgvector` to find relevant context chunks with high mathematical precision.
- **Real-Time Interface:** Powered by **Hotwire (Turbo Streams & ActionCable)** for instant message delivery and "Thinking" state indicators.
- **Zinc Monochrome UI:** A professional, minimalist interface using a Zinc-gray palette for a clean, focused developer experience.
- **Chunked Processing:** Automatically segments documents into manageable context windows for accurate AI responses.

## 🛠 Tech Stack

- **Framework:** Ruby on Rails 8.x
- **Database:** PostgreSQL + `pgvector`
- **LLM Engine:** [Ollama](https://ollama.com/) (Default: `qwen3.5:9b` for inference, `nomic-embed-text` for embeddings)
- **Frontend:** Tailwind CSS (Zinc Palette) + Hotwire / Stimulus
- **Background Jobs:** ActiveJob (Running via `Async` or `Solid Queue`)

---

## 🚀 Getting Started

### 1. Prerequisites

Ensure you have the following installed:
- **Ruby 3.2.2+**
- **PostgreSQL 16+** (with `pgvector` extension)
- **Ollama** (Running locally at `http://localhost:11434`)

### 2. Install AI Models

Pull the required models via your terminal:
```bash
ollama pull qwen3.5:9b
ollama pull nomic-embed-text

## 🚀 Installation

Follow these steps to get your local environment running.

### 1. System Requirements
* **Ruby:** 3.2.2 or higher
* **PostgreSQL:** 16+ with the `pgvector` extension
* **Ollama:** Installed and running on `localhost:11434`

### 2. Prepare AI Models
You must have the inference and embedding models downloaded locally via Ollama:
```bash
# For generating answers
ollama pull qwen2.5:7b

# For document vectorization
ollama pull nomic-embed-text
