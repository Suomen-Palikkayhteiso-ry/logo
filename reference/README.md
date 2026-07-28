# Reference data

## `allowed-colors.csv`

The Rebrickable LEGO color catalog (`name,rgb,is_trans,num_parts,num_sets,y1,y2`).
This is the upstream reference from which the brand color tokens in
[`../content/colors.toml`](../content/colors.toml) are derived — e.g. the brand
`lego-black` token (`#05131D`) is the catalog's "Black" entry.

It is reference data only; nothing in the token pipeline reads it at build time.
Keep it here as the single home for LEGO-color source data across the repo family
(the logo pipeline in the `bricklayer` repo picks brick colors from the same set).
