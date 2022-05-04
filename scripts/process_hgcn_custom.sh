#!/usr/bin/env bash
# Expects to be run from directory containing hgcn_custom_result.txt
# Rewrites header of custom results and gzips.

# Downstream expected column names:
#   Approved symbol
#   Approved name
#   Previous symbols
#   Alias symbols
#   Ensembl gene ID

INFILE="${PWD}/hgcn_custom_results.txt"
OUTFILE="${PWD}/hgcn_genenames.txt"
HEADER="symbol\tname\talias_symbol\tprev_symbol\tensembl_gene_id"

if [[ ! -f "${INFILE}" ]]; then
  echo "file NOT extant"
  exit 1
fi

echo -e "${HEADER}" > "${OUTFILE}"
tail -n +2 "${INFILE}" >> "${OUTFILE}"
gzip -f "${OUTFILE}"
