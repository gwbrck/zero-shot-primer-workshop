# Zero-Shot Mini-Workshop: Classification with the OpenAI API

This repository contains the material for the mini workshop **"Zero-Shot with the OpenAI API -- Primer for Zero-Shot Classification with LLMs"**.

> **Note:** The slides and examples in this primer workshop are in **German**.

## Repository contents

- `Folien.qmd` / `Folien.pdf`: Quarto source file and exported slides of the workshop (German) including figures from https://github.com/masurp/VU_CADC
- `demo.R`: R script containing an example workflow for zero-shot classification via the OpenAI API
- `codieranweisung.txt`, comments.txt`: Example comments and instruction used for classification in the workshop (taken from https://github.com/bachl/methodenvl_ma)
- `main.bib`: Bibliography file (BibTeX)

## Requirements

- R (recommended: current version)
- RStudio / Positron
- Installed R packages:
  - `tidyverse`
  - `httr2`
  - `jsonlite`
  - `dotenv`
  - optional for Quarto/slides: `quarto`, LaTeX distribution

## Setting up the OpenAI API

1.  Create an OpenAI API key and store it locally.
2.  Create a `.env` file in the project directory, for example:

        API_KEY=your_api_key_here

3.  Make sure that `.env` is **not** tracked in version control (add to `.gitignore` if needed).

The script `demo.R` automatically loads the key via `dotenv::load_dot_env()` and reads it using `Sys.getenv("API_KEY")`.

## Demo workflow (`demo.R`)

The script demonstrates:

- Loading the instruction from `codieranweisung.txt` and the example comments from `comments.txt`
- Building a structured output format (JSON schema) for the classification
- Sending a request to the `/v1/responses` endpoint of the OpenAI API
- Iterating over the comments and creating a list of requests
