# Angelehnt an https://github.com/bachl/methodenvl_ma
library(tidyverse) # Sammlung von R-Paketen für Datenimport, -bereinigung, -analyse und Visualisierung
library(httr2) # Senden von HTTP-Anfragen (APIs/Webseiten)
library(jsonlite) # Arbeiten mit JSON: Ein-/Auslesen, Konvertieren zwischen JSON und R-Objekten


# Load API key

# mit Funktion aus library(dotenv) um Umgebungsvariablen aus .env-Dateien ins env zu laden (hier API-Key)
dotenv::load_dot_env()
key <- Sys.getenv("API_KEY")

# Build JSON schema for structured output (Structured Outputs)

structured_output_format <- list(
    type   = "json_schema",
    name   = "social_media_incivility",
    strict = TRUE,
    schema = list(
        type = "object",
        properties = list(
            reasoning = list(description = "Short text to explain your reasoning", type = "string"),
            classification = list(
                description = "Classification into incivil or civil",
                type = "string",
                enum = c("incivil", "civil")
            )
        ),
        additionalProperties = FALSE,
        required = c("reasoning", "classification")
    )
)

# Load instruction and comments
instr <- paste(readLines("codieranweisung.txt", warn = FALSE, encoding = "UTF-8"),
               collapse = "\n")
comments <- readLines("comments.txt", warn = FALSE, encoding = "UTF-8")

# Build request to /v1/responses

req_test <- request("https://api.openai.com/v1/responses") |>
    req_method("POST") |>
    req_auth_bearer_token(key) |>
    req_headers("Content-Type" = "application/json") |>
    req_body_json(
        list(
            model = "gpt-5.1",
            input = list(
                list(role = "system", content = instr),
                list(role = "user", content = comments[1])
            ),
            text = list(format = structured_output_format),
            temperature = 0,
            max_output_tokens = 500
            # andere Optionen: https://platform.openai.com/docs/api-reference/responses/create
        )
    )

# Dry run - komplette Anfrage erstmal anzeigen
req_test |> req_dry_run()

# Test mit einem Text: Anfrage abschicken
resp_test_raw <- req_test |> req_perform()

# resp_test_raw inszpezierbar mit fromJSON() und resp_body_json(resp_test_raw)

req_list <- comments |>
    map( ~ {
        request("https://api.openai.com/v1/responses") |>
            req_method("POST") |>
            req_auth_bearer_token(key) |>
            req_headers("Content-Type" = "application/json") |>
            req_body_json(
                list(
                    model = "gpt-5.1",
                    input = list(
                        list(role = "system", content = instr),
                        list(role = "user", content = .x)
                    ),
                    text = list(format = structured_output_format),
                    temperature = 0,
                    max_output_tokens = 500
                    # andere Optionen: https://platform.openai.com/docs/api-reference/responses/create
                )
            )
    })

resp_list = req_list |>
    req_perform_parallel()


resp_tbl <- tibble(input = comments, resp  = resp_list) |>
    mutate(
        body = map(resp, ~ resp_body_json(.x, simplifyVector = FALSE)),
        
        # JSON-Text -> R-Objekt (Liste oder data.frame)
        parsed = map(
            body,
            ~ fromJSON(.x$output[[1]]$content[[1]]$text, simplifyVector = TRUE)
        )
        
        
    )

resp_parsed <- resp_tbl |>
    select(input, parsed) |>
    unnest_wider(parsed)

resp_parsed
