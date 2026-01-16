## Pathogen Genomic Metadata (INSDC)

Reproducible tools & curated metadata for public pathogen sequencing data from **INSDC nucleotide repositories**, including **ENA (European Nucleotide Archive)** & **NCBI SRA (Sequence Read Archive)**.

This repository is **pathogen-agnostic** & **geography-agnostic**. The same approach can be applied to **any pathogen** & **any geographic scope** (country, region, continent, or global).

---

## Purpose

Public sequencing repositories contain vast amounts of pathogen genomic data, but metadata are often:
- scattered across multiple records (run, sample, study),
- inconsistently populated,
- difficult to retrieve reproducibly.

This repository provides:
- standardized queries to retrieve run-level metadata,
- example datasets,
- a reproducible pattern for generating metadata tables suitable for:
  - genomic surveillance
  - antimicrobial resistance (AMR) research
  - molecular epidemiology
  - downstream bioinformatics workflows

---

## Data sources (INSDC)

- **ENA** – European Nucleotide Archive  
- **NCBI SRA** – Sequence Read Archive  

These databases synchronize under the **INSDC** framework.

---

## Quickstart: Download metadata from ENA (example)

Below is an example using *Staphylococcus aureus* isolates from **Tanzania**.

> *This is only an example.*  
> Replace the pathogen name & geographic scope with your own use case.

### Example ENA query

```bash
curl -sG "https://www.ebi.ac.uk/ena/portal/api/search" \
  --data-urlencode 'result=read_run' \
  --data-urlencode 'query=tax_name("Staphylococcus aureus") AND country="Tanzania"' \
  --data-urlencode 'fields=run_accession,sample_accession,study_accession,scientific_name,first_public,instrument_platform,instrument_model,library_strategy,library_selection,library_source,country,collection_date,isolation_source,location,host,sample_title' \
  --data-urlencode 'format=tsv' \
  --data-urlencode 'limit=0' \
  > s_aureus_tanzania_ENA_runs.tsv

```
---
## Output format

The downloaded file is a tab-separated (TSV) table containing fields such as:

- 🧬 **Run accession**
- 🧪 **BioSample accession**
- 📦 **BioProject / Study accession**
- 🔬 **Scientific name**
- 🖥️ **Sequencing platform & instrument**
- 🧫 **Library strategy and source**
- 🌍 **Country / location**
- 📅 **Collection date**
- 🦠 **Isolation source**
- 👤 **Host**
- 📝 **Sample title**

### These fields are suitable for downstream filtering, enrichment & analysis.
---

## Example dataset included in this repository

This repository includes a small **example dataset** for reference.

### File layout

```bash

data/examples/
├── s_aureus_tanzania_ENA_runs.tsv


```
---
### What the example demonstrates

Expected columns (run/sample/study & key metadata fields)

Naming conventions for outputs & folders

Real-world completeness issues (missing fields, inconsistent entries)

### Using placeholders (recommended pattern)

Replace the example pathogen & geography with your own use case.

Generic template (single country)

tax_name("<PATHOGEN_NAME>") AND country="<COUNTRY>"

Multiple countries / regions

tax_name("<PATHOGEN_NAME>") AND (country="<COUNTRY1>" OR country="<COUNTRY2>")

Tip: You can also substitute country= with other filters such as host=, collection_date=, or project/study accessions depending on your question.

### Notes & limitations

Metadata completeness varies widely by project and submitter.
One isolate may have multiple runs; use BioSample accession to deduplicate isolates where appropriate.
AMR phenotypes / resistance calls are often not included in run metadata and may require:

📄 linked publications,

📎 supplementary tables,

🧪 downstream genomic analysis (e.g., gene/variant-based AMR prediction).

---
## License

Code: MIT License (see LICENSE)

Data: Derived from public repositories — please cite original studies & respect repository terms.

makefile
Copy code
