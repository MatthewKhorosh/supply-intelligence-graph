# Supply Intelligence Graph

**Agentic AI for Foodservice Distribution** | Built with Jac/Jaseci

> An autonomous AI agent that scrapes restaurant data, identifies supply products using Claude Vision, and maps them into an interactive knowledge graph — all in one Jac file.

## What It Does

Supply Intelligence Graph is a full-stack agentic AI application for the $300B foodservice distribution market. It automates the entire lead generation pipeline:

1. **Scrape** — Pulls restaurant data by ZIP code and cuisine type via Google Places and Yelp
2. **Identify** — Claude Vision analyzes restaurant photos to identify supply products using `by llm()`
3. **Enrich** — Scores leads by tier (T1/T2/T3), maps products to distributor catalog SKUs
4. **Act** — Drafts personalized outreach emails, pushes leads to Salesforce CRM
5. **Learn** — Correction feedback loop builds a defensible AI moat over time

No human in the loop. The agent runs the full plan–act–observe cycle autonomously.

## Why It Matters

Foodservice distributors still find leads manually — driving around, cold calling, buying outdated lists. This agent replaces that entire workflow with AI that:

- Finds restaurants by location and cuisine
- Knows what products they need before the first call
- Drafts personalized outreach automatically
- Tracks everything in CRM

Built on real production experience at McDonald Paper & Restaurant Supplies, a 30-year Brooklyn-based distributor.

## What Makes It Agentic

| Requirement | Implementation |
|---|---|
| Defined goal | Find and qualify restaurant supply leads |
| Tool usage | Claude Vision API, walker endpoints, CRM integration |
| Plan-act-observe loop | Scrape → Identify → Enrich → Act → Learn |
| Guardrails | Tier scoring (T1/T2/T3), correction training loop |
| Real product interface | Three-tab UI: Scrape, Leads, Graph |

## Where Jac/Jaseci Is Used

- **Entire application** is a single `main.jac` file — server, AI, and frontend
- **`by llm()`** replaces manual prompt engineering for product identification
- **Typed objects** (`ProductInfo`, `LeadInfo`) structure AI outputs
- **Public walkers** (`ScrapeLeads`, `AnalyzePhoto`, `DraftEmail`) auto-register as API endpoints
- **`jac-client`** renders the full-stack UI with reactive state
- **`jac start`** deploys everything — no separate frontend/backend

## Demo Flow (2 min)

1. **Scrape Tab** — Select ZIP code (11220) and cuisine (Pizza), hit Run Pipeline
2. **Leads Tab** — See restaurant leads populate with name, phone, email, tier
3. **Lead Detail** — Click a lead to see predicted products, draft AI email, push to CRM
4. **Graph Tab** — Interactive visualization of the full agent pipeline
5. **Vision AI** — Watch Claude identify products from a real restaurant photo

## Setup

```bash
# Install Jac
pip install jaseci

# Clone and run
git clone https://github.com/MatthewKhorosh/supply-intelligence-graph.git
cd supply-intelligence-graph/supply-intel

# Set your API key
echo "ANTHROPIC_API_KEY=your-key-here" > .env

# Start
jac start main.jac
# Open http://localhost:8000
```

## Tech Stack

- **Jac v0.11.0** — Full-stack language (server + client in one file)
- **byLLM** — `by llm()` for zero-prompt AI function calls
- **Claude Sonnet 4.5** — Vision API for product identification
- **jac-client** — Reactive frontend with JSX in Jac
- **SVG** — Interactive graph visualization with animated edges

## Architecture

```
main.jac (single file)
├── Server: ProductInfo + LeadInfo objects, by llm() functions
├── Walkers: ScrapeLeads, AnalyzePhoto, DraftEmail (auto-register as POST endpoints)
├── Client: Three-tab UI with reactive state, SVG graph visualization
└── AI: Claude Vision identifies products, generates emails, scores leads
```

## Built By

Matthew Khorosh — Solo build, 24 hours, Velric x The Foundry Hackathon, Miami Beach, Feb 2026

Built on production experience with [Suplook](https://suplook.com) — AI-powered product identification already deployed for McDonald Paper & Restaurant Supplies.
