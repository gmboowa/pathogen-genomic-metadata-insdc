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
---
### Example query multiple run accessions

```bash
curl -sG "https://www.ebi.ac.uk/ena/portal/api/search" \
  --data-urlencode 'result=read_run' \
  --data-urlencode 'query=run_accession=ERR11968331 OR run_accession=ERR11968338 OR run_accession=ERR11968340 OR run_accession=ERR11968343 OR run_accession=ERR11968349 OR run_accession=ERR11968350 OR run_accession=ERR11968359 OR run_accession=ERR11968360 OR run_accession=ERR11968366 OR run_accession=ERR11968367 OR run_accession=ERR11968372 OR run_accession=ERR11968387 OR run_accession=ERR11968390 OR run_accession=ERR11968400 OR run_accession=ERR11968415 OR run_accession=ERR11968434' \
  --data-urlencode 'fields=run_accession,sample_accession,study_accession,scientific_name,first_public,instrument_platform,instrument_model,library_strategy,library_selection,library_source,country,collection_date,isolation_source,location,host,sample_title' \
  --data-urlencode 'format=tsv' \
  --data-urlencode 'limit=0' \
  > Selected_runs.tsv


```
---
## Output format

The downloaded file is a tab-separated (TSV) table containing fields such as:

- 🧬 **Run accession**
- 🧪 **BioSample accession**
- 📦 **BioProject / Study accession**
- 🔬 **Scientific name**
- 🖥️ **Sequencing platform & instrument**
- 🧫 **Library strategy & source**
- 🌍 **Country / location**
- 📅 **Collection date**
- 🦠 **Isolation source**
- 👤 **Host**
- 📝 **Sample title**

### These fields are suitable for downstream filtering, enrichment & analysis.

---
## Downloading the raw reads (runs)

Recommended (more robust, avoids partial downloads)

```bash
cut -f1 input.tsv > s_aureus_tanzania_ENA.txt

mkdir -p fastq && cat s_aureus_tanzania_ENA.txt | xargs -n 1 -P 4 fastq-dump --split-3 --gzip --outdir fastq

```
-P 4 → downloads 4 runs in parallel (adjust to your bandwidth)

--split-3 → handles paired or single-end correctly

--gzip → compresses FASTQs

--outdir fastq → keeps things tidy



### Important notes:

Ensure s_aureus_tanzania_ENA.txt contains only one run accession per line (e.g. ERR12511691)

Make sure SRA Toolkit is configured:

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

tax_name("<PATHOGEN_NAME>") AND country="<COUNTRY>" OR continent="<CONTINENT>"

Multiple countries / regions / continent

tax_name("<PATHOGEN_NAME>") AND (country="<COUNTRY1>" OR country="<COUNTRY2>")

Tip: You can also substitute country= with other filters such as host=, collection_date=, or project/study accessions depending on your question.

---

### Notes & limitations

Metadata completeness varies widely by project & submitter.
One isolate may have multiple runs; use BioSample accession to deduplicate isolates where appropriate.
AMR phenotypes / resistance calls are often not included in run metadata & may require:


### Downloading the raw reads (runs)

#### usage


```bash

cut -f1 input.tsv > pathogen_country_ena.tsv

mkdir -p fastq && cat pathogen_country_ena.tsv | xargs -n 1 -P 4 fastq-dump --split-3 --gzip --outdir fastq
-P 4 → downloads 4 runs in parallel 
--split-3 → handles paired or single-end correctly
--gzip → compresses FASTQs
--outdir fastq → keeps things tidy

```
Important notes:

Ensure pathogen_country_ena.txt contains only one run accession per line (e.g. ERR12511691)

### Make sure SRA Toolkit is configured
---

### Pathogen SRA download utility

For larger download jobs, this repository also supports a simple Bash-based 'download_pathogen_sra.sh' workflow for downloading runs directly from a TSV file containing SRA accessions in the first column.

Script

The utility script is named:

download_pathogen_sra.sh

It is designed to:

parse the first column of an input TSV file,
automatically ignore an optional header,
create the output directory if it does not exist,
download reads with fastq-dump --split-3 --gzip,
show progress as current / total with percentage,
skip runs that have already been downloaded,
write logs for successful and failed downloads.

Example command

```bash

bash download_pathogen_sra.sh \
  --input pathogen_country_ena.tsv \
  --output reads

```
Parameters

Parameter	Description	Required
--input	Absolute path to the TSV file containing run accessions in the first column	Yes
--output	Output directory where downloaded FASTQ files and logs will be written	Yes

Expected input format

The script expects a TSV file where the first column contains run accessions such as:

ERR123456
ERR123457
SRR987654
DRR765432

A header row may be present and will be skipped automatically.

---

#### Output files

The script writes downloaded reads and log files into the output directory provided with --output.

Typical outputs include:

ERR123456.fastq.gz for single-end runs
ERR123456_1.fastq.gz and ERR123456_2.fastq.gz for paired-end runs
download_success.log
download_failed.log
run_accessions.txt
Progress reporting

During execution, the script displays progress in the format:

[12/340 | 3.53%] Downloading: ERR123456

#### This makes it easier to monitor large download jobs and estimate how far the run has progressed.
---

### Example use case

This utility is useful when metadata have already been exported from ENA into a file such as:

pathogen_country_ena.tsv

and the goal is to reproducibly retrieve the corresponding raw sequence reads into a dedicated output directory, for example:

reads
Usage notes
Run the script with bash rather than relying on direct execution from an external drive
Ensure fastq-dump is installed and available in your PATH
Re-running the script is safe because already downloaded runs are skipped automatically

---
## License

MIT License 




